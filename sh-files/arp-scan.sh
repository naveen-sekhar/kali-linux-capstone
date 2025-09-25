#!/bin/bash
# Create reports directory if it doesn't exist
mkdir -p reports
OUTPUT="reports/arp_scan_report.txt"

echo "Running ARP Scan on local network..."
sudo arp-scan --interface=eth0 --localnet | tee "$OUTPUT"
