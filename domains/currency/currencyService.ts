import { createServiceClient } from '@/lib/supabase'

export interface ExchangeRate {
  from_currency: string
  to_currency: string
  exchange_rate: number
  rate_date: string
  rate_type: string
}

export interface PurchaseOrderPayload {
  po_number: string
  vendor_code: string
  company_code: string
  plant_code?: string
  po_date: string
  document_currency: string
  total_amount: number
  items: PurchaseOrderItemPayload[]
}

export interface PurchaseOrderItemPayload {
  line_number: number
  material_code: string
  quantity: number
  unit: string
  unit_price: number
}

export async function getExchangeRate(fromCurrency: string, toCurrency: string, rateDate?: string): Promise<number> {
  if (fromCurrency === toCurrency) return 1.0
  
  const supabase = createServiceClient()
  const targetDate = rateDate || new Date().toISOString().split('T')[0]
  
  const { data, error } = await supabase
    .from('exchange_rates')
    .select('exchange_rate')
    .eq('from_currency', fromCurrency)
    .eq('to_currency', toCurrency)
    .eq('rate_date', targetDate)
    .eq('is_active', true)
    .single()
  
  if (error || !data) {
    throw new Error(`Exchange rate not found for ${fromCurrency} to ${toCurrency} on ${targetDate}`)
  }
  
  return Number(data.exchange_rate)
}

export async function convertCurrency(amount: number, fromCurrency: string, toCurrency: string, rateDate?: string): Promise<number> {
  const rate = await getExchangeRate(fromCurrency, toCurrency, rateDate)
  return amount * rate
}

export async function createPurchaseOrder(payload: PurchaseOrderPayload, userId: string) {
  const supabase = createServiceClient()
  
  // Get company currency
  const { data: companyData } = await supabase
    .from('company_codes')
    .select('currency')
    .eq('company_code', payload.company_code)
    .single()
  
  if (!companyData) throw new Error('Company not found')
  
  const companyCurrency = companyData.currency
  const exchangeRate = await getExchangeRate(payload.document_currency, companyCurrency, payload.po_date)
  const companyAmount = await convertCurrency(payload.total_amount, payload.document_currency, companyCurrency, payload.po_date)
  
  // Create purchase order
  const { data: poData, error: poError } = await supabase
    .from('purchase_orders')
    .insert({
      po_number: payload.po_number,
      vendor_code: payload.vendor_code,
      company_code: payload.company_code,
      plant_code: payload.plant_code,
      po_date: payload.po_date,
      document_currency: payload.document_currency,
      total_amount: payload.total_amount,
      company_currency: companyCurrency,
      company_amount: companyAmount,
      exchange_rate: exchangeRate,
      rate_date: payload.po_date,
      created_by: userId
    })
    .select()
    .single()
  
  if (poError) throw poError
  
  // Create purchase order items
  const itemsData = await Promise.all(
    payload.items.map(async (item) => {
      const companyUnitPrice = await convertCurrency(item.unit_price, payload.document_currency, companyCurrency, payload.po_date)
      const lineAmount = item.quantity * item.unit_price
      const companyLineAmount = item.quantity * companyUnitPrice
      
      return {
        po_id: poData.id,
        line_number: item.line_number,
        material_code: item.material_code,
        quantity: item.quantity,
        unit: item.unit,
        unit_price: item.unit_price,
        line_amount: lineAmount,
        company_unit_price: companyUnitPrice,
        company_line_amount: companyLineAmount
      }
    })
  )
  
  const { error: itemsError } = await supabase
    .from('purchase_order_items')
    .insert(itemsData)
  
  if (itemsError) throw itemsError
  
  return poData
}

export async function createMaterialReceipt(poId: string, poItemId: string, receiptData: any, userId: string) {
  const supabase = createServiceClient()
  
  // Get PO and item details
  const { data: poItem } = await supabase
    .from('purchase_order_items')
    .select(`
      *,
      purchase_orders!inner (
        document_currency,
        company_currency,
        po_date
      )
    `)
    .eq('id', poItemId)
    .single()
  
  if (!poItem) throw new Error('Purchase order item not found')
  
  const po = poItem.purchase_orders
  const receiptDate = receiptData.receipt_date || new Date().toISOString().split('T')[0]
  
  // Get current exchange rate for receipt date
  const currentRate = await getExchangeRate(po.document_currency, po.company_currency, receiptDate)
  
  // Calculate values
  const unitCost = poItem.unit_price
  const totalValue = receiptData.quantity_received * unitCost
  const companyUnitCost = unitCost * currentRate
  const companyTotalValue = receiptData.quantity_received * companyUnitCost
  
  const { data, error } = await supabase
    .from('material_receipts')
    .insert({
      receipt_number: receiptData.receipt_number,
      po_id: poId,
      po_item_id: poItemId,
      material_code: poItem.material_code,
      plant_code: receiptData.plant_code,
      storage_location: receiptData.storage_location,
      receipt_date: receiptDate,
      quantity_received: receiptData.quantity_received,
      document_currency: po.document_currency,
      unit_cost: unitCost,
      total_value: totalValue,
      company_currency: po.company_currency,
      company_unit_cost: companyUnitCost,
      company_total_value: companyTotalValue,
      exchange_rate: currentRate,
      rate_date: receiptDate,
      created_by: userId
    })
    .select()
    .single()
  
  if (error) throw error
  
  // Update stock balances with company currency values
  await updateStockBalance(
    poItem.material_code,
    receiptData.plant_code,
    receiptData.storage_location,
    receiptData.quantity_received,
    companyTotalValue
  )
  
  return data
}

async function updateStockBalance(materialCode: string, plantCode: string, storageLocation: string, quantity: number, value: number) {
  const supabase = createServiceClient()
  
  // This would update the stock_balances table
  // Implementation depends on existing stock balance logic
  const { error } = await supabase.rpc('update_stock_balance', {
    p_material_code: materialCode,
    p_plant_code: plantCode,
    p_storage_location: storageLocation,
    p_quantity_change: quantity,
    p_value_change: value
  })
  
  if (error) console.error('Stock balance update failed:', error)
}