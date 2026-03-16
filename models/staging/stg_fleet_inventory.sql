select
    vehicle_id,
    vin,
    upper(vehicle_class) as vehicle_class,
    current_location_id,
    lower(fleet_status) as fleet_status,
    cast(rentable_flag as boolean) as rentable_flag,
    cast(updated_at as timestamp) as updated_at
from {{ source('raw', 'fleet_inventory') }}
