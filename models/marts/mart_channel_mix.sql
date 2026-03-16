select
    service_date,
    location_id,
    vehicle_class,
    booking_channel,
    sum(active_booking_day_count) as active_booking_day_count,
    row_number() over (
        partition by service_date, location_id, vehicle_class
        order by sum(active_booking_day_count) desc
    ) as booking_channel_rank
from {{ ref('fact_booking_day') }}
group by 1, 2, 3, 4
