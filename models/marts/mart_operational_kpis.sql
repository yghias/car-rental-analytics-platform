with booking_base as (
    select
        pickup_date as service_date,
        location_id,
        vehicle_class,
        count(distinct booking_id) as booking_count,
        sum(case when booking_status = 'cancelled' then 1 else 0 end) as cancelled_booking_count
    from {{ ref('fact_booking') }}
    group by 1, 2, 3
),
utilization as (
    select
        snapshot_date as service_date,
        location_id,
        vehicle_class,
        sum(available_vehicle_count) as available_vehicle_count,
        sum(maintenance_vehicle_count) as maintenance_vehicle_count
    from {{ ref('fact_vehicle_utilization') }}
    group by 1, 2, 3
),
revenue as (
    select
        service_date,
        location_id,
        vehicle_class,
        sum(realized_revenue_amount) as realized_revenue_amount
    from {{ ref('fact_revenue') }}
    group by 1, 2, 3
)

select
    b.service_date,
    b.location_id,
    b.vehicle_class,
    b.booking_count,
    b.cancelled_booking_count,
    u.available_vehicle_count,
    u.maintenance_vehicle_count,
    r.realized_revenue_amount,
    case
        when b.booking_count = 0 then 0
        else round(b.cancelled_booking_count / b.booking_count, 4)
    end as cancellation_rate
from booking_base b
left join utilization u
  on b.service_date = u.service_date
 and b.location_id = u.location_id
 and b.vehicle_class = u.vehicle_class
left join revenue r
  on b.service_date = r.service_date
 and b.location_id = r.location_id
 and b.vehicle_class = r.vehicle_class
