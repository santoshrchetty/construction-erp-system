import type { Metadata, Viewport } from 'next'
import './globals.css'
import { AuthProvider } from '@/lib/contexts/AuthContext'
import { PermissionProvider } from '@/components/shared/permissions/PermissionContext'
import { TenantProvider } from '@/contexts/TenantProvider'

export const metadata: Metadata = {
  title: 'Construction Management SaaS',
  description: 'Complete project management solution for construction companies',
  keywords: 'construction, project management, ERP, materials, procurement',
  robots: process.env.NODE_ENV === 'production' ? 'index, follow' : 'noindex, nofollow',
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50">
        <TenantProvider>
          <AuthProvider>
            <PermissionProvider>
              <main>{children}</main>
            </PermissionProvider>
          </AuthProvider>
        </TenantProvider>
      </body>
    </html>
  )
}