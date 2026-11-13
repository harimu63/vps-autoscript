# Changelog

All notable changes to this project will be documented in this file.

## [3.1.0] - 2026-11-13

### 🔧 Fixed - Critical Issues
- **Improved update system reliability**: Enhanced service restart logic with proper validation
  - Added Xray configuration validation before restart
  - Added Nginx configuration validation before restart
  - Only restarts services that were already active
  - All services restarted in correct order with proper dependency handling

- **Service restart failures now properly detected and reported**
  - Post-update health check identifies failing services
  - Clear error messages guide troubleshooting
  - Failed services logged for review

### ✨ Added - New Features
- **Auto-reload updater if itself is updated**
  - Checks if updater.sh checksum changed after installation
  - Re-executes updated version automatically
  - Ensures latest updater features are used immediately

- **Comprehensive service restart coverage**
  - Xray (primary VPN service with config validation)
  - Nginx (reverse proxy with config validation)
  - SSH (OpenSSH daemon)
  - Dropbear (fallback SSH)
  - Stunnel4 (SSL proxy)
  - Trojan-Go (alternative VPN)
  - OpenVPN (TCP and UDP)
  - All services only restarted if already enabled and active

- **Post-update health check system**
  - Validates critical services are running after update
  - Reports status of nginx, xray, ssh, dropbear
  - Prompts user to run health check if issues found

- **Update manifest generation tool**
  - New file: `utils/generate_manifest.sh`
  - Automatically calculates SHA256 checksums for all files
  - Validates JSON format before output
  - Shows usage instructions in output
  - Can generate manifest from any working copy

- **Comprehensive update documentation**
  - New file: `docs/UPDATE-GUIDE.md`
  - Detailed explanation of update flow
  - Troubleshooting section with common issues
  - Best practices for production systems
  - Security considerations documented

### 📝 Improved - Enhancements
- **Update workflow**:
  - Pre-update backup now includes autoscript binaries
  - Updated files tracked for potential self-reload detection
  - Clearer step-by-step progress messages
  - Better error handling with specific messages for each failure type

- **Service restart order**:
  - Xray restarted first (primary service)
  - Nginx restarted second (reverse proxy dependency)
  - All other services restarted in parallel
  - Each service restart validated before proceeding

- **Health check timing**:
  - Now runs immediately after service restarts
  - Checks services that were actually restarted
  - Reports specific services that failed to start

### 🔒 Security
- SHA256 checksums verified for all files before installation
- Manifest downloaded via HTTPS for integrity
- Lock file prevents concurrent updates
- Only root can apply updates
- Pre-update backup provides rollback capability

### 📋 Technical Details
**Files Modified:**
- `update/updater.sh`: Enhanced service restart logic with validation
- `menu/main.sh`: No changes (uses existing updater)
- `version`: Updated to 3.1.0

**Files Created:**
- `update_manifest.json`: Current update manifest with SHA256 checksums
- `utils/generate_manifest.sh`: Manifest generation script
- `docs/UPDATE-GUIDE.md`: Comprehensive update documentation

**Updated Update Flow:**
```
1. Check for updates (get remote version from GitHub)
2. Fetch update manifest (JSON with file list + checksums)
3. Download all updated files to temp directory
4. Verify SHA256 checksums for each file
5. Create pre-update backup
6. Install files atomically (copy to library directory)
7. Update version file
8. Restart Xray with config validation
9. Restart Nginx with config validation
10. Restart all other managed services
11. Run post-update health check
12. Report results and next steps
13. If updater.sh was updated, re-execute with new version
```

---

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
