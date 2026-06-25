#!/bin/bash

r2-d2-pkg-add elephant
elephant service enable
systemctl --user start elephant.service
