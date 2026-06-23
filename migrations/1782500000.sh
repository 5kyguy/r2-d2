#!/bin/bash

echo "Fix K-2SO OpenCode install: file-based Z.AI key, merge instead of clobber"

r2-d2-ensure-k2so-secrets
r2-d2-merge-k2so-opencode
