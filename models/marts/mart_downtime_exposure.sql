select
    m.location_id,
    v.vehicle_class,
    sum(m.downtime_hours) as total_downtime_hours,
    sum(m.estimated_cost_amount) as maintenance_cost_amount,
    count(distinct m.vehicle_id) as impacted_vehicle_count
from {{ ref('fact_maintenance_downtime') }} m
left join {{ ref('dim_vehicle') }} v
  on m.vehicle_id = v.vehicle_id
group by 1, 2
