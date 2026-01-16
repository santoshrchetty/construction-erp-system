import { NextRequest } from 'next/server'
import { WBSService } from '@/domains/wbs/wbsServices'

const wbsService = new WBSService()

export async function handleWBS(action: string, request: NextRequest, method: string = 'GET') {
  try {
    const { searchParams } = new URL(request.url)
    const body = method === 'POST' || method === 'PUT' ? await request.json() : {}
    
    switch (action) {
      case 'nodes':
        if (method === 'GET') {
          const projectId = searchParams.get('projectId')
          if (!projectId) throw new Error('projectId required')
          return await wbsService.getWBSNodes(projectId)
        } else if (method === 'POST') {
          return await wbsService.createWBSNode(body)
        } else if (method === 'PUT') {
          return await wbsService.updateWBSNode(body.id, body)
        }
        break

      case 'activities':
        if (method === 'GET') {
          const projectId = searchParams.get('projectId')
          const wbsNodeId = searchParams.get('wbsNodeId')
          if (!projectId) throw new Error('projectId required')
          return await wbsService.getActivities(projectId, wbsNodeId || undefined)
        } else if (method === 'POST') {
          return await wbsService.createActivity(body)
        } else if (method === 'PUT') {
          return await wbsService.updateActivity(body.id, body)
        }
        break

      case 'tasks':
        if (method === 'GET') {
          const projectId = searchParams.get('projectId')
          const activityId = searchParams.get('activityId')
          if (!projectId) throw new Error('projectId required')
          return await wbsService.getTasks(projectId, activityId || undefined)
        } else if (method === 'POST') {
          return await wbsService.createTask(body)
        } else if (method === 'PUT') {
          return await wbsService.updateTask(body.id, body)
        }
        break

      case 'delete':
        const { type, id } = body
        if (type === 'node') {
          return await wbsService.deleteWBSNode(id)
        } else if (type === 'activity') {
          return await wbsService.deleteActivity(id)
        } else if (type === 'task') {
          return await wbsService.deleteTask(id)
        }
        break

      case 'vendors':
        return await wbsService.getVendors()

      default:
        return { action, message: `${action} functionality available` }
    }
  } catch (error) {
    console.error('WBS handler error:', error)
    throw error
  }
}