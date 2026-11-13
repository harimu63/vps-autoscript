# Changelog

All notable changes to this project will be documented in this file.

## [3.0.1] - 2026-11-13

### 🔧 Fixed - Critical Issues
- **Fixed repository URLs**: Changed placeholder `your-org` to `harimu63` in all files
  - `install.sh`: Updated REPO_URL
  - `config/defaults.conf`: Updated UPDATE_SOURCE
  - `update/updater.sh`: Updated UPDATE_SOURCE
  - `README.md`: Updated installation examples

- **Fixed OpenVPN UDP port conflict**: Changed from 1194 to 2200 to avoid conflict with TCP port
  - `config/defaults.conf`: PORT_OPENVPN_UDP now correctly set to 2200

- **Fixed service unit typo**: Renamed service from "runn" to "xray-socket-permissions"
  - `installer/xray.sh`: More descriptive service name

### ✨ Added - New Features
- **UFW Firewall Management**: Automatic firewall configuration during installation
  - New file: `library/firewall_manager.sh`
  - Automatically opens all required ports (SSH, HTTP, HTTPS, VPN protocols)
  - Prevents unauthorized access to unused ports
  - Phase 8 added to installer: Firewall Configuration
  - UFW added to core dependencies

### 📝 Improved - Enhancements
- **Domain validation**: Enhanced to strip http/https prefixes and trailing slashes
  - Clearer error messages requiring domain (not IP) for SSL certificate
  - `library/validation.sh`: Updated prompt_domain() function

- **Installation flow**: Updated from 7 phases to 8 phases
  - Phase 1-7: Existing phases renumbered
  - Phase 8: New firewall configuration phase
  - `installer/main.sh`: All phase headers updated

- **Documentation**: 
  - Updated README.md with correct installation URL
  - Added firewall management section
  - Clarified domain requirement (no longer IP-only)
  - Added firewall to security improvements table

- **Installation summary**: Now displays firewall status in completion message

### 🔒 Security
- UFW firewall now enabled by default
- Only necessary ports are opened
- DNS and NTP ports allowed for system functionality
- Prevents SSH lockout during firewall configuration

### 📋 Technical Details
**Files Modified:**
- `install.sh`
- `config/defaults.conf`
- `update/updater.sh`
- `installer/main.sh`
- `installer/xray.sh`
- `library/validation.sh`
- `library/dependency_manager.sh`
- `README.md`

**Files Created:**
- `library/firewall_manager.sh`
- `CHANGELOG.md`

**Ports Configured in Firewall:**
- SSH: 22/tcp
- HTTP: 80/tcp
- HTTPS: 443/tcp
- Dropbear: 444/tcp
- Stunnel: 445/tcp
- SSH WebSocket: 2095/tcp
- OpenVPN TCP: 1194/tcp
- OpenVPN UDP: 2200/udp
- DNS: 53/udp
- NTP: 123/udp

---

## [3.0.0] - Initial Release

### Features
- Multi-protocol VPN support (SSH, VMess, VLESS, Trojan, OpenVPN)
- Modular architecture with clean separation of concerns
- Automatic SSL certificate via Let's Encrypt
- User management with expiry dates
- Backup and restore functionality
- Health monitoring and auto-healing
- BBR TCP congestion control support
- WebSocket and gRPC transport support
