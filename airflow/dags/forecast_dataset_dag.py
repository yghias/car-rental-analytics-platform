from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="forecast_dataset_refresh",
    start_date=datetime(2026, 3, 1),
    schedule="0 6 * * *",
    catchup=False,
    default_args={"retries": 1, "retry_delay": timedelta(minutes=30)},
    tags=["ml", "forecasting"],
) as dag:
    generate_features = BashOperator(
        task_id="generate_features",
        bash_command="echo 'Generate forecast feature snapshots'",
    )

    score_model = BashOperator(
        task_id="score_forecast",
        bash_command="echo 'Score demand forecast model'",
    )

    generate_features >> score_model
