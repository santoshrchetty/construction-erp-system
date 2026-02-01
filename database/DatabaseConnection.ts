// Minimal DatabaseConnection stub
export class DatabaseConnection {
  static getInstance() {
    return new DatabaseConnection()
  }

  async query(sql: string, params?: any[]) {
    throw new Error('DatabaseConnection not implemented')
  }

  async execute(sql: string, params?: any[]) {
    throw new Error('DatabaseConnection not implemented')
  }
}
