select
    cast(updated_at as date) as snapshot_date,
    vehicle_id,
    current_location_id as location_id,
    vehicle_class,
    case when fleet_status = 'available' and rentable_flag then 1 else 0 end as available_vehicle_count,
    case when fleet_status = 'maintenance' then 1 else 0 end as maintenance_vehicle_count
from {{ ref('stg_fleet_inventory') }}
