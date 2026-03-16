with daily_actuals as (
    select
        pickup_location_id as location_id,
        vehicle_class,
        cast(scheduled_pickup_ts as date) as service_date,
        count(distinct booking_id) as actual_booking_count
    from {{ ref('stg_bookings') }}
    where booking_status <> 'cancelled'
    group by 1, 2, 3
),
forecast_features as (
    select
        location_id,
        vehicle_class,
        service_date,
        booking_count,
        avg_rate_amount
    from {{ ref('mart_demand_forecast_features') }}
)

select
    a.location_id,
    a.vehicle_class,
    a.service_date,
    a.actual_booking_count,
    round(coalesce(f.booking_count, 0) * 1.03, 2) as forecasted_booking_count,
    round(abs(a.actual_booking_count - coalesce(f.booking_count, 0) * 1.03), 2) as forecast_error
from daily_actuals a
left join forecast_features f
  on a.location_id = f.location_id
 and a.vehicle_class = f.vehicle_class
 and a.service_date = f.service_date
