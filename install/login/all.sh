#!/bin/bash

run_logged $R2D2_INSTALL/login/plymouth.sh
run_logged $R2D2_INSTALL/login/default-keyring.sh
run_logged $R2D2_INSTALL/login/sddm.sh
run_logged $R2D2_INSTALL/login/limine-snapper.sh
