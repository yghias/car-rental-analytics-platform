select
    pickup_date as service_date,
    location_id,
    vehicle_class,
    count(distinct booking_id) as total_booking_count,
    sum(case when booking_status <> 'cancelled' then 1 else 0 end) as converted_booking_count,
    sum(case when booking_status = 'cancelled' then 1 else 0 end) as cancelled_booking_count,
    case
        when count(distinct booking_id) = 0 then 0
        else round(
            sum(case when booking_status <> 'cancelled' then 1 else 0 end)
            / count(distinct booking_id),
            4
        )
    end as booking_conversion_rate
from {{ ref('fact_booking') }}
group by 1, 2, 3
