import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export default function ApprovalConfiguration() {
  const [departments, setDepartments] = useState([]);
  const [roles, setRoles] = useState([]);
  const [policies, setPolicies] = useState([]);

  const [newRole, setNewRole] = useState({
    role_code: '',
    role_name: '',
    department_code: '',
    approval_limit: 0,
    authority_level: 1
  });

  const [newPolicy, setNewPolicy] = useState({
    policy_name: '',
    department_code: '',
    amount_min: 0,
    amount_max: 999999999,
    approval_strategy: 'AMOUNT_BASED'
  });

  const addRole = async () => {
    try {
      const response = await fetch('/api/approval/roles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newRole)
      });
      
      if (response.ok) {
        alert('Role created successfully!');
        loadRoles();
        setNewRole({ role_code: '', role_name: '', department_code: '', approval_limit: 0, authority_level: 1 });
      }
    } catch (error) {
      console.error('Error creating role:', error);
    }
  };

  const addPolicy = async () => {
    try {
      const response = await fetch('/api/approval/policies', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newPolicy)
      });
      
      if (response.ok) {
        alert('Policy created successfully!');
        loadPolicies();
        setNewPolicy({ policy_name: '', department_code: '', amount_min: 0, amount_max: 999999999, approval_strategy: 'AMOUNT_BASED' });
      }
    } catch (error) {
      console.error('Error creating policy:', error);
    }
  };

  const loadRoles = async () => {
    const response = await fetch('/api/approval/roles');
    const data = await response.json();
    setRoles(data.data || []);
  };

  const loadPolicies = async () => {
    const response = await fetch('/api/approval/policies');
    const data = await response.json();
    setPolicies(data.data || []);
  };

  useEffect(() => {
    loadRoles();
    loadPolicies();
  }, []);

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      {/* Role Configuration */}
      <Card>
        <CardHeader>
          <CardTitle>Approval Roles Configuration</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-5 gap-4 mb-4">
            <Input
              placeholder="Role Code"
              value={newRole.role_code}
              onChange={(e) => setNewRole(prev => ({ ...prev, role_code: e.target.value }))}
            />
            <Input
              placeholder="Role Name"
              value={newRole.role_name}
              onChange={(e) => setNewRole(prev => ({ ...prev, role_name: e.target.value }))}
            />
            <Input
              placeholder="Department"
              value={newRole.department_code}
              onChange={(e) => setNewRole(prev => ({ ...prev, department_code: e.target.value }))}
            />
            <Input
              type="number"
              placeholder="Approval Limit"
              value={newRole.approval_limit}
              onChange={(e) => setNewRole(prev => ({ ...prev, approval_limit: parseFloat(e.target.value) }))}
            />
            <Button onClick={addRole}>Add Role</Button>
          </div>
          
          <div className="space-y-2">
            {roles.map((role) => (
              <div key={role.id} className="flex justify-between items-center p-2 border rounded">
                <span>{role.role_code} - {role.role_name}</span>
                <span>Limit: ${role.approval_limit?.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Policy Configuration */}
      <Card>
        <CardHeader>
          <CardTitle>Approval Policies Configuration</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-5 gap-4 mb-4">
            <Input
              placeholder="Policy Name"
              value={newPolicy.policy_name}
              onChange={(e) => setNewPolicy(prev => ({ ...prev, policy_name: e.target.value }))}
            />
            <Input
              placeholder="Department"
              value={newPolicy.department_code}
              onChange={(e) => setNewPolicy(prev => ({ ...prev, department_code: e.target.value }))}
            />
            <Input
              type="number"
              placeholder="Min Amount"
              value={newPolicy.amount_min}
              onChange={(e) => setNewPolicy(prev => ({ ...prev, amount_min: parseFloat(e.target.value) }))}
            />
            <Input
              type="number"
              placeholder="Max Amount"
              value={newPolicy.amount_max}
              onChange={(e) => setNewPolicy(prev => ({ ...prev, amount_max: parseFloat(e.target.value) }))}
            />
            <Button onClick={addPolicy}>Add Policy</Button>
          </div>
          
          <div className="space-y-2">
            {policies.map((policy) => (
              <div key={policy.id} className="flex justify-between items-center p-2 border rounded">
                <span>{policy.policy_name}</span>
                <span>${policy.amount_min?.toLocaleString()} - ${policy.amount_max?.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Quick Setup Templates */}
      <Card>
        <CardHeader>
          <CardTitle>Quick Setup Templates</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-4">
            <Button variant="outline">Small Company Setup</Button>
            <Button variant="outline">Multi-Department Setup</Button>
            <Button variant="outline">Enterprise Setup</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}