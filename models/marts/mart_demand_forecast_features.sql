select
    b.pickup_location_id as location_id,
    b.vehicle_class,
    cast(b.scheduled_pickup_ts as date) as service_date,
    count(distinct b.booking_id) as booking_count,
    avg(p.rate_amount) as avg_rate_amount
from {{ ref('stg_bookings') }} b
left join {{ ref('stg_pricing_events') }} p
  on b.pickup_location_id = p.location_id
 and b.vehicle_class = p.vehicle_class
group by 1, 2, 3
