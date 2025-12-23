import ProtectedRoute from '../../components/auth/ProtectedRoute'
import MaterialMaster from '../../components/MaterialMaster'

export default function MaterialsPage() {
  return (
    <ProtectedRoute allowedRoles={['Admin', 'Manager', 'Storekeeper']}>
      <MaterialMaster />
    </ProtectedRoute>
  )
}