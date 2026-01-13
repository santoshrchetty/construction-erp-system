export async function getMRPShortages() {
  return { shortages: [], total: 0 }
}

export async function getMaterialForecast() {
  return { forecast: [], timeline: [] }
}

export async function getDemandForecast() {
  return { demand: [], confidence: 0.85 }
}