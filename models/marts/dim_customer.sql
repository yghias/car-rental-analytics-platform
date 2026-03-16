select
    customer_id,
    loyalty_tier,
    country_code,
    marketing_opt_in
from {{ ref('stg_customers') }}
