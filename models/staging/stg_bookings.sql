select
    booking_id,
    customer_id,
    pickup_location_id,
    return_location_id,
    'unknown' as booking_channel,
    upper(vehicle_class) as vehicle_class,
    lower(booking_status) as booking_status,
    cast(scheduled_pickup_ts as timestamp) as scheduled_pickup_ts,
    cast(scheduled_return_ts as timestamp) as scheduled_return_ts,
    cast(booked_revenue_amount as numeric(12,2)) as booked_revenue_amount,
    cast(updated_at as timestamp) as updated_at
from {{ source('raw', 'bookings') }}
