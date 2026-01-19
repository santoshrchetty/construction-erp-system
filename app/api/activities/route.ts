import { NextRequest, NextResponse } from 'next/server';
import { createServiceClient } from '@/lib/supabase/server';
import { resourcePlanningService } from '@/lib/services/resourcePlanning.service';
import type { Database } from '@/types/supabase/database.types';

type ActivityMaterialsTable = Database['public']['Tables']['activity_materials'];

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url);
    const projectId = url.searchParams.get('projectId');
    const activityId = url.searchParams.get('activityId');
    const action = url.searchParams.get('action');

    const supabase = await createServiceClient();
    
    // Get materials for an activity
    if (action === 'materials' && activityId) {
      const { data, error } = await supabase
        .from('activity_materials')
        .select('*')
        .eq('activity_id' satisfies keyof ActivityMaterialsTable['Row'], activityId);
      
      if (error) throw error;
      
      let enrichedData = data;
      
      // Fetch material master data
      const materialIds = data?.map(m => m.material_id).filter(Boolean) || [];
      
      if (materialIds.length > 0) {
        const { data: materials } = await supabase
          .from('materials')
          .select('id, material_code, material_name, base_uom')
          .in('id', materialIds);
        
        const materialsMap = new Map(materials?.map(m => [m.id, m]));
        
        // Get activity code to fetch actuals
        const { data: activity } = await supabase
          .from('activities')
          .select('code')
          .eq('id', activityId)
          .single();
        
        if (activity) {
          const { data: actuals } = await supabase
            .from('universal_journal')
            .select('company_amount')
            .eq('activity_code', activity.code)
            .in('cost_element', ['501000', '502000']);
          
          const totalActual = actuals?.reduce((sum, row) => sum + (row.company_amount || 0), 0) || 0;
          const totalPlanned = data?.reduce((sum, row) => sum + (row.required_quantity * row.unit_cost), 0) || 0;
          
          enrichedData = data?.map(row => {
            const material = materialsMap.get(row.material_id);
            return {
              ...row,
              material_code: material?.material_code || null,
              material_name: material?.material_name || null,
              actual_cost: totalPlanned > 0 ? (row.required_quantity * row.unit_cost / totalPlanned) * totalActual : 0
            };
          });
        }
      }
      
      return NextResponse.json(enrichedData);
    }

    // Get equipment for an activity
    if (action === 'equipment' && activityId) {
      const { data, error } = await supabase
        .from('activity_equipment')
        .select('*')
        .eq('activity_id', activityId);
      
      if (error) throw error;
      
      // Fetch equipment master data
      const equipmentIds = data?.map(e => e.equipment_id).filter(Boolean) || [];
      const { data: equipment } = await supabase
        .from('equipment')
        .select('id, equipment_code, equipment_name, category')
        .in('id', equipmentIds);
      
      const equipmentMap = new Map(equipment?.map(e => [e.id, e]));
      
      const { data: activity } = await supabase
        .from('activities')
        .select('code')
        .eq('id', activityId)
        .single();
      
      if (activity) {
        const { data: actuals } = await supabase
          .from('universal_journal')
          .select('company_amount')
          .eq('activity_code', activity.code)
          .eq('cost_element', '531000');
        
        const totalActual = actuals?.reduce((sum, row) => sum + (row.company_amount || 0), 0) || 0;
        const totalPlanned = data?.reduce((sum, row) => sum + (row.required_hours * row.hourly_rate), 0) || 0;
        
        const enrichedData = data?.map(row => {
          const equip = equipmentMap.get(row.equipment_id);
          return {
            ...row,
            equipment_code: equip?.equipment_code,
            equipment_name: equip?.equipment_name,
            actual_cost: totalPlanned > 0 ? (row.required_hours * row.hourly_rate / totalPlanned) * totalActual : 0
          };
        });
        
        return NextResponse.json(enrichedData);
      }
      
      return NextResponse.json(data);
    }

    // Get manpower for an activity
    if (action === 'manpower' && activityId) {
      const { data, error } = await supabase
        .from('activity_manpower')
        .select('*')
        .eq('activity_id', activityId);
      
      if (error) throw error;
      
      // Fetch employee master data
      const employeeIds = data?.map(m => m.employee_id).filter(Boolean) || [];
      
      let enrichedData = data;
      
      if (employeeIds.length > 0) {
        const { data: employees, error: empError } = await supabase
          .from('employees')
          .select('id, employee_code, first_name, last_name, job_title')
          .in('id', employeeIds);
        
        const employeesMap = new Map(employees?.map(e => [e.id, e]));
        
        const { data: activity } = await supabase
          .from('activities')
          .select('code')
          .eq('id', activityId)
          .single();
        
        if (activity) {
          const { data: actuals } = await supabase
            .from('universal_journal')
            .select('company_amount')
            .eq('activity_code', activity.code)
            .eq('cost_element', '511000');
          
          const totalActual = actuals?.reduce((sum, row) => sum + (row.company_amount || 0), 0) || 0;
          const totalPlanned = data?.reduce((sum, row) => sum + (row.required_hours * row.hourly_rate), 0) || 0;
          
          enrichedData = data?.map(row => {
            const employee = employeesMap.get(row.employee_id);
            return {
              ...row,
              employee_code: employee?.employee_code || null,
              employee_name: employee ? `${employee.first_name} ${employee.last_name}` : null,
              actual_cost: totalPlanned > 0 ? (row.required_hours * row.hourly_rate / totalPlanned) * totalActual : 0
            };
          });
        }
      }
      
      return NextResponse.json(enrichedData);
    }

    // Get services for an activity
    if (action === 'services' && activityId) {
      const { data, error } = await supabase
        .from('activity_services')
        .select('*')
        .eq('activity_id', activityId);
      
      if (error) throw error;
      
      const { data: activity } = await supabase
        .from('activities')
        .select('code')
        .eq('id', activityId)
        .single();
      
      if (activity) {
        const { data: actuals } = await supabase
          .from('universal_journal')
          .select('company_amount, cost_elements!inner(cost_element_type)')
          .eq('activity_code', activity.code)
          .eq('cost_elements.cost_element_type', 'OVERHEAD');
        
        const totalActual = actuals?.reduce((sum, row) => sum + (row.company_amount || 0), 0) || 0;
        const totalPlanned = data?.reduce((sum, row) => sum + (row.duration_hours * row.unit_cost), 0) || 0;
        const enrichedData = data?.map(row => ({
          ...row,
          actual_cost: totalPlanned > 0 ? (row.duration_hours * row.unit_cost / totalPlanned) * totalActual : 0
        }));
        
        return NextResponse.json(enrichedData);
      }
      
      return NextResponse.json(data);
    }

    // Get subcontractors for an activity
    if (action === 'subcontractors' && activityId) {
      const { data, error } = await supabase
        .from('activity_subcontractors')
        .select('*')
        .eq('activity_id', activityId);
      
      if (error) throw error;
      
      // Fetch vendor master data
      const vendorIds = data?.map(s => s.subcontractor_id).filter(Boolean) || [];
      const { data: vendors } = await supabase
        .from('vendors')
        .select('id, vendor_code, vendor_name, trade, specialization')
        .in('id', vendorIds);
      
      const vendorsMap = new Map(vendors?.map(v => [v.id, v]));
      
      const { data: activity } = await supabase
        .from('activities')
        .select('code')
        .eq('id', activityId)
        .single();
      
      if (activity) {
        const { data: actuals } = await supabase
          .from('universal_journal')
          .select('company_amount, cost_elements!inner(cost_element_type)')
          .eq('activity_code', activity.code)
          .eq('cost_elements.cost_element_type', 'SUBCONTRACTOR');
        
        const totalActual = actuals?.reduce((sum, row) => sum + (row.company_amount || 0), 0) || 0;
        const totalPlanned = data?.reduce((sum, row) => sum + row.contract_value, 0) || 0;
        
        const enrichedData = data?.map(row => {
          const vendor = vendorsMap.get(row.subcontractor_id);
          return {
            ...row,
            vendor_code: vendor?.vendor_code,
            vendor_name: vendor?.vendor_name,
            actual_cost: totalPlanned > 0 ? (row.contract_value / totalPlanned) * totalActual : 0
          };
        });
        
        return NextResponse.json(enrichedData);
      }
      
      return NextResponse.json(data);
    }

    // Get activities
    let query = supabase
      .from('activities')
      .select('*, wbs_nodes(code, name)')
      .order('code');

    if (projectId) {
      query = query.eq('project_id', projectId);
    }

    const { data, error } = await query;

    if (error) throw error;

    return NextResponse.json({ activities: data });
  } catch (error) {
    console.error('Activities API error:', error);
    return NextResponse.json({ error: 'Failed to fetch activities' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const url = new URL(request.url);
    const action = url.searchParams.get('action');
    const supabase = await createServiceClient();

    // Attach materials to activity
    if (action === 'attach-materials') {
      const { activityId, materials } = await request.json();

      // Delete existing materials
      await supabase
        .from('activity_materials')
        .delete()
        .eq('activity_id' satisfies keyof ActivityMaterialsTable['Row'], activityId);

      // Insert new materials
      const { data, error } = await supabase
        .from('activity_materials')
        .insert(materials.map((m: any) => ({
          activity_id: activityId,
          material_id: m.material_id,
          required_quantity: m.required_quantity,
          unit_of_measure: m.unit_of_measure,
          unit_cost: m.unit_cost,
          priority_level: m.priority_level || 'normal',
          notes: m.notes,
          project_id: m.project_id
        })))
        .select();

      if (error) throw error;
      return NextResponse.json(data);
    }

    // Attach equipment to activity
    if (action === 'attach-equipment') {
      const { activityId, equipment } = await request.json();

      await supabase.from('activity_equipment').delete().eq('activity_id', activityId);

      const { data, error } = await supabase
        .from('activity_equipment')
        .insert(equipment.map((e: any) => ({
          activity_id: activityId,
          equipment_id: e.equipment_id,
          required_hours: e.required_hours,
          hourly_rate: e.hourly_rate,
          priority_level: e.priority_level || 'normal',
          notes: e.notes,
          project_id: e.project_id
        })))
        .select();

      if (error) throw error;
      return NextResponse.json(data);
    }

    // Attach manpower to activity
    if (action === 'attach-manpower') {
      const { activityId, manpower } = await request.json();

      await supabase.from('activity_manpower').delete().eq('activity_id', activityId);

      const { data, error } = await supabase
        .from('activity_manpower')
        .insert(manpower.map((m: any) => ({
          activity_id: activityId,
          employee_id: m.employee_id,
          role: m.role,
          required_hours: m.required_hours,
          hourly_rate: m.hourly_rate,
          priority_level: m.priority_level || 'normal',
          notes: m.notes,
          project_id: m.project_id
        })))
        .select();

      if (error) throw error;
      return NextResponse.json(data);
    }

    // Attach services to activity
    if (action === 'attach-services') {
      const { activityId, services } = await request.json();

      await supabase.from('activity_services').delete().eq('activity_id', activityId);

      if (services && services.length > 0) {
        const { data, error } = await supabase
          .from('activity_services')
          .insert(services.map((s: any) => ({
            activity_id: activityId,
            service_type: s.service_type,
            service_description: s.service_description,
            scheduled_date: s.scheduled_date,
            duration_hours: s.duration_hours,
            unit_cost: s.unit_cost,
            priority_level: s.priority_level || 'normal',
            project_id: s.project_id
          })))
          .select();

        if (error) throw error;
        return NextResponse.json(data);
      }
      return NextResponse.json([]);
    }

    // Attach subcontractors to activity
    if (action === 'attach-subcontractors') {
      const { activityId, subcontractors } = await request.json();

      await supabase.from('activity_subcontractors').delete().eq('activity_id', activityId);

      if (subcontractors && subcontractors.length > 0) {
        const { data, error } = await supabase
          .from('activity_subcontractors')
          .insert(subcontractors.map((s: any) => ({
            activity_id: activityId,
            subcontractor_id: s.subcontractor_id,
            trade: s.trade,
            scope_of_work: s.scope_of_work,
            crew_size: s.crew_size,
            contract_value: s.contract_value,
            priority_level: s.priority_level || 'normal',
            project_id: s.project_id
          })))
          .select();

        if (error) throw error;
        return NextResponse.json(data);
      }
      return NextResponse.json([]);
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 });
  } catch (error) {
    console.error('Activities API error:', error);
    return NextResponse.json({ error: 'Failed to process request' }, { status: 500 });
  }
}
