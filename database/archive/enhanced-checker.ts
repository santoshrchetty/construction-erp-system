// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
import { SupabaseClient } from '@supabase/supabase-js';
import { UserRole, Module, Permission } from './types';
import { SAPActivity, AUTH_OBJECTS } from '../types/sap-authorization';

// Enhanced permission checker with SAP integration
export class EnhancedPermissionChecker {
  constructor(private supabase: SupabaseClient) {}

  // Map existing permissions to SAP activities
  private mapPermissionToSAPActivity(permission: Permission): SAPActivity {
    switch (permission) {
      case Permission.CREATE: return SAPActivity.CREATE;
      case Permission.EDIT: return SAPActivity.CHANGE;
      case Permission.VIEW: return SAPActivity.DISPLAY;
      case Permission.DELETE: return SAPActivity.DELETE;
      case Permission.APPROVE: return SAPActivity.APPROVE;
      case Permission.SUBMIT: return SAPActivity.SUBMIT;
      default: return SAPActivity.DISPLAY;
    }
  }

  // Map module to SAP authorization object
  private mapModuleToAuthObject(module: Module, permission: Permission): string {
    const activity = this.mapPermissionToSAPActivity(permission);
    
    switch (module) {
      case Module.PROJECTS:
        if (activity === SAPActivity.CREATE) return AUTH_OBJECTS.PROJECT_CREATE;
        if (activity === SAPActivity.CHANGE) return AUTH_OBJECTS.PROJECT_CHANGE;
        return AUTH_OBJECTS.PROJECT_DISPLAY;
        
      case Module.PURCHASE_ORDERS:
        if (activity === SAPActivity.CREATE) return AUTH_OBJECTS.PO_CREATE;
        if (activity === SAPActivity.CHANGE) return AUTH_OBJECTS.PO_CHANGE;
        if (activity === SAPActivity.APPROVE) return AUTH_OBJECTS.PO_APPROVE;
        return AUTH_OBJECTS.PROJECT_DISPLAY;
        
      case Module.PROCUREMENT:
        return AUTH_OBJECTS.PO_CREATE;
        
      case Module.STORES:
      case Module.GOODS_RECEIPTS:
        return AUTH_OBJECTS.INVENTORY_DISPLAY;
        
      case Module.TIMESHEETS:
        if (activity === SAPActivity.APPROVE) return AUTH_OBJECTS.TIMESHEET_APPROVE;
        return AUTH_OBJECTS.TIMESHEET_CREATE;
        
      default:
        return AUTH_OBJECTS.PROJECT_DISPLAY;
    }
  }

  // Enhanced permission check using SAP authorization
  async checkPermission(
    userId: string,
    module: Module,
    permission: Permission,
    context?: Record<string, string>
  ): Promise<boolean> {
    const authObject = this.mapModuleToAuthObject(module, permission);
    const activity = this.mapPermissionToSAPActivity(permission);

    const { data, error } = await this.supabase
      .rpc('check_sap_authorization', {
        p_user_id: userId,
        p_object_name: authObject,
        p_activity: activity,
        p_field_values: context || {}
      });

    if (error) {
      console.error('Authorization check failed:', error);
      return false;
    }

    return data || false;
  }

  // Bulk permission check for multiple modules
  async checkMultiplePermissions(
    userId: string,
    checks: Array<{ module: Module; permission: Permission; context?: Record<string, string> }>
  ): Promise<Record<string, boolean>> {
    const results: Record<string, boolean> = {};
    
    for (const check of checks) {
      const key = `${check.module}_${check.permission}`;
      results[key] = await this.checkPermission(
        userId,
        check.module,
        check.permission,
        check.context
      );
    }
    
    return results;
  }

  // Get user's accessible modules
  async getUserAccessibleModules(userId: string): Promise<Module[]> {
    const modules = Object.values(Module);
    const accessibleModules: Module[] = [];

    for (const module of modules) {
      const hasAccess = await this.checkPermission(userId, module, Permission.VIEW);
      if (hasAccess) {
        accessibleModules.push(module);
      }
    }

    return accessibleModules;
  }
}
*/