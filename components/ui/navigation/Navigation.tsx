'use client'
import { useState } from 'react'
import Link from 'next/link'

export default function Navigation() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <nav style={{background: 'white', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', borderBottom: '1px solid #e5e7eb'}}>
      <div style={{maxWidth: '1200px', margin: '0 auto', padding: '0 1rem'}}>
        <div style={{display: 'flex', justifyContent: 'space-between', height: '4rem', alignItems: 'center'}}>
          <Link href="/" style={{display: 'flex', alignItems: 'center', textDecoration: 'none'}}>
            <div style={{
              height: '2rem',
              width: '2rem',
              background: '#2563eb',
              borderRadius: '0.5rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <span style={{color: 'white', fontWeight: 'bold', fontSize: '0.875rem'}}>CM</span>
            </div>
            <span style={{marginLeft: '0.5rem', fontSize: '1.25rem', fontWeight: 'bold', color: '#111827'}}>
              ConstructionManager
            </span>
          </Link>

          <div style={{display: 'none'}} className="desktop-nav">
            <div style={{display: 'flex', alignItems: 'center', gap: '2rem'}}>
              <Link href="/projects" style={{color: '#374151', textDecoration: 'none', padding: '0.5rem 0.75rem', fontSize: '0.875rem', fontWeight: '500'}}>
                Projects
              </Link>
              <Link href="/analytics" style={{color: '#374151', textDecoration: 'none', padding: '0.5rem 0.75rem', fontSize: '0.875rem', fontWeight: '500'}}>
                Analytics
              </Link>
              <Link href="/procurement" style={{color: '#374151', textDecoration: 'none', padding: '0.5rem 0.75rem', fontSize: '0.875rem', fontWeight: '500'}}>
                Procurement
              </Link>
              <Link href="/materials" style={{color: '#374151', textDecoration: 'none', padding: '0.5rem 0.75rem', fontSize: '0.875rem', fontWeight: '500'}}>
                Materials
              </Link>
              <Link href="/timesheets" style={{color: '#374151', textDecoration: 'none', padding: '0.5rem 0.75rem', fontSize: '0.875rem', fontWeight: '500'}}>
                Timesheets
              </Link>
            </div>
          </div>

          <button
            onClick={() => setIsOpen(!isOpen)}
            style={{
              color: '#374151',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              padding: '0.5rem'
            }}
            className="mobile-menu-btn"
          >
            <svg style={{height: '1.5rem', width: '1.5rem'}} fill="none" viewBox="0 0 24 24" stroke="currentColor">
              {isOpen ? (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              ) : (
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              )}
            </svg>
          </button>
        </div>
      </div>

      {isOpen && (
        <div style={{background: '#f9fafb', padding: '0.5rem 1rem 0.75rem'}}>
          <div style={{display: 'flex', flexDirection: 'column', gap: '0.25rem'}}>
            <Link href="/projects" style={{display: 'block', padding: '0.75rem', color: '#374151', textDecoration: 'none', fontSize: '1rem', fontWeight: '500'}}>
              Projects
            </Link>
            <Link href="/analytics" style={{display: 'block', padding: '0.75rem', color: '#374151', textDecoration: 'none', fontSize: '1rem', fontWeight: '500'}}>
              Analytics
            </Link>
            <Link href="/procurement" style={{display: 'block', padding: '0.75rem', color: '#374151', textDecoration: 'none', fontSize: '1rem', fontWeight: '500'}}>
              Procurement
            </Link>
            <Link href="/materials" style={{display: 'block', padding: '0.75rem', color: '#374151', textDecoration: 'none', fontSize: '1rem', fontWeight: '500'}}>
              Materials
            </Link>
            <Link href="/timesheets" style={{display: 'block', padding: '0.75rem', color: '#374151', textDecoration: 'none', fontSize: '1rem', fontWeight: '500'}}>
              Timesheets
            </Link>
          </div>
        </div>
      )}

      <style jsx>{`
        @media (min-width: 768px) {
          .desktop-nav {
            display: block !important;
          }
          .mobile-menu-btn {
            display: none !important;
          }
        }
      `}</style>
    </nav>
  )
}