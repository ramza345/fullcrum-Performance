#!/usr/bin/env bash
# Sets up Harvey (https://github.com/ethanplusai/harvey) next to this repository.
# Intended for the cloud environment's "Setup script", which starts one
# directory above the repository:   bash fullcrum-Performance/scripts/setup-harvey.sh
# Safe to re-run. Does not configure email or any credentials.
set -euo pipefail

HARVEY_DIR="${HARVEY_DIR:-$(pwd)/harvey}"
PROXY_CA="${PROXY_CA:-/root/.ccr/ca-bundle.crt}"

[ -d "$HARVEY_DIR/.git" ] || git clone -q https://github.com/ethanplusai/harvey.git "$HARVEY_DIR"
cd "$HARVEY_DIR"

[ -d .venv ] || python3.13 -m venv .venv
.venv/bin/pip install -q -e .

# Never overwrite an existing .env
[ -f .env ] || cp .env.example .env

# Harvey's public-website client ignores system CA settings, so behind the
# sandbox's TLS-inspecting proxy `harvey train` fails with CERTIFICATE_VERIFY_FAILED.
# Point its certifi bundle at the proxy CA bundle when that file exists.
if [ -f "$PROXY_CA" ]; then
  certifi_path="$(.venv/bin/python -c 'import certifi; print(certifi.where())')"
  cp "$PROXY_CA" "$certifi_path"
fi

echo "Harvey ready in $HARVEY_DIR (activate with: source $HARVEY_DIR/.venv/bin/activate)"
