// import { z } from 'zod'; // Removed - not using Zod validation

// SAP Activity codes
export enum SAPActivity {
  CREATE = '01',
  CHANGE = '02', 
  DISPLAY = '03',
  DELETE = '06',
  APPROVE = '05',
  SUBMIT = '04'
}

// Authorization Object schema
export const AuthorizationObjectSchema = z.object({
  id: z.string().uuid(),
  object_name: z.string().max(10),
  description: z.string(),
  module: z.string(),
  is_active: z.boolean().default(true),
  created_at: z.string()
});

// Authorization Field schema
export const AuthorizationFieldSchema = z.object({
  id: z.string().uuid(),
  auth_object_id: z.string().uuid(),
  field_name: z.string().max(10),
  field_description: z.string().optional(),
  field_values: z.array(z.string()),
  is_required: z.boolean().default(true),
  created_at: z.string()
});

// User Authorization schema
export const UserAuthorizationSchema = z.object({
  id: z.string().uuid(),
  user_id: z.string().uuid(),
  auth_object_id: z.string().uuid(),
  field_values: z.record(z.array(z.string())), // {"ACTVT": ["01", "02"]}
  valid_from: z.string(),
  valid_to: z.string().optional(),
  created_at: z.string()
});

// Authorization Check Request
export const AuthCheckRequestSchema = z.object({
  user_id: z.string().uuid(),
  object_name: z.string(),
  activity: z.nativeEnum(SAPActivity),
  field_values: z.record(z.string()).optional() // {"PROJ_TYPE": "commercial"}
});

export type AuthorizationObject = z.infer<typeof AuthorizationObjectSchema>;
export type AuthorizationField = z.infer<typeof AuthorizationFieldSchema>;
export type UserAuthorization = z.infer<typeof UserAuthorizationSchema>;
export type AuthCheckRequest = z.infer<typeof AuthCheckRequestSchema>;

// Common authorization objects
export const AUTH_OBJECTS = {
  PROJECT_CREATE: 'F_PROJ_CRE',
  PROJECT_CHANGE: 'F_PROJ_CHG', 
  PROJECT_DISPLAY: 'F_PROJ_DIS',
  PO_CREATE: 'F_PO_CRE',
  PO_CHANGE: 'F_PO_CHG',
  PO_APPROVE: 'F_PO_APP',
  MATERIAL_CREATE: 'F_MAT_CRE',
  INVENTORY_DISPLAY: 'F_INV_DIS',
  TIMESHEET_CREATE: 'F_TIME_CRE',
  TIMESHEET_APPROVE: 'F_TIME_APP'
} as const;