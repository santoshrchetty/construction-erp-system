import ProtectedRoute from '../../components/auth/ProtectedRoute'
import ERPConfigFixed from '../../components/ERPConfigFixed'

export default function ERPConfigPage() {
  return (
    <ProtectedRoute allowedRoles={['Admin', 'Manager']}>
      <ERPConfigFixed />
    </ProtectedRoute>
  )
}