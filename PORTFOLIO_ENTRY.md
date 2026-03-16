# Portfolio Entry

## Business Problem

Car rental businesses need accurate, timely visibility into bookings, fleet availability, maintenance downtime, and pricing changes to maximize asset utilization and revenue. In practice, these signals are often fragmented across operational systems and spreadsheets, making it difficult to manage supply-demand balance or trust executive reporting.

## Solution

`car-rental-analytics-platform` is a production-style cloud data platform that consolidates reservation, fleet, pricing, customer, maintenance, and location data from batch APIs, file feeds, and Kafka event streams. It lands raw data in cloud storage, standardizes and models it in a warehouse, and publishes curated marts for utilization analytics, revenue reporting, pricing analysis, demand forecasting, and operational dashboards.

## Stack

- Python
- Kafka
- Airflow
- Snowflake or Redshift
- dbt-style SQL modeling
- Terraform
- GitHub Actions
- Docker

## Highlights

- Near-real-time booking, fleet, and pricing event processing
- Canonical data modeling and dimensional marts
- Forecasting feature generation for demand planning
- Governance, observability, SLAs, backfills, and security design
- Documentation written like a real internal engineering project
