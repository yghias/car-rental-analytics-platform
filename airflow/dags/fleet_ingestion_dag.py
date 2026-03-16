from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from src.ingestion.fleet_api import run as run_fleet


with DAG(
    dag_id="fleet_ingestion",
    start_date=datetime(2026, 3, 1),
    schedule="0 * * * *",
    catchup=False,
    default_args={"retries": 2, "retry_delay": timedelta(minutes=15)},
    tags=["ingestion", "fleet"],
) as dag:
    ingest_fleet = PythonOperator(
        task_id="ingest_fleet",
        python_callable=run_fleet,
        op_kwargs={"snapshot_date": "{{ ds }}"},
    )

    ingest_fleet
