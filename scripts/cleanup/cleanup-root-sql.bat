@echo off
echo Moving root SQL files to database archive...

move "check-*.sql" "database\archive\"
move "test-*.sql" "database\archive\"
move "debug-*.sql" "database\archive\"
move "fix-*.sql" "database\archive\"
move "verify-*.sql" "database\archive\"
move "create-*.sql" "database\archive\"
move "add-*.sql" "database\archive\"
move "step*.sql" "database\archive\"

echo Root cleanup complete!