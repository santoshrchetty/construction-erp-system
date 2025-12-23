import ProtectedRoute from '../../components/auth/ProtectedRoute'
import SAPOrgTreeCRUD from '../../components/SAPOrgTreeCRUD'

export default function SAPConfigPage() {
  return (
    <ProtectedRoute allowedRoles={['Admin', 'Manager']}>
      <SAPOrgTreeCRUD />
    </ProtectedRoute>
  )
}