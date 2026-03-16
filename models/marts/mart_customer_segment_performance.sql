select
    b.pickup_date as service_date,
    b.location_id,
    b.vehicle_class,
    c.loyalty_tier,
    c.country_code,
    count(distinct b.booking_id) as booking_count,
    sum(r.realized_revenue_amount) as realized_revenue_amount,
    round(avg(r.realized_revenue_amount), 2) as avg_revenue_per_booking
from {{ ref('fact_booking') }} b
left join {{ ref('dim_customer') }} c
  on b.customer_id = c.customer_id
left join {{ ref('fact_revenue') }} r
  on b.booking_id = r.booking_id
group by 1, 2, 3, 4, 5
