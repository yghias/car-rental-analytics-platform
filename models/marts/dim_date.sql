with dates as (
    select cast(scheduled_pickup_ts as date) as calendar_date
    from {{ ref('stg_bookings') }}
    union
    select cast(scheduled_return_ts as date) as calendar_date
    from {{ ref('stg_bookings') }}
)

select
    calendar_date,
    extract(year from calendar_date) as calendar_year,
    extract(month from calendar_date) as calendar_month,
    extract(day from calendar_date) as day_of_month,
    dayname(calendar_date) as day_name
from dates
