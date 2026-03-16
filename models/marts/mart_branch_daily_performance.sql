with revenue as (
    select
        location_id,
        vehicle_class,
        service_date,
        sum(realized_revenue_amount) as realized_revenue_amount,
        count(distinct booking_id) as booking_count
    from {{ ref('fact_revenue') }}
    group by 1, 2, 3
),
utilization as (
    select
        location_id,
        vehicle_class,
        snapshot_date as service_date,
        sum(available_vehicle_count) as available_vehicle_count,
        sum(maintenance_vehicle_count) as maintenance_vehicle_count
    from {{ ref('fact_vehicle_utilization') }}
    group by 1, 2, 3
)

select
    r.service_date,
    r.location_id,
    r.vehicle_class,
    r.booking_count,
    r.realized_revenue_amount,
    u.available_vehicle_count,
    u.maintenance_vehicle_count,
    case
        when coalesce(u.available_vehicle_count, 0) = 0 then null
        else round(r.realized_revenue_amount / u.available_vehicle_count, 2)
    end as revenue_per_available_car_day
from revenue r
left join utilization u
  on r.location_id = u.location_id
 and r.vehicle_class = u.vehicle_class
 and r.service_date = u.service_date
