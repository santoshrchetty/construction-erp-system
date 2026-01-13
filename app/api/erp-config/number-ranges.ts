import { NextRequest, NextResponse } from 'next/server';
import { NumberRangeService } from '../../../domains/finance/NumberRangeService';
import { supabase } from '../../../lib/supabase';

const numberRangeService = new NumberRangeService();

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const action = searchParams.get('action');
    const companyCode = searchParams.get('company_code');
    
    switch (action) {
      case 'number-ranges':
        const ranges = await numberRangeService.getAllNumberRanges(companyCode || undefined);
        return NextResponse.json({ success: true, data: ranges });
        
      case 'alerts':
        const alerts = await numberRangeService.getNumberRangeAlerts(companyCode || undefined);
        return NextResponse.json({ success: true, data: alerts });
        
      case 'stats':
        const { data: stats, error: statsError } = await supabase
          .rpc('get_number_range_statistics', { p_company_code: companyCode });
        if (statsError) throw statsError;
        return NextResponse.json({ success: true, data: stats });
        
      case 'ranges':
        const { data: rangeData, error: rangeError } = await supabase
          .from('document_number_ranges')
          .select('*')
          .eq('company_code', companyCode)
          .order('document_type');
        if (rangeError) throw rangeError;
        return NextResponse.json({ success: true, data: rangeData });
        
      default:
        return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 });
    }
  } catch (error) {
    console.error('Error in number range API:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const { action, companyCode, documentType, ...data } = await request.json();
    
    switch (action) {
      case 'create':
        const newRange = await numberRangeService.createNumberRange(data);
        return NextResponse.json({ success: true, data: newRange });
        
      case 'update':
        const updatedRange = await numberRangeService.updateNumberRange(data.id, data);
        return NextResponse.json({ success: true, data: updatedRange });
        
      case 'reset':
        const resetRange = await numberRangeService.resetNumberRange(data.id, data.newCurrentNumber, data.userId);
        return NextResponse.json({ success: true, data: resetRange });
        
      case 'get_next_number':
        const { data: nextNumber, error: nextError } = await supabase
          .rpc('get_next_number', { 
            p_company_code: companyCode, 
            p_document_type: documentType 
          });
        if (nextError) throw nextError;
        return NextResponse.json({ success: true, data: { number: nextNumber } });
        
      case 'update_range':
        const { error: updateError } = await supabase
          .from('document_number_ranges')
          .update(data)
          .eq('company_code', companyCode)
          .eq('document_type', documentType);
        if (updateError) throw updateError;
        return NextResponse.json({ success: true });
        
      case 'create_range':
        const { error: createError } = await supabase
          .from('document_number_ranges')
          .insert({ company_code: companyCode, document_type: documentType, ...data });
        if (createError) throw createError;
        return NextResponse.json({ success: true });
        
      case 'configure_company':
        const { error: configError } = await supabase
          .rpc('configure_company_number_ranges', { p_company_code: companyCode });
        if (configError) throw configError;
        return NextResponse.json({ success: true });
        
      default:
        return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 });
    }
  } catch (error) {
    console.error('Error in number range API:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}