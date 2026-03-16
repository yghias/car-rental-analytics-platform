with kpis as (
    select
        service_date,
        location_id,
        vehicle_class,
        booking_count,
        cancelled_booking_count,
        available_vehicle_count,
        maintenance_vehicle_count,
        realized_revenue_amount,
        cancellation_rate
    from {{ ref('mart_operational_kpis') }}
),
forecast as (
    select
        service_date,
        location_id,
        vehicle_class,
        forecasted_booking_count,
        forecast_error
    from {{ ref('fact_forecast_actual') }}
)

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
    k.cancellation_rate,
    f.forecasted_booking_count,
    f.forecast_error,
    case
        when coalesce(k.available_vehicle_count, 0) = 0 then null
        else round(k.realized_revenue_amount / k.available_vehicle_count, 2)
    end as revenue_per_available_car_day
from kpis k
left join forecast f
  on k.service_date = f.service_date
 and k.location_id = f.location_id
 and k.vehicle_class = f.vehicle_class
left join {{ ref('dim_location') }} l
  on k.location_id = l.location_id
