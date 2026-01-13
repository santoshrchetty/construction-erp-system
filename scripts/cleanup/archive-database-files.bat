@echo off
echo Moving database files to archive...

move "database\check_*.sql" "database\archive\"
move "database\test_*.sql" "database\archive\"
move "database\debug_*.sql" "database\archive\"
move "database\fix_*.sql" "database\archive\"
move "database\verify_*.sql" "database\archive\"
move "database\simple_*.sql" "database\archive\"
move "database\quick_*.sql" "database\archive\"
move "database\run_*.sql" "database\archive\"
move "database\clean_*.sql" "database\archive\"
move "database\insert_test_*.sql" "database\archive\"
move "database\FIX_*.sql" "database\archive\"
move "database\TEST_*.sql" "database\archive\"

echo Archive complete!