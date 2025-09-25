#!/bin/bash
# Vulnerability Scan Script using Nmap in Kali Linux
# Usage: ./vuln_scan.sh <target_ip_or_domain>

# Check if target IP or domain is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target_ip_or_domain>"
  exit 1
fi

TARGET="$1"
# Create reports directory if it doesn't exist
mkdir -p reports
OUTPUT="reports/vuln_scan_report.txt"

echo "===================================" | tee -a "$OUTPUT"
echo " Starting Vulnerability Scan"     | tee -a "$OUTPUT"
echo " Target: $TARGET"                 | tee -a "$OUTPUT"
echo " Date: $(date)"                   | tee -a "$OUTPUT"
echo "===================================" | tee -a "$OUTPUT"

# Step 1: Basic Port Scan
echo -e "\n[+] Running Port Scan..." | tee -a "$OUTPUT"
nmap -sS -Pn -p- --open "$TARGET" 2>&1 | tee -a "$OUTPUT"

# Step 2: Service Version Detection
echo -e "\n[+] Detecting Service Versions..." | tee -a "$OUTPUT"
nmap -sV "$TARGET" 2>&1 | tee -a "$OUTPUT"

# Step 3: OS Detection
echo -e "\n[+] Detecting Operating System..." | tee -a "$OUTPUT"
nmap -O "$TARGET" 2>&1 | tee -a "$OUTPUT"

# Step 4: Vulnerability Scan using Nmap Scripts
echo -e "\n[+] Running Vulnerability Scan with Nmap Scripts..." | tee -a "$OUTPUT"
nmap --script vuln "$TARGET" 2>&1 | tee -a "$OUTPUT"

# Step 5: HTTP Vulnerabilities (if HTTP found)
echo -e "\n[+] Checking for HTTP vulnerabilities..." | tee -a "$OUTPUT"
nmap -p 80,443 --script http-vuln* "$TARGET" 2>&1 | tee -a "$OUTPUT"

echo -e "\n===================================" | tee -a "$OUTPUT"
echo " Vulnerability Scan Completed"     | tee -a "$OUTPUT"
echo " Report saved to: $OUTPUT"
echo "===================================" | tee -a "$OUTPUT"
