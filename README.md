# Network Security Assessment Tool - Capstone Project

A comprehensive security assessment toolkit that performs automated network scanning, vulnerability assessment, and exploitation analysis with a web-based dashboard for report visualization.

## 🚀 Features

- **ARP Network Discovery**: Scan local network for active hosts
- **Network Reconnaissance**: Comprehensive port scanning, OS detection, and service enumeration
- **Vulnerability Assessment**: Automated vulnerability scanning using Nmap scripts
- **Exploitation Analysis**: Metasploit-based exploitation attempts
- **Web Dashboard**: Real-time report viewing with interactive interface

## 📁 Directory Structure

```
capstone/
├── README.md                      # This file
├── index.html                     # Web dashboard for viewing reports
├── sh-files/                      # Shell scripts directory
│   ├── test.sh                    # Main integration script (runs all scans)
│   ├── arp-scan.sh                # ARP network discovery script
│   ├── ns.sh                      # Network reconnaissance script
│   ├── vuln.sh                    # Vulnerability scanning script
│   └── exploit.sh                 # Exploitation analysis script
└── reports/                       # Generated reports directory
    ├── arp_scan_report.txt        # ARP scan results
    ├── network_scan_report.txt    # Network reconnaissance results
    ├── vuln_scan_report.txt       # Vulnerability scan results
    └── exploit/                   # Exploitation reports
        ├── full_scan_report.txt   # Complete scan log
        ├── recon_report.txt       # Reconnaissance results
        ├── msf_output_report.txt  # Metasploit output
        └── auto_exploit_script.rc # Generated MSF resource script
```

## 🛠️ Prerequisites

### Required Tools (Kali Linux)
```bash
# Install required packages
sudo apt update
sudo apt install -y nmap netcat arp-scan metasploit-framework
```

### For Web Dashboard
- Python 3.x (for local HTTP server)
- Network access to target systems

## ⚙️ Installation

1. **Clone or download the project files**:
   ```bash
   git clone https://github.com/naveen-sekhar/kali-linux-capstone.git
   cd kali-linux-capstone
   ```

2. **Make scripts executable**:
   ```bash
   chmod +x sh-files/*.sh
   ```

## 🚀 Usage

### Option 1: Run Complete Assessment (Recommended)

Run all security assessments on a target:
```bash
# Run complete assessment on a single target
sudo ./sh-files/test.sh <YOUR_TARGET_IP>

# Run complete assessment on a network range
sudo ./sh-files/test.sh 192.168.1.0/24
```

### Option 2: Run Individual Scripts

**ARP Network Discovery:**
```bash
sudo ./sh-files/arp-scan.sh
```

**Network Reconnaissance:**
```bash
sudo ./sh-files/ns.sh 192.168.1.100
# or for network range
sudo ./sh-files/ns.sh 192.168.1.0/24
```

**Vulnerability Scanning:**
```bash
sudo ./sh-files/vuln.sh 192.168.1.100
```

**Exploitation Analysis:**
```bash
sudo ./sh-files/exploit.sh 192.168.1.100
```

## 📊 Viewing Reports

### Method 1: Web Dashboard (Recommended)

1. **Start Python HTTP server** in the project directory:
   ```bash
   # Python 3
   python3 -m http.server 8000
   
   # Python 2 (if needed)
   python -m SimpleHTTPServer 8000
   ```

2. **Open web browser** and navigate to:
   ```
   http://localhost:8000
   ```

3. **View reports** by clicking on the respective sections:
   - 🔍 ARP Network Discovery
   - 🌐 Network Reconnaissance  
   - ⚠️ Vulnerability Assessment
   - 💥 Exploitation Attempts

### Method 2: Command Line

View reports directly from terminal:
```bash
# View ARP scan results
cat reports/arp_scan_report.txt

# View network scan results
cat reports/network_scan_report.txt

# View vulnerability scan results
cat reports/vuln_scan_report.txt

# View exploitation results
cat reports/exploit/full_scan_report.txt
```

## 🔧 Configuration

### Network Interface Configuration

Edit `sh-files/arp-scan.sh` to change network interface:
```bash
# Change eth0 to your network interface (e.g., wlan0)
sudo arp-scan --interface=wlan0 --localnet | tee "$OUTPUT"
```

### Metasploit Exploits

Edit `sh-files/exploit.sh` to add/modify exploits:
```bash
# Add new exploits to the resource script
cat <<EOF > "$MSF_RC"
use exploit/your/new/exploit
set RHOST $TARGET
set RPORT 1234
exploit -j
EOF
```

## 📝 Script Details

### test.sh
- **Purpose**: Integration script that runs all security assessments
- **Usage**: `sudo ./sh-files/test.sh <target>`
- **Output**: Executes all individual scripts in sequence

### arp-scan.sh
- **Purpose**: Discovers active hosts on local network using ARP
- **Requirements**: Root privileges, arp-scan tool
- **Output**: `reports/arp_scan_report.txt`

### ns.sh
- **Purpose**: Comprehensive network reconnaissance
- **Features**: Ping sweep, TCP/UDP port scans, OS detection, service enumeration, banner grabbing
- **Output**: `reports/network_scan_report.txt`

### vuln.sh
- **Purpose**: Vulnerability assessment using Nmap scripts
- **Features**: Port scanning, service detection, vulnerability scripts, HTTP vulnerability checks
- **Output**: `reports/vuln_scan_report.txt`

### exploit.sh
- **Purpose**: Automated exploitation attempts using Metasploit
- **Features**: Service reconnaissance, automatic exploit generation, Metasploit execution
- **Output**: Multiple files in `reports/exploit/` directory

## 🔒 Important Security Notes

⚠️ **WARNING**: This tool is for educational and authorized testing purposes only.

- **Only use on networks you own or have explicit permission to test**
- **Root privileges required** for some scanning techniques
- **Network administrators may detect** these scanning activities
- **Some exploits may cause service disruption** - use in controlled environments
- **Comply with local laws and regulations** regarding network security testing

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied errors**:
   ```bash
   chmod +x sh-files/*.sh
   sudo ./sh-files/test.sh <target>
   ```

2. **Missing tools**:
   ```bash
   sudo apt install nmap netcat arp-scan metasploit-framework
   ```

3. **Web dashboard not loading**:
   - Ensure Python HTTP server is running
   - Check whether you start the server in the project directory
   - Check if port 8000 is available
   - Try alternative port: `python3 -m http.server 8080`

4. **Reports not updating**:
   - Files are overwritten each run (no timestamps)
   - Refresh browser page after running scans
   - Check file permissions in reports directory

5. **Network interface issues**:
   ```bash
   # List available interfaces
   ip link show
   # Update sh-files/arp-scan.sh with correct interface
   ```

## 📚 Educational Purpose

This project demonstrates:
- Network reconnaissance techniques
- Vulnerability assessment methodologies
- Automated exploitation frameworks
- Security report generation and visualization
- Integration of multiple security tools

## 🤝 Contributing

This is a capstone project for educational purposes. Suggestions and improvements are welcome for learning enhancement.

## 📄 License

This project is for educational use only. Please ensure compliance with local laws and regulations when using these tools.

---

**Created for Semester-5 Capstone Project - Network Security Assessment**  
*Date: September 25, 2025*
