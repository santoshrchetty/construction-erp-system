/**
 * Subdomain Utility
 * Extracts subdomain from hostname for tenant identification
 */

export function extractSubdomain(hostname: string): string | null {
  if (!hostname) return null
  
  // Remove port if present
  const host = hostname.split(':')[0]
  
  // Split by dots
  const parts = host.split('.')
  
  // localhost or IP address - no subdomain
  if (parts.length < 2 || host === 'localhost' || /^\d+\.\d+\.\d+\.\d+$/.test(host)) {
    return null
  }
  
  // Get first part as subdomain
  const subdomain = parts[0]
  
  // Ignore common prefixes
  if (['www', 'app', 'api', 'admin'].includes(subdomain)) {
    return null
  }
  
  return subdomain
}

export function isLocalDevelopment(hostname: string): boolean {
  return hostname.includes('localhost') || hostname.includes('127.0.0.1')
}
