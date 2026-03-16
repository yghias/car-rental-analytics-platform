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
