from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="warehouse_transform",
    start_date=datetime(2026, 3, 1),
    schedule="15 * * * *",
    catchup=False,
    default_args={"retries": 1, "retry_delay": timedelta(minutes=10)},
    tags=["transform", "warehouse"],
) as dag:
    build_models = BashOperator(
        task_id="build_models",
        bash_command="echo 'Run dbt build for staging and marts'",
    )

    quality_checks = BashOperator(
        task_id="quality_checks",
        bash_command="echo 'Run SQL quality checks and reconciliations'",
    )

    build_models >> quality_checks
