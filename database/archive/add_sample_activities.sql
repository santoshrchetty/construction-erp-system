                                                    -- Add sample activities data for testing
                                                    -- First create a simple project and WBS if they don't exist

                                                    DO $$
                                                    DECLARE
                                                        project_uuid UUID;
                                                        wbs_foundation UUID;
                                                    BEGIN
                                                        -- Create or get a sample project
                                                        INSERT INTO projects (name, code, project_type, status, start_date, planned_end_date, budget)
                                                        VALUES ('Sample Construction Project', 'PROJ-2024-001', 'commercial', 'active', '2024-01-01', '2024-12-31', 1000000)
                                                        ON CONFLICT (code) DO NOTHING;
                                                        
                                                        SELECT id INTO project_uuid FROM projects WHERE code = 'PROJ-2024-001';
                                                        
                                                        -- Create or get WBS node
                                                        INSERT INTO wbs_nodes (project_id, code, name, node_type, level, sequence_order)
                                                        VALUES (project_uuid, 'WBS-01', 'Foundation Phase', 'phase', 1, 1)
                                                        ON CONFLICT (project_id, code) DO NOTHING;
                                                        
                                                        SELECT id INTO wbs_foundation FROM wbs_nodes WHERE project_id = project_uuid AND code = 'WBS-01';
                                                        
                                                        -- Insert sample activities
                                                        INSERT INTO activities (
                                                            project_id, wbs_node_id, code, name, description,
                                                            planned_start_date, planned_end_date, duration_days,
                                                            planned_hours, budget_amount, progress_percentage, status
                                                        ) VALUES
                                                        (project_uuid, wbs_foundation, 'ACT-001', 'Site Survey', 'Complete topographical survey and soil investigation', 
                                                        '2024-01-15', '2024-01-25', 8, 80, 25000, 100, 'completed'),
                                                        
                                                        (project_uuid, wbs_foundation, 'ACT-002', 'Site Clearing', 'Clear vegetation and prepare site for construction',
                                                        '2024-01-26', '2024-02-05', 7, 120, 75000, 75, 'in_progress')
                                                        
                                                        ON CONFLICT (project_id, code) DO NOTHING;
                                                        
                                                    END $$;