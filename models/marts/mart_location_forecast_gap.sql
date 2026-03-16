select
    service_date,
    location_id,
    vehicle_class,
    actual_booking_count,
    forecasted_booking_count,
    forecast_error,
    case
        when actual_booking_count = 0 then null
        else round(abs(forecast_error) / actual_booking_count, 4)
    end as forecast_error_pct
from {{ ref('fact_forecast_actual') }}
