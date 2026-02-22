-- Hybrid Workflow Model: Header-level workflow with line-level overrides
-- This approach maintains performance while allowing flexibility

-- Keep workflow at header level by default
ALTER TABLE material_requests 
ADD COLUMN IF NOT EXISTS primary_workflow_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS workflow_strategy VARCHAR(20) DEFAULT 'HEADER' CHECK (workflow_strategy IN ('HEADER', 'LINE_ITEM', 'MIXED'));

-- Line-level workflow only when needed
ALTER TABLE material_request_items
ADD COLUMN IF NOT EXISTS override_workflow_id VARCHAR(50), -- Only populated when different from header
ADD COLUMN IF NOT EXISTS requires_separate_approval BOOLEAN DEFAULT FALSE;

-- Workflow assignment logic
CREATE OR REPLACE FUNCTION determine_workflow_strategy(
  mr_id UUID
) RETURNS VARCHAR(20) AS $$
DECLARE
  mixed_assignments BOOLEAN;
  high_value_items BOOLEAN;
BEGIN
  -- Check if MR has mixed account assignments
  SELECT COUNT(DISTINCT account_assignment_category) > 1 
  INTO mixed_assignments
  FROM material_request_items 
  WHERE material_request_id = mr_id;
  
  -- Check if any line exceeds threshold
  SELECT EXISTS(SELECT 1 FROM material_request_items 
                WHERE material_request_id = mr_id 
                AND total_line_value > 5000)
  INTO high_value_items;
  
  -- Return strategy
  IF mixed_assignments OR high_value_items THEN
    RETURN 'MIXED';
  ELSE
    RETURN 'HEADER';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Performance optimization indexes
CREATE INDEX IF NOT EXISTS idx_mr_workflow_strategy ON material_requests(workflow_strategy);
CREATE INDEX IF NOT EXISTS idx_mr_items_separate_approval ON material_request_items(requires_separate_approval) WHERE requires_separate_approval = TRUE;