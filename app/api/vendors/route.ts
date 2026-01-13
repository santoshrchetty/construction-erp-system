import { NextRequest, NextResponse } from 'next/server';
import { poServices } from '../../../domains/purchase-orders/poServices';

export async function GET() {
  try {
    const vendors = await poServices.getVendors();
    return NextResponse.json(vendors);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch vendors' }, { status: 500 });
  }
}