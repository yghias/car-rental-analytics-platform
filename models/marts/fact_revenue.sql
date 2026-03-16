select
    booking_id,
    pickup_location_id as location_id,
    vehicle_class,
    cast(scheduled_pickup_ts as date) as service_date,
    booked_revenue_amount as realized_revenue_amount
from {{ ref('stg_bookings') }}
where booking_status <> 'cancelled'
