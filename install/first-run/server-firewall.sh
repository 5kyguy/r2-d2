#!/bin/bash

# Allow nothing in, everything out
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow OpenSSH

# Allow Docker containers to use DNS on host
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'

sudo ufw --force enable
sudo systemctl enable ufw

sudo ufw-docker install
sudo ufw reload