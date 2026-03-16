from __future__ import annotations

from pathlib import Path

from src.common.logging import get_logger

logger = get_logger(__name__)


SQL_ASSET_GROUPS = {
    "ddl": ["sql/schema.sql", "sql/warehouse_admin.sql"],
    "marts": ["sql/marts.sql"],
    "tests": ["sql/tests.sql"],
}


def load_sql_asset_group(group_name: str) -> dict[str, str]:
    if group_name not in SQL_ASSET_GROUPS:
        raise ValueError(f"Unknown SQL asset group: {group_name}")
    assets = {}
    for relative_path in SQL_ASSET_GROUPS[group_name]:
        path = Path(relative_path)
        assets[relative_path] = path.read_text(encoding="utf-8")
    logger.info("Loaded SQL asset group", extra={"group_name": group_name, "asset_count": len(assets)})
    return assets
