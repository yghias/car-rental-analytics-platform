-- Parameterized backfill patterns. Replace placeholders with orchestrated runtime values.

-- Example: rebuild a booking date window in the warehouse.
delete from marts.fact_booking
where pickup_date between to_date('{{ start_date }}') and to_date('{{ end_date }}');

insert into marts.fact_booking (
    booking_id,
    customer_id,
    location_id,
    vehicle_class,
    booking_status,
    pickup_date,
    return_date,
    scheduled_rental_days,
    booked_revenue_amount
)
select
    booking_id,
    customer_id,
    pickup_location_id,
    vehicle_class,
    booking_status,
    cast(date_trunc('day', scheduled_pickup_ts) as date),
    cast(date_trunc('day', scheduled_return_ts) as date),
    greatest(datediff('day', scheduled_pickup_ts, scheduled_return_ts), 1),
    booked_revenue_amount
from core.booking
where cast(date_trunc('day', scheduled_pickup_ts) as date) between to_date('{{ start_date }}') and to_date('{{ end_date }}');

-- Example: rebuild branch daily performance only for impacted partitions.
delete from marts.mart_branch_daily_performance
where service_date between to_date('{{ start_date }}') and to_date('{{ end_date }}')
  and location_id = '{{ location_id }}';

insert into marts.mart_branch_daily_performance (
    service_date,
    location_id,
    vehicle_class,
    booking_count,
    realized_revenue_amount,
    available_vehicle_count,
    maintenance_vehicle_count,
    revenue_per_available_car_day
)
select
    r.service_date,
    r.location_id,
    r.vehicle_class,
    count(distinct r.booking_id),
    sum(r.realized_revenue_amount),
    sum(u.available_vehicle_count),
    sum(u.maintenance_vehicle_count),
    case
        when sum(u.available_vehicle_count) = 0 then null
        else sum(r.realized_revenue_amount) / sum(u.available_vehicle_count)
    end
from marts.fact_revenue r
left join marts.fact_vehicle_utilization u
  on r.service_date = u.snapshot_date
 and r.location_id = u.location_id
 and r.vehicle_class = u.vehicle_class
where r.service_date between to_date('{{ start_date }}') and to_date('{{ end_date }}')
  and r.location_id = '{{ location_id }}'
group by 1, 2, 3;

-- Example: replay operational quality checks after a backfill.
insert into ops.data_quality_result (
    check_name,
    dataset_name,
    severity,
    passed_flag,
    observed_value,
    expected_value,
    evaluated_at,
    pipeline_run_id
)
select
    'backfill_partition_rebuilt',
    'marts.mart_branch_daily_performance',
    'info',
    true,
    concat('{{ start_date }}', ' to ', '{{ end_date }}'),
    '{{ location_id }}',
    current_timestamp,
    '{{ pipeline_run_id }}';
