select
    b.pickup_location_id as location_id,
    b.vehicle_class,
    cast(b.scheduled_pickup_ts as date) as service_date,
    coalesce(p.channel, 'unknown') as channel,
    count(distinct b.booking_id) as booking_count,
    avg(p.rate_amount) as avg_rate_amount,
    sum(case when b.booking_status <> 'cancelled' then b.booked_revenue_amount else 0 end) as realized_revenue_amount
from {{ ref('stg_bookings') }} b
left join {{ ref('stg_pricing_events') }} p
  on b.pickup_location_id = p.location_id
 and b.vehicle_class = p.vehicle_class
 and b.scheduled_pickup_ts >= p.effective_start_ts
 and b.scheduled_pickup_ts < p.effective_end_ts
group by 1, 2, 3, 4
