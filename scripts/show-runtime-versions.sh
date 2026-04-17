#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS_FILE="${1:-$ROOT_DIR/config/deploy-targets.json}"

[ -f "$TARGETS_FILE" ] || {
  echo "[show-runtime-versions][error] targets file not found: $TARGETS_FILE" >&2
  exit 1
}

python3 - "$TARGETS_FILE" <<'PY'
import json
import sys
from pathlib import Path

targets_path = Path(sys.argv[1])
data = json.loads(targets_path.read_text(encoding="utf-8"))

headers = ["service", "runtime_image", "release_tag", "commit_sha", "deployed_at", "container_image"]
rows = []

for service in sorted(data):
    target = data[service]
    state_file = Path(target.get("deployment_state_file", ""))
    runtime_image = target.get("runtime_image_name", "")
    release_tag = ""
    commit_sha = ""
    deployed_at = ""
    container_image = ""
    if state_file.is_file():
        state = json.loads(state_file.read_text(encoding="utf-8"))
        release_tag = state.get("release_image_tag", "")
        commit_sha = state.get("release_commit_sha", "")
        deployed_at = state.get("deployed_at", "")
        container_image = state.get("container", {}).get("configured_image", "")
    rows.append([service, runtime_image, release_tag, commit_sha, deployed_at, container_image])

widths = [len(h) for h in headers]
for row in rows:
    for idx, value in enumerate(row):
        widths[idx] = max(widths[idx], len(str(value)))

def render(row):
    return "  ".join(str(value).ljust(widths[idx]) for idx, value in enumerate(row))

print(render(headers))
print("  ".join("-" * width for width in widths))
for row in rows:
    print(render(row))
PY
