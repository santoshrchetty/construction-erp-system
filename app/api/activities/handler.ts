import { NextRequest } from 'next/server'
import { ActivityService } from '@/domains/activities/activityServices'

const activityService = new ActivityService()

export async function handleActivities(action: string, request: NextRequest, method: string = 'GET') {
  try {
    if (method === 'GET') {
      const { searchParams } = new URL(request.url)
      const wbsCode = searchParams.get('wbsCode')
      const wbsElement = searchParams.get('wbsElement')
      const projectCode = searchParams.get('projectCode')
      
      // Handle wbsElement parameter (used by Material Request component)
      if (wbsElement) {
        const data = await activityService.getActivitiesByWBSCode(wbsElement)
        return { success: true, data }
      }
      
      if (wbsCode) {
        const data = await activityService.getActivitiesByWBSCode(wbsCode)
        return { success: true, data }
      }
      
      if (projectCode) {
        const data = await activityService.getActivitiesByProject(projectCode)
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