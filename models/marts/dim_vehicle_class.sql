select distinct
    vehicle_class
from {{ ref('stg_fleet_inventory') }}
