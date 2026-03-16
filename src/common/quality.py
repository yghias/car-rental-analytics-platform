from __future__ import annotations

from dataclasses import dataclass

import pandas as pd


@dataclass(frozen=True)
class QualityCheckResult:
    check_name: str
    passed: bool
    detail: str


def assert_non_empty(frame: pd.DataFrame, dataset_name: str) -> QualityCheckResult:
    passed = not frame.empty
    detail = f"{dataset_name} row_count={len(frame)}"
    return QualityCheckResult("non_empty", passed, detail)


def assert_required_columns(frame: pd.DataFrame, required: list[str]) -> QualityCheckResult:
    missing = sorted(set(required) - set(frame.columns))
    passed = not missing
    detail = "missing=" + ",".join(missing) if missing else "all_required_present"
    return QualityCheckResult("required_columns", passed, detail)
