select
    service_date,
    location_id,
    vehicle_class,
    channel,
    booking_count,
    avg_rate_amount,
    realized_revenue_amount,
    lag(avg_rate_amount) over (
        partition by location_id, vehicle_class, channel
        order by service_date
    ) as prior_day_avg_rate_amount,
    realized_revenue_amount - lag(realized_revenue_amount) over (
        partition by location_id, vehicle_class, channel
        order by service_date
    ) as revenue_delta_vs_prior_day
from {{ ref('fact_pricing_effectiveness') }}
