import { NextRequest } from 'next/server'
import { ActivityService } from '@/domains/activities/activityServices'

const activityService = new ActivityService()

export async function handleActivities(action: string, request: NextRequest, method: string = 'GET') {
  try {
    if (method === 'GET') {
      const { searchParams } = new URL(request.url)
      const wbsCode = searchParams.get('wbsCode')
      const projectId = searchParams.get('projectId')
      
      if (wbsCode) {
        const data = await activityService.getActivitiesByWBSCode(wbsCode)
        return { success: true, data }
      }
      
      if (projectId) {
        const data = await activityService.getActivitiesByProject(projectId)
        return { success: true, data }
      }
      
      return { success: true, data: [] }
    }

    return { success: false, error: 'Method not supported' }
  } catch (error) {
    console.error('Activities handler error:', error)
    throw error
  }
}