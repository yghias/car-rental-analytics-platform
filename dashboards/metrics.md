# Dashboard Metrics

## Fleet Utilization Rate

Definition:
`active_rental_vehicle_days / total_rentable_vehicle_days`

Business use:
- monitor asset productivity by branch and vehicle class

## Revenue per Available Car Day

Definition:
`realized_revenue / available_car_days`

Business use:
- compare commercial yield across branches independent of fleet size

## Booking Cancellation Rate

Definition:
`cancelled_bookings / total_bookings`

Business use:
- identify volatility in booking demand and branch-specific operational risk

## Maintenance Downtime Hours

Definition:
`sum(closed_at - opened_at)` across maintenance events

Business use:
- quantify capacity loss and maintenance impact by branch and vehicle class

## Forecast Accuracy

Definition:
`1 - abs(actual_bookings - forecasted_bookings) / nullif(actual_bookings, 0)`

Business use:
- validate demand planning quality and identify under-modeled locations
