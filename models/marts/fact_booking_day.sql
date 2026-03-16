with booking_dates as (
    select
        booking_id,
        pickup_location_id as location_id,
        vehicle_class,
        coalesce(booking_channel, 'unknown') as booking_channel,
        cast(scheduled_pickup_ts as date) as pickup_date,
        cast(scheduled_return_ts as date) as return_date
    from {{ ref('stg_bookings') }}
),
date_spine as (
    select
        booking_id,
        location_id,
        vehicle_class,
        booking_channel,
        pickup_date as service_date
    from booking_dates
)

select
    booking_id,
    service_date,
    location_id,
    vehicle_class,
    booking_channel,
    1 as active_booking_day_count
from date_spine
