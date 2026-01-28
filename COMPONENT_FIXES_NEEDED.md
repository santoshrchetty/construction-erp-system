# Remaining Changes for UnifiedMaterialRequestComponent.tsx

## Lines to fix (change IDs to codes):

Line 739-742: account_assignment onChange
```typescript
// CHANGE FROM:
project_id: '',
wbs_element_id: '',
activity_id: '',
cost_center_id: '',

// TO:
project_code: '',
wbs_element: '',
activity_code: '',
cost_center: '',
```

Line 765-766: Project dropdown
```typescript
// CHANGE FROM:
value={formData.project_id}
onChange={(e) => setFormData(prev => ({ ...prev, project_id: e.target.value, wbs_element_id: '', activity_id: '' }))}
<option key={p.id} value={p.id}>

// TO:
value={formData.project_code}
onChange={(e) => setFormData(prev => ({ ...prev, project_code: e.target.value, wbs_element: '', activity_code: '' }))}
<option key={p.id} value={p.code}>
```

Line 779-785: WBS dropdown
```typescript
// CHANGE FROM:
{!formData.project_id && ...}
disabled={!formData.project_id || loadingWBS}
value={formData.wbs_element_id}
onChange={(e) => setFormData(prev => ({ ...prev, wbs_element_id: e.target.value, activity_id: '' }))}
<option key={w.id} value={w.id}>

// TO:
{!formData.project_code && ...}
disabled={!formData.project_code || loadingWBS}
value={formData.wbs_element}
onChange={(e) => setFormData(prev => ({ ...prev, wbs_element: e.target.value, activity_code: '' }))}
<option key={w.id} value={w.wbs_element}>
```

Line 798-804: Activity dropdown
```typescript
// CHANGE FROM:
{!formData.wbs_element_id && ...}
disabled={!formData.wbs_element_id || loadingActivities}
value={formData.activity_id}
onChange={(e) => setFormData(prev => ({ ...prev, activity_id: e.target.value }))}
<option key={a.id} value={a.id}>

// TO:
{!formData.wbs_element && ...}
disabled={!formData.wbs_element || loadingActivities}
value={formData.activity_code}
onChange={(e) => setFormData(prev => ({ ...prev, activity_code: e.target.value }))}
<option key={a.id} value={a.code}>
```

Line 826-827: Cost Center dropdown
```typescript
// CHANGE FROM:
value={formData.cost_center_id}
onChange={(e) => setFormData(prev => ({ ...prev, cost_center_id: e.target.value }))}
<option key={cc.id} value={cc.id}>

// TO:
value={formData.cost_center}
onChange={(e) => setFormData(prev => ({ ...prev, cost_center: e.target.value }))}
<option key={cc.id} value={cc.cost_center_code}>
```

Line 868, 876, 917: Material section
```typescript
// CHANGE FROM:
disabled={!formData.plant_id}
{!formData.plant_id && ...}
disabled={!formData.plant_id}

// TO:
disabled={!formData.plant_code}
{!formData.plant_code && ...}
disabled={!formData.plant_code}
```

## Run this SQL first (already done):
```sql
ALTER TABLE material_requests ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(50);
CREATE INDEX IF NOT EXISTS idx_material_requests_wbs_element ON material_requests(wbs_element);
```
