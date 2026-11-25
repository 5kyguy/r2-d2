#!/bin/bash

# Voxtype is a base package. Download small.en and start the user service.
# Non-fatal: a failed or slow model download must not abort the install —
# r2-d2-update-sync-pkgs retries provisioning on the next update.
r2-d2-voxtype-setup || true
