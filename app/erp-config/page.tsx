import ProtectedRoute from '../../components/auth/ProtectedRoute'
import ERPConfigurationPage from './ERPConfigurationPage'

export default function ERPConfigPage() {
  return (
    <ProtectedRoute allowedRoles={['Admin', 'Manager']}>
      <ERPConfigurationPage />
    </ProtectedRoute>
  )
}