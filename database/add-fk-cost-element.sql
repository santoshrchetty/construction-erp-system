-- Check for any cost_elements in universal_journal that don't exist in cost_elements table
SELECT DISTINCT uj.cost_element
FROM universal_journal uj
LEFT JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE ce.cost_element IS NULL
  AND uj.cost_element IS NOT NULL;

-- If above returns no rows, safe to add FK
ALTER TABLE universal_journal 
ADD CONSTRAINT fk_uj_cost_element 
FOREIGN KEY (cost_element) REFERENCES cost_elements(cost_element);

-- Verify constraint added
SELECT conname, contype, pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'universal_journal'::regclass
  AND conname = 'fk_uj_cost_element';
