import { NextRequest, NextResponse } from 'next/server'
import { handleActivities } from './handler'
import { createClient } from '@supabase/supabase-js'

const createServiceClient = () => {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )
}

export async function GET(request: NextRequest) {
  try {
    const result = await handleActivities('get', request, 'GET')
    return NextResponse.json(result)
  } catch (error) {
    console.error('Activities API error:', error)
    return NextResponse.json({ error: 'Failed to fetch activities' }, { status: 500 })
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
        .eq('activity_id', activityId);

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
