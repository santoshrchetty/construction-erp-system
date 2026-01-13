import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';

interface PendingPO {
  po_number: string;
  vendor_code: string;
  total_amount: number;
  current_level: number;
  total_levels: number;
  approver_role: string;
  created_by: string;
  po_date: string;
}

export default function POApprovalPanel() {
  const [pendingPOs, setPendingPOs] = useState<PendingPO[]>([]);
  const [comments, setComments] = useState<{[key: string]: string}>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadPendingApprovals();
  }, []);

  const loadPendingApprovals = async () => {
    try {
      const response = await fetch('/api/purchase?action=pending-approvals&approverId=current_user');
      const result = await response.json();
      if (result.success) {
        setPendingPOs(result.data || []);
      }
    } catch (error) {
      console.error('Error loading pending approvals:', error);
    }
  };

  const handleApproval = async (poNumber: string, action: 'approve' | 'reject') => {
    setLoading(true);
    try {
      const response = await fetch(`/api/purchase?action=${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          poNumber,
          approverId: 'current_user',
          comments: comments[poNumber] || ''
        })
      });

      const result = await response.json();
      if (result.success) {
        alert(`PO ${action}d successfully!`);
        loadPendingApprovals(); // Refresh list
        setComments(prev => ({ ...prev, [poNumber]: '' }));
      } else {
        alert('Error: ' + (result.error || 'Unknown error'));
      }
    } catch (error) {
      console.error(`Error ${action}ing PO:`, error);
      alert(`Error ${action}ing PO`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <Card>
        <CardHeader>
          <CardTitle>Purchase Order Approvals</CardTitle>
        </CardHeader>
        <CardContent>
          {pendingPOs.length === 0 ? (
            <p className="text-gray-500">No pending approvals</p>
          ) : (
            <div className="space-y-4">
              {pendingPOs.map((po) => (
                <div key={po.po_number} className="border rounded p-4">
                  <div className="grid grid-cols-4 gap-4 mb-4">
                    <div>
                      <label className="text-sm font-medium">PO Number</label>
                      <p>{po.po_number}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium">Vendor</label>
                      <p>{po.vendor_code}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium">Amount</label>
                      <p>₹{po.total_amount.toFixed(2)}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium">Approval Level</label>
                      <p>{po.current_level} of {po.total_levels}</p>
                    </div>
                  </div>
                  
                  <div className="mb-4">
                    <label className="block text-sm font-medium mb-2">Comments</label>
                    <Textarea
                      value={comments[po.po_number] || ''}
                      onChange={(e) => setComments(prev => ({ ...prev, [po.po_number]: e.target.value }))}
                      placeholder="Add approval comments..."
                      rows={2}
                    />
                  </div>
                  
                  <div className="flex space-x-4">
                    <Button 
                      onClick={() => handleApproval(po.po_number, 'approve')}
                      disabled={loading}
                      className="bg-green-600 hover:bg-green-700"
                    >
                      Approve
                    </Button>
                    <Button 
                      onClick={() => handleApproval(po.po_number, 'reject')}
                      disabled={loading}
                      variant="destructive"
                    >
                      Reject
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}