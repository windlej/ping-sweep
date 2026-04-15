#!/bin/bash

# ping-sweep.sh
if [ -z "$1" ]; then
  echo "Usage: $0 <CIDR>"
  exit 1
fi

cidr=$1
live_hosts=()
dead_hosts=()

for ip in $(nmap -sL $cidr | grep 'Nmap scan report' | awk '{print $5}'); do
    if ping -c 1 $ip > /dev/null 2>&1; then
        live_hosts+=($ip)
    else
        dead_hosts+=($ip)
    fi
done

echo "IP Address,Status" > ping_sweep_results.csv
for ip in "${live_hosts[@]}"; do
    echo "$ip,Live" >> ping_sweep_results.csv
done
for ip in "${dead_hosts[@]}"; do
    echo "$ip,Dead" >> ping_sweep_results.csv
done

echo "Results saved to ping_sweep_results.csv"
