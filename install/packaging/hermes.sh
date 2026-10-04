#!/bin/bash

# Install Hermes Agent via the official installer (~/.hermes).
# Skip the setup wizard; the user can run `hermes setup` after install.
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive
