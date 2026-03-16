select
    location_id,
    location_name,
    city,
    state,
    region,
    cast(airport_flag as boolean) as airport_flag,
    cast(updated_at as timestamp) as updated_at
from {{ source('raw', 'locations') }}
