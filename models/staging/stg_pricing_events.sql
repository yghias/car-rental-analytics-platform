select
    pricing_event_id,
    location_id,
    upper(vehicle_class) as vehicle_class,
    channel,
    cast(rate_amount as numeric(12,2)) as rate_amount,
    cast(effective_start_ts as timestamp) as effective_start_ts,
    cast(effective_end_ts as timestamp) as effective_end_ts,
    cast(updated_at as timestamp) as updated_at
from {{ source('raw', 'pricing_events') }}
