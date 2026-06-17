#!/bin/bash

echo "Rebuild r2d2-mcp when Node.js is available"

if command -v node &>/dev/null && [[ -f $R2D2_PATH/mcp/r2d2/package.json ]]; then
  (cd "$R2D2_PATH/mcp/r2d2" && npm ci && npm run build) || true
fi
