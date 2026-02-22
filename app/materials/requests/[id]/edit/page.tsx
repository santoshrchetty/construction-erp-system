'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import MaterialRequestFormV2 from '@/components/features/materials/MaterialRequestFormV2';
import { createClient } from '@/lib/supabase/client';

export default function EditMaterialRequestPage() {
  const params = useParams();
  const router = useRouter();
  const [materialRequest, setMaterialRequest] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMaterialRequest = async () => {
      const supabase = createClient();
      const { data, error } = await supabase
        .from('material_requests')
        .select(`
          *,
          items:material_request_items(*)
        `)
        .eq('id', params.id)
        .single();

      if (error || !data) {
        router.push('/materials/requests');
        return;
      }

      if (data.status !== 'DRAFT') {
        router.push(`/materials/requests/${params.id}`);
        return;
      }

      setMaterialRequest(data);
      setLoading(false);
    };

    fetchMaterialRequest();
  }, [params.id, router]);

  if (loading) {
    return <div className="p-6">Loading...</div>;
  }

  return (
    <div className="p-6">
      <MaterialRequestFormV2 
        initialData={materialRequest}
        isEditMode={true}
      />
    </div>
  );
}
