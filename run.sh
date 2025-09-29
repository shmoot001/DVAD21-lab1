#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  printf "Please run as root\n"
  printf "For example: sudo $0\n"
  exit
fi

sysctl -w net.mptcp.mptcp_enabled=0
sysctl -w net.ipv4.tcp_congestion_control=cubic
sysctl -w net.ipv4.tcp_min_tso_segs=1

# Stop the ovs controller if it's running, as it interferes with mininet
#pkill ovs-testcontrol

python3 network.py

echo "cleaning up..."
pkill xterm
mn -c &> /dev/null
