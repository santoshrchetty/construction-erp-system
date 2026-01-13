@echo off
echo Organizing markdown files...

REM Move root level docs to docs folder
move "ARCHITECTURE_DISCOVERY.md" "docs\"
move "conversation.md" "docs\archive\"
move "DEPLOYMENT_CHECKLIST.md" "docs\"
move "DEVELOPMENT_STANDARDS.md" "docs\"
move "Finance_Engine.md" "docs\"
move "IMPLEMENTATION_ROADMAP.md" "docs\"
move "IMPLEMENTATION_STATUS.md" "docs\"
move "project-numbering-wbs-examples.md" "docs\"
move "q-dev-chat-2026-01-04.md" "docs\archive\"
move "reference_conversation.md" "docs\archive\"
move "RESTORE_SYSTEM.md" "docs\"
move "test_cement_opc_83_instructions.md" "docs\archive\"
move "test_existing_cement_opc_83.md" "docs\archive\"
move "test_maintain_material_master_checklist.md" "docs\archive\"

echo Markdown files organized!