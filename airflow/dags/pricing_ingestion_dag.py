from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from src.ingestion.pricing_api import run as run_pricing


with DAG(
    dag_id="pricing_ingestion",
    start_date=datetime(2026, 3, 1),
    schedule="*/15 * * * *",
    catchup=False,
    default_args={"retries": 2, "retry_delay": timedelta(minutes=10)},
    tags=["ingestion", "pricing"],
) as dag:
    ingest_pricing = PythonOperator(task_id="ingest_pricing", python_callable=run_pricing)

    ingest_pricing
