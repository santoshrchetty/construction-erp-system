// Authorization cache with TTL and user isolation
interface CachedAuth {
  data: any[]
  expires: number
  userId: string
  roleId: string
}

class AuthCache {
  private cache = new Map<string, CachedAuth>()
  private readonly TTL = 5 * 60 * 1000 // 5 minutes

  get(userId: string, roleId: string): any[] | null {
    const key = `${userId}_${roleId}`
    const cached = this.cache.get(key)
    
    if (cached && Date.now() < cached.expires) {
      console.log(`Cache HIT for ${key}`) // Debug cache performance
      return cached.data
    }
    
    // Clean expired entry
    if (cached) {
      console.log(`Cache EXPIRED for ${key}`) // Debug cache expiry
      this.cache.delete(key)
    } else {
      console.log(`Cache MISS for ${key}`) // Debug cache miss
    }
    
    return null
  }

  set(userId: string, roleId: string, data: any[]): void {
    const key = `${userId}_${roleId}`
    console.log(`Cache SET for ${key} with ${data.length} items`) // Debug cache set
    this.cache.set(key, {
      data,
      expires: Date.now() + this.TTL,
      userId,
      roleId
    })
  }

  clear(): void {
    this.cache.clear()
  }

  clearUser(userId: string): void {
    for (const [key, value] of this.cache.entries()) {
      if (value.userId === userId) {
        this.cache.delete(key)
      }
    }
  }

  // Clean expired entries periodically
  cleanup(): void {
    const now = Date.now()
    for (const [key, value] of this.cache.entries()) {
      if (now >= value.expires) {
        this.cache.delete(key)
      }
    }
  }
}

export const authCache = new AuthCache()

// Cleanup every 10 minutes
setInterval(() => authCache.cleanup(), 10 * 60 * 1000)