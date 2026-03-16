select
    service_date,
    location_id,
    vehicle_class,
    sum(realized_revenue_amount) as realized_revenue_amount,
    sum(booked_revenue_amount) as booked_revenue_amount,
    count(distinct booking_id) as booking_count,
    round(avg(realized_revenue_amount), 2) as avg_revenue_per_booking
from {{ ref('fact_revenue') }}
group by 1, 2, 3
