select
    customer_id,
    upper(loyalty_tier) as loyalty_tier,
    country_code,
    cast(marketing_opt_in as boolean) as marketing_opt_in,
    cast(updated_at as timestamp) as updated_at
from {{ source('raw', 'customers') }}
