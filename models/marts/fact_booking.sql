select
    b.booking_id,
    b.customer_id,
    b.pickup_location_id as location_id,
    b.vehicle_class,
    b.booking_status,
    date_trunc('day', b.scheduled_pickup_ts) as pickup_date,
    date_trunc('day', b.scheduled_return_ts) as return_date,
    datediff('day', b.scheduled_pickup_ts, b.scheduled_return_ts) as scheduled_rental_days,
    b.booked_revenue_amount
from {{ ref('stg_bookings') }} b
