// Client-side logger that writes to a file
class Logger {
  private logs: string[] = []

  log(message: string, data?: any) {
    const timestamp = new Date().toISOString()
    const logEntry = `[${timestamp}] ${message}${data ? ` | Data: ${JSON.stringify(data)}` : ''}`
    
    this.logs.push(logEntry)
    console.log(logEntry)
    
    // Send to API endpoint to write to file
    this.writeToFile(logEntry)
  }

  private async writeToFile(logEntry: string) {
    try {
      await fetch('/api/log', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ log: logEntry })
      })
    } catch (error) {
      console.error('Failed to write log:', error)
    }
  }

  getLogs() {
    return this.logs
  }

  clear() {
    this.logs = []
  }
}

export const logger = new Logger()