import { test, expect } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';

test.describe('User Authorization Check', () => {
  
  test('should check admin user role and authorization objects', async () => {
    const supabase = createClient(
      'https://tozgoiwobgdscplxdgbv.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvemdvaXdvYmdkc2NwbHhkZ2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODc4MTgsImV4cCI6MjA4MzM2MzgxOH0.mxCS2VfY74qCiGNnhmcx0N9aX_nTi6yujzVk44lti9E'
    );
    
    console.log('🔍 Checking authorization system tables...');
    
    // Check if users table exists and has admin user
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('*')
      .eq('email', 'admin@nttdemo.com');
    
    console.log('Users table query result:', { users, usersError });
    
    // Check roles table
    const { data: roles, error: rolesError } = await supabase
      .from('roles')
      .select('*');
    
    console.log('Roles table:', { roles, rolesError });
    
    // Check authorization_objects table
    const { data: authObjects, error: authError } = await supabase
      .from('authorization_objects')
      .select('*')
      .limit(10);
    
    console.log('Authorization objects:', { authObjects, authError });
    
    // Check role_authorization_objects table
    const { data: roleAuth, error: roleAuthError } = await supabase
      .from('role_authorization_objects')
      .select('*')
      .limit(10);
    
    console.log('Role authorization objects:', { roleAuth, roleAuthError });
    
    // Check tiles table
    const { data: tiles, error: tilesError } = await supabase
      .from('tiles')
      .select('*')
      .eq('is_active', true)
      .limit(10);
    
    console.log('Tiles table:', { tiles, tilesError });
    
    // Check user_roles table
    const { data: userRoles, error: userRolesError } = await supabase
      .from('user_roles')
      .select('*');
    
    console.log('User roles table:', { userRoles, userRolesError });
    
    console.log('\n📊 AUTHORIZATION SYSTEM STATUS:');
    console.log(`Users table: ${usersError ? '❌ Error' : '✅ OK'} (${users?.length || 0} users)`);
    console.log(`Roles table: ${rolesError ? '❌ Error' : '✅ OK'} (${roles?.length || 0} roles)`);
    console.log(`Auth objects: ${authError ? '❌ Error' : '✅ OK'} (${authObjects?.length || 0} objects)`);
    console.log(`Role auth: ${roleAuthError ? '❌ Error' : '✅ OK'} (${roleAuth?.length || 0} assignments)`);
    console.log(`Tiles: ${tilesError ? '❌ Error' : '✅ OK'} (${tiles?.length || 0} tiles)`);
    console.log(`User roles: ${userRolesError ? '❌ Error' : '✅ OK'} (${userRoles?.length || 0} assignments)`);
    
    // If admin user exists, check their specific authorization
    if (users && users.length > 0) {
      const adminUser = users[0];
      console.log('\n👤 Admin user details:', {
        id: adminUser.id,
        email: adminUser.email,
        role_id: adminUser.role_id
      });
      
      // Check admin's role assignments
      if (adminUser.role_id) {
        const { data: adminRoleAuth } = await supabase
          .from('role_authorization_objects')
          .select('*, authorization_objects(*)')
          .eq('role_id', adminUser.role_id);
        
        console.log(`Admin has ${adminRoleAuth?.length || 0} authorization objects`);
        
        if (adminRoleAuth && adminRoleAuth.length > 0) {
          console.log('Admin authorized objects:');
          adminRoleAuth.forEach((auth, i) => {
            console.log(`  ${i + 1}. ${auth.authorization_objects?.object_name}`);
          });
        }
      }
    }
    
    // Test passes if basic tables exist
    expect(usersError).toBeNull();
  });
});