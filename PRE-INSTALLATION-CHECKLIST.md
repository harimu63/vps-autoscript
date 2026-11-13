# Pre-Installation Checklist

Before installing VPS Autoscript, please ensure you meet all requirements:

## ✅ System Requirements

### Operating System
- [ ] Ubuntu 20.04, 22.04, or 24.04 LTS
- [ ] Debian 10, 11, or 12
- [ ] Architecture: x86_64 (amd64)

### Virtualization
- [ ] KVM, Xen, VMware, or Bare Metal
- [ ] **NOT** OpenVZ or LXC (these are not supported)

### Resources
- [ ] RAM: Minimum 512 MB (1 GB recommended)
- [ ] Disk: Minimum 5 GB free space
- [ ] Kernel: Version 4.9 or higher (check with: `uname -r`)

### Network
- [ ] Fresh VPS with clean OS installation
- [ ] Root access available
- [ ] Public IPv4 address
- [ ] Stable internet connection

## ✅ Domain Requirements

### Domain Setup (CRITICAL)
- [ ] You have a registered domain or subdomain
- [ ] Domain is pointed to your VPS IP address (A record)
- [ ] DNS propagation is complete (check with: `nslookup yourdomain.com`)
- [ ] Ports 80 and 443 are accessible from internet (for SSL cert issuance)

**Example DNS Configuration:**
```
Type: A
Name: vpn (or @ for root domain)
Value: YOUR_VPS_IP_ADDRESS
TTL: 3600
```

**Verify DNS:**
```bash
# Check if domain resolves to your VPS IP
dig +short yourdomain.com

# Should return your VPS IP address
```

**⚠️ IMPORTANT:** 
- IP address is NOT supported - you MUST use a domain
- SSL certificate cannot be issued without a valid domain
- Domain must be accessible from the internet

## ✅ Port Requirements

Ensure these ports are not being used by other services:

- [ ] Port 22 (SSH) - available
- [ ] Port 80 (HTTP) - available  
- [ ] Port 443 (HTTPS) - available
- [ ] Port 444 (Dropbear) - available
- [ ] Port 445 (Stunnel) - available
- [ ] Port 1194 (OpenVPN TCP) - available
- [ ] Port 2095 (SSH WebSocket) - available
- [ ] Port 2200 (OpenVPN UDP) - available

**Check port availability:**
```bash
# Check if port is in use
ss -tulpn | grep ':443'

# If output is empty, port is available
```

## ✅ Pre-Installation Commands

Run these commands BEFORE installation:

### 1. Update System
```bash
apt update && apt upgrade -y
```

### 2. Check if running as root
```bash
whoami
# Should output: root
```

### 3. Check virtualization type
```bash
systemd-detect-virt
# Should NOT output: openvz or lxc
```

### 4. Check available disk space
```bash
df -h /
# Should show at least 5GB available
```

### 5. Check kernel version
```bash
uname -r
# Should be 4.9 or higher
```

### 6. Verify internet connectivity
```bash
ping -c 4 google.com
# Should get replies
```

### 7. Check DNS resolution
```bash
nslookup github.com
# Should resolve successfully
```

## ✅ Installation Information

Prepare this information before starting installation:

- [ ] **Domain name**: ___________________________
- [ ] **Admin email**: ___________________________
- [ ] **SSH WebSocket port** (default: 2095): _____
- [ ] **Enable BBR?** (recommended): Yes / No

## ✅ Backup Current Configuration

If you're re-installing or upgrading:

- [ ] Backup any existing VPN configurations
- [ ] Export user lists if applicable
- [ ] Save custom configurations
- [ ] Document any port changes made

## ✅ Cloud Provider Specific

### DigitalOcean
- [ ] Ensure firewall rules allow ports 22, 80, 443
- [ ] Disable "Droplet Firewall" (script manages UFW)

### AWS/Lightsail
- [ ] Security Group allows ports 22, 80, 443, 1194, 2200
- [ ] Elastic IP assigned (if needed)

### Google Cloud
- [ ] VPC firewall rules configured
- [ ] Static external IP assigned

### Vultr/Linode/OVH
- [ ] No additional firewall blocking ports
- [ ] rDNS configured (optional)

## ✅ Post-Installation Access

Prepare SSH client for after installation:

- [ ] SSH client installed (PuTTY, Terminal, etc.)
- [ ] Know your VPS IP address
- [ ] Have root password ready

## 🚀 Ready to Install?

If all checkboxes above are checked, you're ready to proceed:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/harimu63/vps-autoscript/main/install.sh)
```

## ❓ Troubleshooting

**If installation fails:**

1. Check `/var/log/vps-autoscript/autoscript.log`
2. Verify domain DNS is correct
3. Ensure ports 80 and 443 are not blocked
4. Check SSL log: `/var/log/vps-autoscript/ssl.log`
5. Run dry-run mode first:
   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/harimu63/vps-autoscript/main/install.sh) --dry-run
   ```

**Common Issues:**

- **SSL certificate fails**: Domain not pointed to VPS IP
- **Port conflicts**: Another service using required ports
- **Permission denied**: Not running as root
- **Network timeout**: VPS has no internet connectivity

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/harimu63/vps-autoscript/issues
- Check documentation: `docs/troubleshooting.md`
