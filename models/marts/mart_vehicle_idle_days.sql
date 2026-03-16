with daily_activity as (
    select
        snapshot_date as service_date,
        vehicle_id,
        location_id,
        vehicle_class,
        available_vehicle_count,
        reserved_vehicle_count
    from {{ ref('fact_vehicle_utilization') }}
)

select
    service_date,
    vehicle_id,
    location_id,
    vehicle_class,
    available_vehicle_count,
    reserved_vehicle_count,
    case
        when available_vehicle_count = 1 and reserved_vehicle_count = 0 then 1
        else 0
    end as idle_vehicle_day_flag
from daily_activity
