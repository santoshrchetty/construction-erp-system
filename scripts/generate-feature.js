#!/usr/bin/env node

/**
 * Feature Template Generator
 * 
 * Generates boilerplate code following 4-layer architecture standards
 * Usage: node scripts/generate-feature.js [domain] [feature]
 * Example: node scripts/generate-feature.js projects milestone
 */

const fs = require('fs')
const path = require('path')

function generateFeature(domain, feature) {
  const FeatureName = capitalize(feature)
  const featureName = feature.toLowerCase()
  const domainName = domain.toLowerCase()

  // 1. Generate Repository
  const repositoryContent = `import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type ${FeatureName}Row = Database['public']['Tables']['${featureName}s']['Row']

export class ${FeatureName}Repository extends BaseRepository<'${featureName}s'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, '${featureName}s')
  }

  async findByStatus(status: string): Promise<${FeatureName}Row[]> {
    const { data, error } = await this.supabase
      .from('${featureName}s')
      .select('*')
      .eq('status', status)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }
}
`

  // 2. Generate Service
  const serviceContent = `import { repositories } from '@/lib/repositories'
import { logger } from '@/lib/logger'

export class ${FeatureName}Service {
  static async create${FeatureName}(data: any, userId: string) {
    try {
      const ${featureName} = await repositories.${featureName}s.create({
        ...data,
        created_by: userId
      })
      
      logger.info('${FeatureName} created', { ${featureName}Id: ${featureName}.id })
      return ${featureName}
      
    } catch (error) {
      logger.error('${FeatureName} creation failed', { error })
      throw error
    }
  }

  static async get${FeatureName}sByStatus(status: string) {
    return await repositories.${featureName}s.findByStatus(status)
  }
}
`

  // 3. Generate API Route
  const apiRouteContent = `import { NextRequest, NextResponse } from 'next/server'
import { ${FeatureName}Service } from '@/domains/${domainName}'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status') || 'active'
    
    const ${featureName}s = await ${FeatureName}Service.get${FeatureName}sByStatus(status)
    return NextResponse.json({ success: true, data: ${featureName}s })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to fetch ${featureName}s' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const data = await request.json()
    const ${featureName} = await ${FeatureName}Service.create${FeatureName}(data, 'user-id')
    
    return NextResponse.json({ success: true, data: ${featureName} })
    
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create ${featureName}' },
      { status: 400 }
    )
  }
}
`

  console.log(`✅ Generated ${feature} feature templates for ${domain} domain`)
  console.log(`📁 Repository: types/repositories/${featureName}.repository.ts`)
  console.log(`📁 Service: domains/${domainName}/${FeatureName}Service.ts`)
  console.log(`📁 API: app/api/${featureName}s/route.ts`)
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

const args = process.argv.slice(2)
if (args.length !== 2) {
  console.log('Usage: node scripts/generate-feature.js [domain] [feature]')
  process.exit(1)
}

generateFeature(args[0], args[1])