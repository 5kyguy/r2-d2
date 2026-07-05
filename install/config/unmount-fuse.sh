#!/bin/bash

# Install the FUSE unmount system-sleep hook so gvfsd-fuse doesn't block
# suspend/hibernate. The hook lazy-unmounts fuse.gvfsd-fuse on pre-sleep and
# restarts gvfs-daemon on post-wake. See default/systemd/system-sleep/unmount-fuse.

sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$R2D2_PATH/default/systemd/system-sleep/unmount-fuse" /usr/lib/systemd/system-sleep/
