from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime


@dataclass(frozen=True)
class JobRunMetadata:
    job_name: str
    run_id: str
    started_at: datetime
    window_start: str | None = None
    window_end: str | None = None


def build_job_metadata(job_name: str, window_start: str | None = None, window_end: str | None = None) -> JobRunMetadata:
    started_at = datetime.now(tz=UTC)
    run_id = f"{job_name}_{started_at:%Y%m%dT%H%M%S}"
    return JobRunMetadata(job_name=job_name, run_id=run_id, started_at=started_at, window_start=window_start, window_end=window_end)
