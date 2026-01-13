-- RLS Policies for ERP Configuration Tables

-- Enable RLS on all ERP config tables
ALTER TABLE material_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE uom_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE valuation_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE movement_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_determination ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read ERP config data
CREATE POLICY "Allow authenticated users to read material_groups" ON material_groups FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read vendor_categories" ON vendor_categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read payment_terms" ON payment_terms FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read uom_groups" ON uom_groups FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read material_status" ON material_status FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read valuation_classes" ON valuation_classes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read movement_types" ON movement_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read account_keys" ON account_keys FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated users to read account_determination" ON account_determination FOR SELECT TO authenticated USING (true);

-- Allow admin users to modify ERP config data
CREATE POLICY "Allow admin users to modify material_groups" ON material_groups FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify vendor_categories" ON vendor_categories FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify payment_terms" ON payment_terms FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify uom_groups" ON uom_groups FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify material_status" ON material_status FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify valuation_classes" ON valuation_classes FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify movement_types" ON movement_types FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify account_keys" ON account_keys FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);

CREATE POLICY "Allow admin users to modify account_determination" ON account_determination FOR ALL TO authenticated USING (
  EXISTS (SELECT 1 FROM users u JOIN user_roles ur ON u.id = ur.user_id JOIN roles r ON ur.role_id = r.id 
          WHERE u.id = auth.uid() AND r.name IN ('Admin', 'Manager'))
);