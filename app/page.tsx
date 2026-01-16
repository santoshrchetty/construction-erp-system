export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#F7F7F7] via-white to-[#F0F8FF] flex items-center justify-center p-4">
      <div className="text-center max-w-3xl mx-auto">
        <div className="mb-8">
          <h1 className="text-5xl md:text-6xl font-light text-[#32363A] mb-4 tracking-tight">
            Nexus ERP
          </h1>
          <div className="h-1 w-24 bg-gradient-to-r from-[#0A6ED1] to-[#0080FF] mx-auto mb-6 rounded-full"></div>
          <p className="text-xl md:text-2xl text-[#6A6D70] font-light mb-3">
            Enterprise Resource Planning for Modern Construction
          </p>
          <p className="text-base text-[#6A6D70] max-w-2xl mx-auto leading-relaxed">
            Streamline project management, procurement, finance, and operations with an integrated platform built for the construction industry
          </p>
        </div>
        <a 
          href="/login" 
          className="inline-flex items-center px-8 py-4 bg-[#0A6ED1] text-white rounded-lg font-medium hover:bg-[#0080FF] shadow-[0_4px_16px_rgba(10,110,209,0.3)] hover:shadow-[0_6px_20px_rgba(10,110,209,0.4)] transition-all duration-200 transform hover:scale-105"
        >
          Get Started
          <svg className="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </a>
      </div>
    </div>
  )
}