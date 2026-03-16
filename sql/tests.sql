select booking_id, count(*)
from core.booking
group by booking_id
having count(*) > 1;

select *
from core.booking
where pickup_location_id is null
   or return_location_id is null;

select *
from core.maintenance_event
where closed_at < opened_at;

select *
from marts.fact_revenue
where realized_revenue_amount < 0;

select
    location_id,
    vehicle_class,
    channel,
    effective_start_ts,
    effective_end_ts
from core.pricing_event
where effective_end_ts <= effective_start_ts;

select
    p1.location_id,
    p1.vehicle_class,
    p1.channel,
    p1.pricing_event_id as left_pricing_event_id,
    p2.pricing_event_id as right_pricing_event_id
from core.pricing_event p1
join core.pricing_event p2
  on p1.location_id = p2.location_id
 and p1.vehicle_class = p2.vehicle_class
 and p1.channel = p2.channel
 and p1.pricing_event_id < p2.pricing_event_id
 and p1.effective_start_ts < p2.effective_end_ts
 and p2.effective_start_ts < p1.effective_end_ts;

select
    pickup_date,
    location_id,
    vehicle_class
from marts.fact_booking_pace
group by 1, 2, 3
having sum(booking_count) = 0;

select
    service_date,
    location_id,
    vehicle_class,
    available_vehicle_count,
    maintenance_vehicle_count
from marts.mart_operational_kpis
where maintenance_vehicle_count > available_vehicle_count
  and available_vehicle_count is not null;
