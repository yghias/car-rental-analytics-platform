select
    maintenance_event_id,
    vehicle_id,
    location_id,
    maintenance_type,
    datediff('hour', opened_at, closed_at) as downtime_hours,
    estimated_cost_amount
from {{ ref('stg_maintenance_events') }}
