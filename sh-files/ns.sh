#!/usr/bin/env bash
# ns - merged network reconnaissance script (Experiments 1-6)
# Usage: ./ns <target-ip-or-subnet>
# Example: ./ns 192.168.1.1
#          ./ns 192.168.1.0/24
#
# The script runs:
# Experiment 1 - Ping sweep (nmap -sn) on provided subnet or derived /24 for single IP
# Experiment 2 - TCP port scan (nmap -sS)
# Experiment 3 - UDP port scan (nmap -sU)
# Experiment 4 - OS detection (nmap -O)
# Experiment 5 - Service version detection (nmap -sV)
# Experiment 6 - Banner grabbing (netcat)
#
# Output:
# A structured text file named results_<target>_<timestamp>.txt is created in current directory.
# The script also prints progress messages to stdout.
set -euo pipefail
IFS=$'\n\t'

print_err() { printf "%s\n" "$*" >&2; }

if [[ $# -lt 1 ]]; then
  print_err "Usage: $0 <target-ip-or-subnet>"
  print_err "Examples:"
  print_err "  $0 192.168.1.1"
  print_err "  $0 192.168.1.0/24"
  exit 2
fi

TARGET="$1"
# Create reports directory if it doesn't exist
mkdir -p reports
RESULT_FILE="reports/network_scan_report.txt"

echo "=== NS Recon Script ===" | tee "$RESULT_FILE"
echo "Target: $TARGET" | tee -a "$RESULT_FILE"
echo "Timestamp: $(date -R)" | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

# Helper to run a command, time it, and append header/footer to result file
run_section() {
  local title="$1"; shift
  local cmd="$*"
  echo "------------------------------------------------------------" | tee -a "$RESULT_FILE"
  echo ">>> $title" | tee -a "$RESULT_FILE"
  echo "Command: $cmd" | tee -a "$RESULT_FILE"
  echo "Start: $(date -R)" | tee -a "$RESULT_FILE"
  echo "" | tee -a "$RESULT_FILE"
  # Run the command and capture both stdout and stderr
  # Use timeout to avoid hangs (where appropriate)
  eval "$cmd" >> "$RESULT_FILE" 2>&1 || echo "[note] command exited with non-zero status" | tee -a "$RESULT_FILE"
  echo "" | tee -a "$RESULT_FILE"
  echo "End: $(date -R)" | tee -a "$RESULT_FILE"
  echo "" | tee -a "$RESULT_FILE"
}

# Determine whether TARGET is a CIDR subnet or single IP
is_cidr() {
  [[ "$TARGET" =~ .+/.+ ]]
}

# For single IP, derive /24 network for the ping sweep
derive_subnet_from_ip() {
  local ip="$1"
  # assume IPv4 dotted quad
  IFS='.' read -r a b c d <<< "$ip"
  echo "${a}.${b}.${c}.0/24"
}

# Check for required tools
MISSING_TOOLS=()
for tool in nmap nc; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    MISSING_TOOLS+=("$tool")
  fi
done

if [[ ${#MISSING_TOOLS[@]} -ne 0 ]]; then
  echo "[warning] Missing tools: ${MISSING_TOOLS[*]}. The script will still attempt available scans but some steps may fail." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 1: Ping Sweep of a Subnet
if is_cidr; then
  SUBNET="$TARGET"
else
  SUBNET=$(derive_subnet_from_ip "$TARGET")
fi
if command -v nmap >/dev/null 2>&1; then
  run_section "Experiment 1: Ping Sweep of subnet $SUBNET" "nmap -sn \"$SUBNET\""
else
  echo "[skip] nmap not available; skipping Experiment 1 (Ping Sweep)." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 2: TCP Port Scan
if command -v nmap >/dev/null 2>&1; then
  # Use -Pn to prevent host discovery if desired; here we let nmap decide.
  # -sS requires root for raw sockets; if not root, fall back to -sT (TCP connect scan)
  if [[ $EUID -eq 0 ]]; then
    TCP_CMD="nmap -sS -p- --min-rate 1000 \"$TARGET\""
  else
    TCP_CMD="nmap -sT -p- --min-rate 1000 \"$TARGET\""
  fi
  run_section "Experiment 2: TCP Port Scan of $TARGET" "$TCP_CMD"
else
  echo "[skip] nmap not available; skipping Experiment 2 (TCP Port Scan)." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 3: UDP Port Scan
if command -v nmap >/dev/null 2>&1; then
  # UDP scans are slow; limit common ports for practical runtime
  # We'll scan top 200 common UDP ports to limit time
  run_section "Experiment 3: UDP Port Scan of $TARGET (top 200 UDP ports; may be slow)" "nmap -sU --top-ports 200 \"$TARGET\" -oG -"
else
  echo "[skip] nmap not available; skipping Experiment 3 (UDP Port Scan)." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 4: OS Detection
if command -v nmap >/dev/null 2>&1; then
  if [[ $EUID -eq 0 ]]; then
    run_section "Experiment 4: OS Detection of $TARGET" "nmap -O \"$TARGET\""
  else
    echo "[notice] OS detection (-O) usually requires root. Attempting it but results may be limited." | tee -a "$RESULT_FILE"
    run_section "Experiment 4: OS Detection of $TARGET (non-root attempt)" "nmap -O \"$TARGET\""
  fi
else
  echo "[skip] nmap not available; skipping Experiment 4 (OS Detection)." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 5: Service Version Detection
if command -v nmap >/dev/null 2>&1; then
  run_section "Experiment 5: Service Version Detection of $TARGET" "nmap -sV \"$TARGET\""
else
  echo "[skip] nmap not available; skipping Experiment 5 (Service Version Detection)." | tee -a "$RESULT_FILE"
fi

# EXPERIMENT 6: Banner Grabbing (netcat)
if command -v nc >/dev/null 2>&1; then
  # Try grabbing banners for a few common TCP ports found earlier (22,80,443,53,21)
  PORTS=(22 21 25 80 110 143 443 3306 3389)
  echo "------------------------------------------------------------" | tee -a "$RESULT_FILE"
  echo ">>> Experiment 6: Banner Grabbing (netcat)" | tee -a "$RESULT_FILE"
  echo "Start: $(date -R)" | tee -a "$RESULT_FILE"
  echo "" | tee -a "$RESULT_FILE"
  for p in "${PORTS[@]}"; do
    echo "--- Banner grabbing $TARGET:$p ---" | tee -a "$RESULT_FILE"
    # Use a short timeout to avoid long waits
    (echo -e "\r\n" | timeout 3 nc -w 3 "$TARGET" "$p") >> "$RESULT_FILE" 2>&1 || echo "[note] no banner or connection refused on port $p" | tee -a "$RESULT_FILE"
    echo "" | tee -a "$RESULT_FILE"
  done
  echo "End: $(date -R)" | tee -a "$RESULT_FILE"
  echo "" | tee -a "$RESULT_FILE"
else
  echo "[skip] netcat (nc) not available; skipping Experiment 6 (Banner Grabbing)." | tee -a "$RESULT_FILE"
fi

echo "All experiments complete. Results saved in: $RESULT_FILE" | tee -a "$RESULT_FILE"
echo "Note: Some nmap options (e.g., -sS, -O) may require root privileges to be fully effective." | tee -a "$RESULT_FILE"
