#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_TARGETS_FILE="${DEPLOY_TARGETS_FILE:-$ROOT_DIR/config/deploy-targets.json}"

die() {
  echo "[show-runtime-versions][error] $*" >&2
  exit 1
}

command -v python3 >/dev/null 2>&1 || die "Missing command: python3"
[ -f "$DEPLOY_TARGETS_FILE" ] || die "deploy targets file not found: $DEPLOY_TARGETS_FILE"

python3 - "$DEPLOY_TARGETS_FILE" <<'PY'
import json
import os
import sys
from pathlib import Path

targets_path = Path(sys.argv[1])
data = json.loads(targets_path.read_text(encoding="utf-8"))

rows = []
for service, cfg in sorted(data.items()):
    state_file = Path(str(cfg.get("deployment_state_file", "")).strip())
    state = {}
    if state_file.is_file():
        try:
            state = json.loads(state_file.read_text(encoding="utf-8"))
        except Exception:
            state = {"_error": "invalid-json"}

    container = state.get("container", {}) if isinstance(state, dict) else {}
    rows.append(
        {
            "service": service,
            "runtime_image_name": str(cfg.get("runtime_image_name", "")),
            "release_image_ref": str(state.get("release_image_ref", "")),
            "release_commit_sha": str(state.get("release_commit_sha", "")),
            "release_image_digest": str(state.get("release_image_digest", "")),
            "deployed_at": str(state.get("deployed_at", "")),
            "container_status": str(container.get("status", "")),
            "configured_image": str(container.get("configured_image", "")),
            "state_file": state_file.as_posix(),
        }
    )

headers = [
    "service",
    "runtime_image_name",
    "release_commit_sha",
    "deployed_at",
    "container_status",
    "configured_image",
    "release_image_ref",
]

widths = {h: len(h) for h in headers}
for row in rows:
    for h in headers:
        widths[h] = max(widths[h], len(row[h]))

fmt = "  ".join(f"{{{h}:{widths[h]}}}" for h in headers)
print(fmt.format(**{h: h for h in headers}))
print(fmt.format(**{h: "-" * widths[h] for h in headers}))
for row in rows:
    print(fmt.format(**row))
PY
