select
    location_id,
    location_name,
    city,
    state,
    region,
    airport_flag
from {{ ref('stg_locations') }}
