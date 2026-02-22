# Fiori Component Architecture - Quick Reference

## 📏 Line Count Limits

| File Type | Max Lines | Purpose |
|-----------|-----------|---------|
| Main ObjectPage | **150** | Orchestration only |
| Section Component | **100** | Focused UI area |
| Items Section | **200** | Complex table allowed |
| Custom Hook | **250** | Business logic |
| Utility | **100** | Pure functions |

## 📁 File Structure Template

```
{Entity}ObjectPage/
├── {Entity}ObjectPage.tsx              (120 lines) ⭐
├── sections/
│   ├── {Entity}HeaderSection.tsx       (60-100 lines)
│   ├── {Entity}GeneralSection.tsx      (60-100 lines)
│   └── {Entity}ItemsSection.tsx        (150-200 lines)
├── components/
│   └── {Reusable}Component.tsx         (60-100 lines)
├── hooks/
│   ├── use{Entity}FormData.ts          (150-250 lines)
│   └── use{Entity}Actions.ts           (60-100 lines)
└── dialogs/
    └── {Entity}PreviewDialog.tsx       (80-120 lines)
```

## 🎯 Main Component Template

```typescript
// {Entity}ObjectPage.tsx (120 lines max)
export default function {Entity}ObjectPage() {
  // 1. Hooks (5-10 lines)
  const { formData, masterData, updateField } = use{Entity}FormData()
  const { save, submit, preview } = use{Entity}Actions(formData)
  
  // 2. UI State (5-10 lines)
  const [expandedSections, setExpandedSections] = useState({...})
  
  // 3. Render (80-100 lines)
  return (
    <div className="object-page">
      <ObjectPageHeader title={...} />
      
      <div className="object-page-content">
        <ObjectPageSection title="..." expanded={...}>
          <{Entity}Section data={...} onChange={...} />
        </ObjectPageSection>
      </div>
      
      <ObjectPageFooter>
        <Button onClick={save}>Save</Button>
        <Button onClick={submit}>Submit</Button>
      </ObjectPageFooter>
    </div>
  )
}
```

## 🧩 Section Component Template

```typescript
// sections/{Entity}Section.tsx (60-100 lines max)
interface {Entity}SectionProps {
  data: FormData
  masterData: MasterData
  onChange: (field: string, value: any) => void
  readOnly?: boolean
}

export default function {Entity}Section({
  data,
  masterData,
  onChange,
  readOnly = false
}: {Entity}SectionProps) {
  return (
    <div className="form-section">
      <div className="form-grid grid-cols-3 gap-4">
        <FormField label="..." required>
          <Select
            value={data.field}
            onChange={(e) => onChange('field', e.target.value)}
            disabled={readOnly}
          >
            {/* Options */}
          </Select>
        </FormField>
      </div>
    </div>
  )
}
```

## 🪝 Custom Hook Template

```typescript
// hooks/use{Entity}FormData.ts (150-250 lines max)
export function use{Entity}FormData() {
  // 1. State (20 lines)
  const [formData, setFormData] = useState(initialState)
  const [masterData, setMasterData] = useState({...})
  
  // 2. Load on mount (30 lines)
  useEffect(() => {
    loadInitialData()
  }, [])
  
  // 3. Load dependent data (40 lines)
  useEffect(() => {
    if (formData.field) loadDependentData()
  }, [formData.field])
  
  // 4. Loading functions (100 lines)
  const loadInitialData = async () => {...}
  const loadDependentData = async () => {...}
  
  // 5. Update functions (30 lines)
  const updateField = (field, value) => {...}
  const updateItem = (index, field, value) => {...}
  
  // 6. Return (10 lines)
  return { formData, masterData, updateField, updateItem }
}
```

## ✅ Pre-Implementation Checklist

### Planning
- [ ] Identify 3-5 main sections
- [ ] List all master data needed
- [ ] List all actions (save, submit, etc.)
- [ ] Identify reusable components

### Implementation
- [ ] Main ObjectPage (120-150 lines)
- [ ] Section components (60-100 lines each)
- [ ] Data hook (150-250 lines)
- [ ] Actions hook (60-100 lines)
- [ ] Reusable components (60-100 lines)

### Quality Check
- [ ] Main file < 150 lines?
- [ ] Sections < 100 lines?
- [ ] Hooks < 250 lines?
- [ ] No business logic in UI?
- [ ] All sections collapsible?
- [ ] Props interfaces defined?

## 🚫 Anti-Patterns

| ❌ DON'T | ✅ DO |
|---------|-------|
| 1,000+ line components | Split into 8-15 files |
| Business logic in UI | Move to custom hooks |
| Data loading in sections | Load in hooks, pass via props |
| Monolithic files | Focused, single-responsibility files |

## 📊 Expected Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Main File | 1,161 lines | 120 lines | 90% ↓ |
| Largest File | 1,161 lines | 200 lines | 83% ↓ |
| Maintainability | Poor | Excellent | 90% ↑ |
| Testability | Hard | Easy | 95% ↑ |
| Reusability | None | High | 100% ↑ |

## 🎨 Fiori Principles

1. **Role-Based** - Design for specific user tasks
2. **Responsive** - Works on desktop, tablet, mobile
3. **Simple** - Focus on essential tasks
4. **Coherent** - Consistent UX across all apps
5. **Delightful** - Modern, intuitive interface

## 📚 Key Concepts

### Object Page Layout
- Sticky header with title and status
- Collapsible sections for header data
- Always-expanded items section
- Sticky footer with actions

### Section Pattern
- Each section is independent
- Can be collapsed/expanded
- Receives data via props
- Emits changes via callbacks

### Hook Pattern
- All data loading in hooks
- All actions in hooks
- UI components stay pure
- Easy to test and reuse

## 🔗 Related Documents

- Full Standard: `FIORI_COMPONENT_ARCHITECTURE_STANDARD.md`
- Implementation Example: `MaterialRequestObjectPage.tsx`
- Migration Guide: See "Migration Guide" section in full standard

---

**Quick Tip:** When in doubt, ask: "Is this file over 150 lines?" If yes, split it!
