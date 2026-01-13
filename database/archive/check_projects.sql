[
  {
    "column_name": "id",
    "data_type": "uuid",
    "is_nullable": "NO",
    "column_default": "uuid_generate_v4()"
  },
  {
    "column_name": "name",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "code",
    "data_type": "character varying",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "description",
    "data_type": "text",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "project_type",
    "data_type": "USER-DEFINED",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "status",
    "data_type": "USER-DEFINED",
    "is_nullable": "NO",
    "column_default": "'planning'::project_status"
  },
  {
    "column_name": "start_date",
    "data_type": "date",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "planned_end_date",
    "data_type": "date",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "actual_end_date",
    "data_type": "date",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "budget",
    "data_type": "numeric",
    "is_nullable": "NO",
    "column_default": null
  },
  {
    "column_name": "client_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "project_manager_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "location",
    "data_type": "text",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "now()"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "is_nullable": "YES",
    "column_default": "now()"
  },
  {
    "column_name": "site_code",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "site_name",
    "data_type": "character varying",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "working_days",
    "data_type": "ARRAY",
    "is_nullable": "YES",
    "column_default": "'{1,2,3,4,5}'::integer[]"
  },
  {
    "column_name": "holidays",
    "data_type": "ARRAY",
    "is_nullable": "YES",
    "column_default": "'{}'::date[]"
  },
  {
    "column_name": "created_by",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "project_indirect_cost_plan",
    "data_type": "numeric",
    "is_nullable": "YES",
    "column_default": "0"
  },
  {
    "column_name": "project_indirect_cost_actual",
    "data_type": "numeric",
    "is_nullable": "YES",
    "column_default": "0"
  },
  {
    "column_name": "indirect_cost_allocation_method",
    "data_type": "USER-DEFINED",
    "is_nullable": "YES",
    "column_default": "'percentage_of_direct'::indirect_allocation_method"
  },
  {
    "column_name": "project_direct_cost_total",
    "data_type": "numeric",
    "is_nullable": "YES",
    "column_default": "0"
  },
  {
    "column_name": "company_code_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "purchasing_org_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  },
  {
    "column_name": "plant_id",
    "data_type": "uuid",
    "is_nullable": "YES",
    "column_default": null
  }
]