import React, { useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Icons } from '@/components/ui/icons';

// Purchase Requisition Approvals Component
export const PurchaseRequisitionApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.FileInvoice className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Manage purchase requisition approval workflows</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Pending PR Approvals</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search PR number..." />
            <Button>View Pending Requests</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

// Claims Approvals Component
export const ClaimsApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.Receipt className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Process claims and progress payment approvals</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Claims Processing</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search claim number..." />
            <Button>View Pending Claims</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

// Contract Approvals Component
export const ContractApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.Handshake className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Approve contracts and subcontractor agreements</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Contract Approvals</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search contract number..." />
            <Button>View Pending Contracts</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

// Invoice Approvals Component
export const InvoiceApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.FileInvoiceDollar className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Process vendor invoice approvals and payments</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Invoice Processing</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search invoice number..." />
            <Button>View Pending Invoices</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

// Change Order Approvals Component
export const ChangeOrderApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.Edit className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Approve project scope and specification changes</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Change Order Management</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search change order number..." />
            <Button>View Pending Changes</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);

// Budget Approvals Component
export const BudgetApprovalsComponent = () => (
  <div className="p-6">
    <div className="bg-white rounded-lg shadow p-6">
      <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center">
          <Icons.Calculator className="w-5 h-5 text-blue-600 mr-2" />
          <div>
            <p className="text-sm text-blue-600">Approve budget modifications and allocations</p>
          </div>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Budget Management</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <Input placeholder="Search budget code..." />
            <Button>View Pending Budgets</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
);