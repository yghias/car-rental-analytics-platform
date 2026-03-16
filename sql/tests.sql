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

select
    service_date,
    location_id,
    vehicle_class,
    booking_conversion_rate
from marts.mart_booking_conversion
where booking_conversion_rate < 0
   or booking_conversion_rate > 1;

select
    service_date,
    location_id,
    vehicle_class,
    booking_channel,
    booking_channel_rank
from marts.mart_channel_mix
where booking_channel_rank < 1;

select
    service_date,
    location_id,
    vehicle_class,
    forecast_error_pct
from marts.mart_location_forecast_gap
where forecast_error_pct > 2;

select
    location_id,
    vehicle_class,
    total_downtime_hours,
    impacted_vehicle_count
from marts.mart_downtime_exposure
where impacted_vehicle_count = 0
  and total_downtime_hours > 0;
