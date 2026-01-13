export default function HomePage() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 mb-4">Construction Management SaaS</h1>
        <p className="text-gray-600 mb-8">Welcome to your construction management system</p>
        <a 
          href="/login" 
          className="bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700"
        >
          Get Started
        </a>
      </div>
    </div>
  )
}