import type { Metadata } from 'next'
import './globals.css'
import { AuthProvider } from '@/lib/contexts/AuthContext'
import AuthFlowDebugger from '@/components/debug/AuthFlowDebugger'

export const metadata: Metadata = {
  title: 'Construction Management SaaS',
  description: 'Complete project management solution for construction companies',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50">
        <AuthProvider>
          <main>{children}</main>
        </AuthProvider>
      </body>
    </html>
  )
}