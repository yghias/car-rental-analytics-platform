select
    r.service_date,
    l.region,
    r.vehicle_class,
    sum(r.realized_revenue_amount) as realized_revenue_amount,
    count(distinct r.booking_id) as booking_count,
    lag(sum(r.realized_revenue_amount)) over (
        partition by l.region, r.vehicle_class
        order by r.service_date
    ) as prior_day_regional_revenue
from {{ ref('fact_revenue') }} r
left join {{ ref('dim_location') }} l
  on r.location_id = l.location_id
group by 1, 2, 3
