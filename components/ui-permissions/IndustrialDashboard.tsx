'use client'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Settings, Users, Workflow } from 'lucide-react'

export function IndustrialDashboard() {
  const router = useRouter()

  const tiles = [
    {
      title: 'User Management',
      description: 'Manage users, roles, and permissions',
      icon: Users,
      path: '/admin/users'
    },
    {
      title: 'Workflow Configuration',
      description: 'Configure workflow definitions and steps',
      icon: Workflow,
      path: '/admin/workflows'
    },
    {
      title: 'System Settings',
      description: 'Configure system-wide settings',
      icon: Settings,
      path: '/admin/settings'
    }
  ]

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-8">Administration</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {tiles.map((tile) => {
          const Icon = tile.icon
          return (
            <Card 
              key={tile.path}
              className="cursor-pointer hover:shadow-lg transition-shadow"
              onClick={() => router.push(tile.path)}
            >
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Icon className="h-5 w-5" />
                  {tile.title}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-600">{tile.description}</p>
              </CardContent>
            </Card>
          )
        })}
      </div>
    </div>
  )
}
