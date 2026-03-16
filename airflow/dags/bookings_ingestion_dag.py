from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from src.ingestion.bookings_api import run as run_bookings


with DAG(
    dag_id="bookings_ingestion",
    start_date=datetime(2026, 3, 1),
    schedule="*/30 * * * *",
    catchup=False,
    default_args={"retries": 2, "retry_delay": timedelta(minutes=10)},
    tags=["ingestion", "bookings"],
) as dag:
    ingest_bookings = PythonOperator(
        task_id="ingest_bookings",
        python_callable=run_bookings,
        op_kwargs={"start_date": "{{ ds }}", "end_date": "{{ ds }}"},
    )

    ingest_bookings
