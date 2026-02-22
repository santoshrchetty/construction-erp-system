import { createServiceClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const supabase = await createServiceClient()
  const { searchParams } = new URL(request.url)
  const action = searchParams.get('action')

  try {
    // 📋 LIST DOCUMENTS WITH CURRENT LIFECYCLE
    if (action === 'find' || action === 'list') {
      const documentNumber = searchParams.get('document_number')
      const title = searchParams.get('title')
      const documentType = searchParams.get('document_type')
      const status = searchParams.get('status')

      let query = supabase
        .from('documents')
        .select(`
          id,
          document_number,
          document_type,
          title,
          description,
          document_subtype,
          part_number,
          parent_document_id,
          document_level,
          project_code,
          created_at,
          parent_document:parent_document_id(
            document_number,
            title
          )
        `)
        .order('created_at', { ascending: false })

      if (documentNumber) {
        query = query.ilike('document_number', `%${documentNumber}%`)
      }
      if (title) {
        query = query.ilike('title', `%${title}%`)
      }
      if (documentType) {
        query = query.eq('document_type', documentType)
      }

      const { data: docs, error: docsError } = await query
      if (docsError) throw docsError

      // Get current lifecycle for each document
      const documentsWithLifecycle = await Promise.all(
        (docs || []).map(async (doc) => {
          const { data: lifecycle } = await supabase
            .from('document_lifecycle')
            .select('version, revision, status, effective_date')
            .eq('document_id', doc.id)
            .eq('is_current', true)
            .single()

          return {
            ...doc,
            current_lifecycle: lifecycle || { version: '0.1', status: 'DRAFT' }
          }
        })
      )

      // Filter by status if provided
      const filteredDocs = status 
        ? documentsWithLifecycle.filter(doc => doc.current_lifecycle.status === status)
        : documentsWithLifecycle

      return NextResponse.json({ success: true, data: filteredDocs })
    }

    // 📄 GET DOCUMENT BY ID
    if (action === 'get') {
      const documentId = searchParams.get('id')
      if (!documentId) {
        return NextResponse.json({ success: false, error: 'Document ID required' }, { status: 400 })
      }

      const { data: doc, error: docError } = await supabase
        .from('documents')
        .select(`
          id,
          document_number,
          document_type,
          title,
          description,
          document_subtype,
          part_number,
          parent_document_id,
          document_level,
          project_code,
          created_at
        `)
        .eq('id', documentId)
        .single()

      if (docError) throw docError

      const { data: lifecycle } = await supabase
        .from('document_lifecycle')
        .select('version, revision, status, effective_date')
        .eq('document_id', documentId)
        .eq('is_current', true)
        .single()

      return NextResponse.json({ 
        success: true, 
        data: {
          ...doc,
          current_lifecycle: lifecycle || { version: '0.1', status: 'DRAFT' }
        }
      })
    }

    // 🌳 HIERARCHICAL VIEW
    if (action === 'hierarchy') {
      const rootId = searchParams.get('rootId')
      if (!rootId) {
        return NextResponse.json({ success: false, error: 'rootId required' }, { status: 400 })
      }

      const { data, error } = await supabase
        .rpc('get_document_hierarchy', { p_root_document_id: rootId })

      if (error) throw error
      return NextResponse.json({ success: true, data })
    }

    // 📄 PARENT DOCUMENTS
    if (action === 'parent-documents') {
      const documentType = searchParams.get('document_type')
      
      let query = supabase
        .from('documents')
        .select('id, document_number, title, document_type, document_level')
        .order('document_number')

      // Only show documents that can be parents (exclude current document if editing)
      const excludeId = searchParams.get('exclude_id')
      if (excludeId) {
        query = query.neq('id', excludeId)
      }

      // Filter by document type if provided
      if (documentType) {
        query = query.eq('document_type', documentType)
      }

      const { data, error } = await query
      if (error) {
        console.error('Parent documents query error:', error)
        throw error
      }
      
      console.log('Parent documents loaded:', data?.length || 0, 'documents')
      return NextResponse.json({ success: true, data: data || [] })
    }

    // 🔗 RELATIONSHIPS
    if (action === 'relationships') {
      const documentId = searchParams.get('documentId')
      if (!documentId) {
        return NextResponse.json({ success: false, error: 'documentId required' }, { status: 400 })
      }

      const { data, error } = await supabase
        .from('document_relationships')
        .select(`
          id,
          relationship_type,
          is_primary,
          related_document:related_document_id(
            id,
            document_number,
            title,
            document_type
          )
        `)
        .eq('document_id', documentId)

      if (error) throw error
      return NextResponse.json({ success: true, data })
    }

    if (action === 'document-types') {
      return NextResponse.json({ 
        success: true, 
        data: [
          { value: 'DRW', label: 'Drawing' },
          { value: 'SPE', label: 'Specification' },
          { value: 'CNT', label: 'Contract' },
          { value: 'RFI', label: 'RFI' },
          { value: 'SUB', label: 'Submittal' },
          { value: 'CHG', label: 'Change Order' },
          { value: 'DOC', label: 'Other' }
        ]
      })
    }

    if (action === 'document-statuses') {
      return NextResponse.json({ 
        success: true, 
        data: [
          { value: 'DRAFT', label: 'Draft' },
          { value: 'IFR', label: 'Issued for Review' },
          { value: 'IFA', label: 'Issued for Approval' },
          { value: 'IFC', label: 'Issued for Construction' },
          { value: 'AS_BUILT', label: 'As Built' },
          { value: 'VOID', label: 'Void' }
        ]
      })
    }

    return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 })
  }
}

export async function POST(request: Request) {
  const supabase = await createServiceClient()
  const body = await request.json()
  const { action, data } = body

  try {
    // 📝 CREATE DOCUMENT
    if (action === 'create') {
      const tenantId = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
      
      const { data: result, error } = await supabase
        .rpc('create_document_with_lifecycle', {
          p_tenant_id: tenantId,
          p_document_type: data.document_type,
          p_title: data.title,
          p_description: data.description,
          p_document_subtype: data.document_subtype,
          p_part_number: data.part_number,
          p_parent_document_id: data.parent_document_id,
          p_created_by: data.created_by
        })

      if (error) throw error
      return NextResponse.json({ success: true, data: result[0] })
    }

    // 🔄 ISSUE REVISION
    if (action === 'issue-revision') {
      const { data: result, error } = await supabase
        .rpc('issue_document_revision', {
          p_document_id: data.document_id,
          p_new_revision: data.revision,
          p_new_status: data.status,
          p_issued_by: data.issued_by
        })

      if (error) throw error
      return NextResponse.json({ success: true, data: result })
    }

    return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 })
  }
}

export async function DELETE(request: Request) {
  const supabase = await createServiceClient()
  const body = await request.json()
  const { action, documentId, hardDelete } = body

  try {
    if (action === 'delete') {
      if (hardDelete) {
        // Hard delete for DRAFT documents
        await supabase.from('document_lifecycle').delete().eq('document_id', documentId)
        await supabase.from('document_relationships').delete().or(`document_id.eq.${documentId},related_document_id.eq.${documentId}`)
        const { error } = await supabase.from('documents').delete().eq('id', documentId)
        if (error) throw error
      } else {
        // Soft delete - set status to VOID
        const { error } = await supabase
          .from('document_lifecycle')
          .update({ status: 'VOID', updated_at: new Date().toISOString() })
          .eq('document_id', documentId)
          .eq('is_current', true)
        if (error) throw error
      }
      return NextResponse.json({ success: true })
    }
    return NextResponse.json({ success: false, error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message }, { status: 500 })
  }
}
