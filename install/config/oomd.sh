#!/bin/bash

# Enable systemd-oomd and mark only app.slice as a kill candidate so runaway
# apps die instead of taking the compositor with them.

sudo mkdir -p /usr/lib/systemd/user/app.slice.d /etc/systemd/oomd.conf.d
sudo cp "$R2D2_PATH/default/systemd/user/app.slice.d/10-oomd.conf" /usr/lib/systemd/user/app.slice.d/10-oomd.conf
sudo cp "$R2D2_PATH/default/etc/systemd/oomd.conf.d/10-r2-d2.conf" /etc/systemd/oomd.conf.d/10-r2-d2.conf

sudo systemctl enable --now systemd-oomd.service
