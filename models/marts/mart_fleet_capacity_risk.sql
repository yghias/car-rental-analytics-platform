with utilization as (
    select
        snapshot_date as service_date,
        location_id,
        vehicle_class,
        sum(available_vehicle_count) as available_vehicle_count,
        sum(maintenance_vehicle_count) as maintenance_vehicle_count
    from {{ ref('fact_vehicle_utilization') }}
    group by 1, 2, 3
),
pace as (
    select
        pickup_date as service_date,
        location_id,
        vehicle_class,
        sum(booking_count) as booking_count
    from {{ ref('fact_booking_pace') }}
    group by 1, 2, 3
)

select
    p.service_date,
    p.location_id,
    p.vehicle_class,
    p.booking_count,
    u.available_vehicle_count,
    u.maintenance_vehicle_count,
    p.booking_count - coalesce(u.available_vehicle_count, 0) as booking_supply_gap,
    case
        when p.booking_count > coalesce(u.available_vehicle_count, 0) then 'risk'
        else 'balanced'
    end as capacity_risk_status
from pace p
left join utilization u
  on p.service_date = u.service_date
 and p.location_id = u.location_id
 and p.vehicle_class = u.vehicle_class
