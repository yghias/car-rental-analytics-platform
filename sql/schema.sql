create schema if not exists raw;
create schema if not exists staging;
create schema if not exists core;
create schema if not exists marts;
create schema if not exists ml;
create schema if not exists ops;

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
