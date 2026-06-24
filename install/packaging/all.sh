#!/bin/bash

run_logged $R2D2_INSTALL/packaging/base.sh
run_logged $R2D2_INSTALL/packaging/opencode.sh

if ! r2d2_is_server; then
  run_logged $R2D2_INSTALL/packaging/fonts.sh
  run_logged $R2D2_INSTALL/packaging/icons.sh
  run_logged $R2D2_INSTALL/packaging/webapps.sh
  run_logged $R2D2_INSTALL/packaging/tuis.sh
else
  run_logged $R2D2_INSTALL/packaging/k2so.sh
fi