select
    maintenance_event_id,
    vehicle_id,
    location_id,
    maintenance_type,
    cast(opened_at as timestamp) as opened_at,
    cast(closed_at as timestamp) as closed_at,
    cast(estimated_cost_amount as numeric(12,2)) as estimated_cost_amount
from {{ source('raw', 'maintenance_events') }}
