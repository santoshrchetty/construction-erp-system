import { NextRequest } from 'next/server'
import * as wbsServices from '@/domains/wbs/wbsServices'

export async function handleWBS(action: string, request: NextRequest, method: string = 'GET') {
  try {
    const body = method === 'POST' || method === 'PUT' ? await request.json() : {}
    
    switch (action) {
      case 'projects':
        const { companyCode } = body.companyCode ? body : { companyCode: 'C001' }
        return await wbsServices.getProjects(companyCode)

      case 'elements':
        const { projectCode, companyCode: elementsCompany } = body
        return await wbsServices.getWBSElements(projectCode, elementsCompany)

      case 'nodes':
        if (method === 'GET') {
          return await wbsServices.getWBSNodes(body.projectId)
        } else if (method === 'POST') {
          return await wbsServices.createWBSNode(body)
        } else if (method === 'PUT') {
          return await wbsServices.updateWBSNode(body.id, body)
        }
        break

      case 'activities':
        if (method === 'GET') {
          return await wbsServices.getActivities(body.projectId)
        } else if (method === 'POST') {
          return await wbsServices.createActivity(body)
        } else if (method === 'PUT') {
          return await wbsServices.updateActivity(body.id, body)
        }
        break

      case 'tasks':
        if (method === 'GET') {
          return await wbsServices.getTasks(body.projectId)
        } else if (method === 'POST') {
          return await wbsServices.createTask(body)
        } else if (method === 'PUT') {
          return await wbsServices.updateTask(body.id, body)
        }
        break

      case 'delete':
        const { type, id } = body
        if (type === 'node') {
          return await wbsServices.deleteWBSNode(id)
        } else if (type === 'activity') {
          return await wbsServices.deleteActivity(id)
        } else if (type === 'task') {
          return await wbsServices.deleteTask(id)
        }
        break

      case 'vendors':
        return await wbsServices.getVendors()

      default:
        return { action, message: `${action} functionality available` }
    }
  } catch (error) {
    console.error('WBS handler error:', error)
    throw error
  }
}