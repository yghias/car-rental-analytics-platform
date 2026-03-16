select
    vehicle_id,
    vin,
    vehicle_class,
    current_location_id as location_id
from {{ ref('stg_fleet_inventory') }}
