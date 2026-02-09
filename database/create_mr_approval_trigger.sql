-- Database Trigger: Auto-create workflow when MR is submitted

-- 1. Create function to trigger workflow
CREATE OR REPLACE FUNCTION trigger_mr_approval_workflow()
RETURNS TRIGGER AS $$
DECLARE
  v_workflow_id UUID;
BEGIN
  -- Only trigger if status changed to SUBMITTED
  IF NEW.status = 'SUBMITTED' AND (OLD.status IS NULL OR OLD.status != 'SUBMITTED') THEN
    
    -- Get workflow ID for Material Requests
    SELECT id INTO v_workflow_id
    FROM workflow_definitions
    WHERE object_type = 'MATERIAL_REQUEST'
    AND workflow_code = 'MR_STD_APPROVAL'
    AND is_active = true
    LIMIT 1;
    
    IF v_workflow_id IS NOT NULL THEN
      -- Create workflow instance
      INSERT INTO workflow_instances (
        workflow_id,
        object_type,
        object_id,
        requester_id,
        current_step_sequence,
        status,
        context_data
      ) VALUES (
        v_workflow_id,
        'MATERIAL_REQUEST',
        NEW.id::text,
        NEW.created_by::text,
        1,
        'ACTIVE',
        jsonb_build_object(
          'request_number', NEW.request_number,
          'request_type', NEW.request_type,
          'company_code', NEW.company_code,
          'plant_code', NEW.plant_code,
          'project_code', NEW.project_code,
          'total_amount', NEW.total_amount
        )
      );
      
      -- Update MR status to IN_APPROVAL
      NEW.status := 'IN_APPROVAL';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Create trigger on material_requests table
DROP TRIGGER IF EXISTS trg_mr_approval_workflow ON material_requests;

CREATE TRIGGER trg_mr_approval_workflow
  BEFORE UPDATE ON material_requests
  FOR EACH ROW
  EXECUTE FUNCTION trigger_mr_approval_workflow();

-- 3. Test: Update existing DRAFT MRs to SUBMITTED
UPDATE material_requests
SET status = 'SUBMITTED'
WHERE status = 'DRAFT'
AND request_type = 'MATERIAL_REQ';

-- 4. Verify workflow instances created
SELECT 
  wi.id,
  wi.object_id,
  wi.status,
  wi.current_step_sequence,
  mr.request_number,
  mr.status as mr_status
FROM workflow_instances wi
JOIN material_requests mr ON mr.id::text = wi.object_id
WHERE wi.object_type = 'MATERIAL_REQUEST'
ORDER BY wi.created_at DESC;
