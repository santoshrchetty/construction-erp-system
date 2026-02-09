import { SupabaseClient } from '@supabase/supabase-js';
import { 
  AuthorizationObject, 
  AuthorizationField, 
  UserAuthorization, 
  AuthCheckRequest,
  SAPActivity 
} from '../sap-authorization';

export class SAPAuthorizationRepository {
  constructor(private supabase: SupabaseClient) {}

  // Check user authorization
  async checkAuthorization(request: AuthCheckRequest): Promise<boolean> {
    const { data, error } = await this.supabase
      .rpc('check_sap_authorization', {
        p_user_id: request.user_id,
        p_object_name: request.object_name,
        p_activity: request.activity,
        p_field_values: request.field_values || {}
      });

    if (error) throw error;
    return data || false;
  }

  // Get user authorizations
  async getUserAuthorizations(userId: string): Promise<UserAuthorization[]> {
    const { data, error } = await this.supabase
      .from('user_authorizations')
      .select(`
        *,
        authorization_objects (
          object_name,
          description,
          module
        )
      `)
      .eq('user_id', userId)
      .gte('valid_to', new Date().toISOString().split('T')[0])
      .or('valid_to.is.null');

    if (error) throw error;
    return data || [];
  }

  // Assign authorization to user
  async assignAuthorization(
    userId: string, 
    objectName: string, 
    fieldValues: Record<string, string[]>
  ): Promise<void> {
    const { data: authObject } = await this.supabase
      .from('authorization_objects')
      .select('id')
      .eq('object_name', objectName)
      .single();

    if (!authObject) throw new Error(`Authorization object ${objectName} not found`);

    const { error } = await this.supabase
      .from('user_authorizations')
      .upsert({
        user_id: userId,
        auth_object_id: authObject.id,
        field_values: fieldValues
      });

    if (error) throw error;
  }

  // Get all authorization objects
  async getAuthorizationObjects(): Promise<AuthorizationObject[]> {
    const { data, error } = await this.supabase
      .from('authorization_objects')
      .select('*')
      .eq('is_active', true)
      .order('module', { ascending: true });

    if (error) throw error;
    return data || [];
  }
}