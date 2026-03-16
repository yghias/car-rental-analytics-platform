select
    pickup_date as service_date,
    location_id,
    vehicle_class,
    avg(datediff('day', cast(updated_at as timestamp), cast(pickup_date as timestamp))) as avg_booking_lead_days,
    min(datediff('day', cast(updated_at as timestamp), cast(pickup_date as timestamp))) as min_booking_lead_days,
    max(datediff('day', cast(updated_at as timestamp), cast(pickup_date as timestamp))) as max_booking_lead_days,
    count(distinct booking_id) as booking_count
from {{ ref('fact_booking_pace') }}
group by 1, 2, 3
