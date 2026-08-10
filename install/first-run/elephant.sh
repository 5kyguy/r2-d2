#!/bin/bash

r2-d2-pkg-aur-add elephant
elephant service enable
systemctl --user start elephant.service
