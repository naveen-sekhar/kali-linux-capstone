#!/bin/bash

TARGET=$1

echo "Network Scanning and recnnoissance on $TARGET..."
bash ns.sh "$TARGET"

echo "Vulnerability scanning  on $TARGET..."
bash vuln.sh "$TARGET"

echo "Exploitation analysis on $TARGET..."
bash exploit.sh "$TARGET"

echo "ARP Scan..."
bash arp-scan.sh

echo "[*] All scripts executed successfully."
