from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

from src.common.logging import get_logger
from src.common.warehouse import upsert_dataframe

logger = get_logger(__name__)


def run(file_path: str, target_table: str) -> None:
    path = Path(file_path)
    if path.suffix.lower() == ".csv":
        frame = pd.read_csv(path)
    elif path.suffix.lower() == ".parquet":
        frame = pd.read_parquet(path)
    else:
        raise ValueError(f"Unsupported file extension for {path}")
    upsert_dataframe(target_table, frame)
    logger.info("Loaded file drop", extra={"file_path": file_path, "target_table": target_table, "row_count": len(frame)})


def main() -> None:
    parser = argparse.ArgumentParser(description="Load CSV or parquet file drop")
    parser.add_argument("--file-path", required=True)
    parser.add_argument("--target-table", required=True)
    args = parser.parse_args()
    run(args.file_path, args.target_table)


if __name__ == "__main__":
    main()
