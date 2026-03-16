create schema if not exists raw;
create schema if not exists staging;
create schema if not exists core;
create schema if not exists marts;
create schema if not exists ml;
create schema if not exists ops;

create or replace table ops.pipeline_run (
    pipeline_run_sk bigint generated always as identity,
    pipeline_name varchar not null,
    run_id varchar not null,
    source_name varchar,
    started_at timestamp not null,
    completed_at timestamp,
    status varchar not null,
    extracted_row_count bigint default 0,
    loaded_row_count bigint default 0,
    error_count bigint default 0,
    primary key (pipeline_run_sk)
);

create or replace table ops.data_quality_result (
    quality_result_sk bigint generated always as identity,
    check_name varchar not null,
    dataset_name varchar not null,
    severity varchar not null,
    passed_flag boolean not null,
    observed_value varchar,
    expected_value varchar,
    evaluated_at timestamp not null,
    pipeline_run_id varchar,
    primary key (quality_result_sk)
);

create or replace table core.booking (
    booking_sk bigint generated always as identity,
    booking_id varchar not null,
    customer_id varchar not null,
    pickup_location_id varchar not null,
    return_location_id varchar not null,
    vehicle_class varchar not null,
    booking_status varchar not null,
    booking_created_ts timestamp,
    scheduled_pickup_ts timestamp,
    scheduled_return_ts timestamp,
    actual_pickup_ts timestamp,
    actual_return_ts timestamp,
    booked_revenue_amount number(12,2),
    final_revenue_amount number(12,2),
    source_system varchar,
    ingestion_ts timestamp,
    primary key (booking_sk)
);

create or replace table core.booking_event (
    booking_event_sk bigint generated always as identity,
    booking_id varchar not null,
    event_id varchar not null,
    event_type varchar not null,
    event_ts timestamp not null,
    booking_status varchar,
    source_system varchar,
    ingestion_ts timestamp not null,
    primary key (booking_event_sk)
);

create or replace table core.vehicle (
    vehicle_sk bigint generated always as identity,
    vehicle_id varchar not null,
    vin varchar not null,
    vehicle_class varchar not null,
    make varchar,
    model varchar,
    model_year integer,
    current_location_id varchar,
    active_flag boolean,
    ingestion_ts timestamp,
    primary key (vehicle_sk)
);

create or replace table core.fleet_status_snapshot (
    fleet_status_snapshot_sk bigint generated always as identity,
    snapshot_date date not null,
    vehicle_id varchar not null,
    current_location_id varchar not null,
    vehicle_class varchar not null,
    fleet_status_standardized varchar not null,
    available_flag boolean not null,
    in_maintenance boolean default false,
    source_system varchar,
    ingestion_ts timestamp not null,
    primary key (fleet_status_snapshot_sk)
);

create or replace table core.customer (
    customer_sk bigint generated always as identity,
    customer_id varchar not null,
    loyalty_tier varchar,
    country_code varchar,
    marketing_opt_in boolean,
    effective_start_ts timestamp default current_timestamp,
    effective_end_ts timestamp,
    is_current boolean default true,
    primary key (customer_sk)
);

create or replace table core.location (
    location_sk bigint generated always as identity,
    location_id varchar not null,
    location_name varchar not null,
    city varchar,
    state varchar,
    region varchar,
    airport_flag boolean,
    effective_start_ts timestamp default current_timestamp,
    effective_end_ts timestamp,
    is_current boolean default true,
    primary key (location_sk)
);

create or replace table core.pricing_event (
    pricing_event_sk bigint generated always as identity,
    pricing_event_id varchar not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    channel varchar not null,
    rate_amount number(12,2),
    effective_start_ts timestamp,
    effective_end_ts timestamp,
    ingestion_ts timestamp,
    primary key (pricing_event_sk)
);

create or replace table core.maintenance_event (
    maintenance_event_sk bigint generated always as identity,
    maintenance_event_id varchar not null,
    vehicle_id varchar not null,
    location_id varchar,
    maintenance_type varchar,
    opened_at timestamp,
    closed_at timestamp,
    estimated_cost_amount number(12,2),
    ingestion_ts timestamp,
    primary key (maintenance_event_sk)
);

create or replace table marts.dim_location (
    location_id varchar not null,
    location_name varchar,
    city varchar,
    state varchar,
    region varchar,
    airport_flag boolean
);

create or replace table marts.dim_vehicle (
    vehicle_id varchar not null,
    vin varchar,
    vehicle_class varchar,
    location_id varchar
);

create or replace table marts.fact_booking (
    booking_id varchar not null,
    customer_id varchar not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    booking_status varchar not null,
    pickup_date date,
    return_date date,
    scheduled_rental_days integer,
    booked_revenue_amount number(12,2)
);

create or replace table marts.fact_booking_day (
    booking_id varchar not null,
    service_date date not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    booking_channel varchar,
    active_booking_day_count integer default 1
);

create or replace table marts.fact_booking_pace (
    pickup_date date not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    booking_created_date date not null,
    booking_count bigint default 0
);

create or replace table marts.fact_vehicle_utilization (
    snapshot_date date not null,
    vehicle_id varchar not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    available_vehicle_count integer default 0,
    reserved_vehicle_count integer default 0,
    maintenance_vehicle_count integer default 0
);

create or replace table marts.fact_revenue (
    booking_id varchar not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    service_date date not null,
    booked_revenue_amount number(12,2),
    realized_revenue_amount number(12,2)
);

create or replace table marts.fact_pricing_event (
    pricing_event_id varchar not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    channel varchar not null,
    rate_amount number(12,2),
    effective_start_ts timestamp,
    effective_end_ts timestamp,
    effective_days integer
);

create or replace table marts.fact_pricing_effectiveness (
    location_id varchar not null,
    vehicle_class varchar not null,
    service_date date not null,
    channel varchar not null,
    booking_count bigint default 0,
    avg_rate_amount number(12,2),
    realized_revenue_amount number(12,2)
);

create or replace table marts.fact_maintenance_downtime (
    maintenance_event_id varchar not null,
    vehicle_id varchar not null,
    location_id varchar,
    maintenance_type varchar,
    downtime_hours integer,
    estimated_cost_amount number(12,2)
);

create or replace table marts.fact_forecast_actual (
    location_id varchar not null,
    vehicle_class varchar not null,
    service_date date not null,
    actual_booking_count bigint default 0,
    forecasted_booking_count number(12,2),
    forecast_error number(12,2)
);

create or replace table marts.mart_branch_daily_performance (
    service_date date not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    booking_count bigint default 0,
    realized_revenue_amount number(12,2),
    available_vehicle_count bigint,
    maintenance_vehicle_count bigint,
    revenue_per_available_car_day number(12,2)
);

create or replace table marts.mart_operational_kpis (
    service_date date not null,
    location_id varchar not null,
    vehicle_class varchar not null,
    booking_count bigint default 0,
    cancelled_booking_count bigint default 0,
    available_vehicle_count bigint,
    maintenance_vehicle_count bigint,
    realized_revenue_amount number(12,2),
    cancellation_rate number(12,4)
);
