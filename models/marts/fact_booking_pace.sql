select
    cast(scheduled_pickup_ts as date) as pickup_date,
    pickup_location_id as location_id,
    vehicle_class,
    cast(updated_at as date) as booking_created_date,
    count(distinct booking_id) as booking_count
from {{ ref('stg_bookings') }}
group by 1, 2, 3, 4
