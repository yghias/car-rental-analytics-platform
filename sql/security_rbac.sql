-- Example RBAC definitions for a production-style analytics platform.

create role if not exists platform_admin;
create role if not exists ingestion_service;
create role if not exists analytics_engineer_rw;
create role if not exists analyst_ro;
create role if not exists finance_ro;

grant usage on warehouse analytics_wh to role ingestion_service;
grant usage on warehouse analytics_wh to role analytics_engineer_rw;
grant usage on warehouse analytics_bi_wh to role analyst_ro;
grant usage on warehouse analytics_bi_wh to role finance_ro;

grant usage on schema raw to role ingestion_service;
grant usage on schema staging to role analytics_engineer_rw;
grant usage on schema core to role analytics_engineer_rw;
grant usage on schema marts to role analyst_ro;
grant usage on schema marts to role finance_ro;

grant select on all tables in schema marts to role analyst_ro;
grant select on all tables in schema marts to role finance_ro;
grant select, insert, update, delete on all tables in schema core to role analytics_engineer_rw;
grant insert, update on all tables in schema ops to role analytics_engineer_rw;

create or replace masking policy pii_customer_id_mask as (val string) returns string ->
    case
        when current_role() in ('PLATFORM_ADMIN', 'ANALYTICS_ENGINEER_RW') then val
        else 'MASKED'
    end;

alter table if exists core.customer modify column customer_id set masking policy pii_customer_id_mask;
