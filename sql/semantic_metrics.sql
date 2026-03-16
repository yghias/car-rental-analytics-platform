create or replace view marts.semantic_metrics_daily as
select
    k.service_date,
    k.location_id,
    l.region,
    k.vehicle_class,
    k.booking_count,
    k.cancelled_booking_count,
    k.available_vehicle_count,
    k.maintenance_vehicle_count,
    k.realized_revenue_amount,
    case
        when k.booking_count = 0 then 0
        else round(k.cancelled_booking_count / k.booking_count, 4)
    end as cancellation_rate,
    case
        when coalesce(k.available_vehicle_count, 0) = 0 then null
        else round(k.realized_revenue_amount / k.available_vehicle_count, 2)
    end as revenue_per_available_car_day,
    case
        when coalesce(k.available_vehicle_count, 0) = 0 then null
        else round(k.booking_count / k.available_vehicle_count, 4)
    end as booking_to_supply_ratio
from marts.mart_operational_kpis k
left join marts.dim_location l
  on k.location_id = l.location_id;

create or replace view marts.semantic_metrics_forecast as
select
    f.service_date,
    f.location_id,
    f.vehicle_class,
    f.actual_booking_count,
    f.forecasted_booking_count,
    f.forecast_error,
    case
        when f.actual_booking_count = 0 then null
        else round(1 - abs(f.forecast_error) / f.actual_booking_count, 4)
    end as forecast_accuracy
from marts.fact_forecast_actual f;
