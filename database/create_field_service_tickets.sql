-- Create field_service_tickets table
CREATE TABLE IF NOT EXISTS public.field_service_tickets (
  ticket_id UUID NOT NULL DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  facility_id UUID,
  equipment_id UUID,
  assigned_external_org_id UUID,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  reported_by UUID,
  reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  assigned_at TIMESTAMP WITH TIME ZONE,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolution_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT field_service_tickets_pkey PRIMARY KEY (ticket_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tickets_tenant ON field_service_tickets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tickets_facility ON field_service_tickets(facility_id);
CREATE INDEX IF NOT EXISTS idx_tickets_equipment ON field_service_tickets(equipment_id);
CREATE INDEX IF NOT EXISTS idx_tickets_org ON field_service_tickets(assigned_external_org_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON field_service_tickets(status);

-- Trigger
CREATE TRIGGER update_tickets_updated_at 
  BEFORE UPDATE ON field_service_tickets 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();
