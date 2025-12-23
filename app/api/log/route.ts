import { NextRequest, NextResponse } from 'next/server'
import { writeFile, appendFile } from 'fs/promises'
import { join } from 'path'

export async function POST(request: NextRequest) {
  try {
    const { log } = await request.json()
    const logPath = join(process.cwd(), 'auth-debug.log')
    
    await appendFile(logPath, log + '\n', 'utf8')
    
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Log API error:', error)
    return NextResponse.json({ error: 'Failed to write log' }, { status: 500 })
  }
}