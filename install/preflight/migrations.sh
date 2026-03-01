#!/bin/bash

# Prepare migration state directory. Migrations are run at end of install (omarchy-migrate).
OMARCHY_MIGRATIONS_STATE_PATH=~/.local/state/omarchy/migrations
mkdir -p $OMARCHY_MIGRATIONS_STATE_PATH
