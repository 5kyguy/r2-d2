#!/bin/bash

if r2d2_is_server; then
  run_logged $R2D2_INSTALL/login/server.sh
else
  run_logged $R2D2_INSTALL/login/plymouth.sh
  run_logged $R2D2_INSTALL/login/default-keyring.sh
  run_logged $R2D2_INSTALL/login/sddm.sh
  run_logged $R2D2_INSTALL/login/limine-snapper.sh
fi