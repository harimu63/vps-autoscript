#!/usr/bin/env bash
# =============================================================================
# firewall_manager.sh — UFW firewall configuration for VPS autoscript
# =============================================================================

[[ -n "${_FIREWALL_MANAGER_SH:-}" ]] && return 0
readonly _FIREWALL_MANAGER_SH=1

[[ -z "${RED:-}" ]] && source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# -----------------------------------------------------------------------------
# UFW Installation and Basic Setup
# -----------------------------------------------------------------------------

install_ufw() {
  if has_command ufw; then
    info "UFW already installed."
    return 0
  fi
  step "Installing UFW firewall..."
  apt_install ufw
  success "UFW installed."
}

# -----------------------------------------------------------------------------
# Configure firewall rules for all VPN protocols
# -----------------------------------------------------------------------------

setup_firewall() {
  step "Configuring UFW firewall rules..."
  
  # Load port configuration
  source "$(dirname "${BASH_SOURCE[0]}")/../config/defaults.conf"
  [[ -f "${CONFIG_DIR}/autoscript.conf" ]] && source "${CONFIG_DIR}/autoscript.conf"
  
  # Disable UFW first to prevent lockout
  ufw --force disable 2>/dev/null || true
  
  # Reset to default (deny incoming, allow outgoing)
  echo "y" | ufw reset &>/dev/null
  ufw default deny incoming
  ufw default allow outgoing
  
  # Allow SSH (critical - prevent lockout)
  ufw allow "${PORT_SSH:-22}/tcp" comment "SSH"
  
  # Allow HTTP/HTTPS (for SSL cert issuance and web panel)
  ufw allow "${PORT_NGINX_HTTP:-80}/tcp" comment "HTTP"
  ufw allow "${PORT_NGINX_HTTPS:-443}/tcp" comment "HTTPS - Xray/Trojan"
  
  # Allow Dropbear SSH
  ufw allow "${PORT_DROPBEAR:-444}/tcp" comment "Dropbear SSH"
  
  # Allow Stunnel4
  ufw allow "${PORT_STUNNEL:-445}/tcp" comment "Stunnel4"
  
  # Allow SSH WebSocket
  ufw allow "${PORT_SSHWS:-2095}/tcp" comment "SSH WebSocket"
  
  # Allow OpenVPN
  ufw allow "${PORT_OPENVPN_TCP:-1194}/tcp" comment "OpenVPN TCP"
  ufw allow "${PORT_OPENVPN_UDP:-2200}/udp" comment "OpenVPN UDP"
  
  # Allow Trojan-Go (if different from 443)
  [[ "${PORT_TROJAN_GO:-2087}" != "443" ]] && \
    ufw allow "${PORT_TROJAN_GO:-2087}/tcp" comment "Trojan-Go"
  
  # Allow UDP for DNS, NTP, QUIC
  ufw allow 53/udp comment "DNS"
  ufw allow 123/udp comment "NTP"
  
  # Enable UFW with auto-confirm
  echo "y" | ufw enable
  
  # Verify status
  ufw status numbered | while IFS= read -r line; do
    log_debug "ufw: ${line}"
  done
  
  success "Firewall configured and enabled."
}

# -----------------------------------------------------------------------------
# Add custom port
# -----------------------------------------------------------------------------

fw_allow_port() {
  local port="$1"
  local proto="${2:-tcp}"
  local comment="${3:-Custom port}"
  
  if ! has_command ufw; then
    warn "UFW not installed. Port ${port}/${proto} not added to firewall."
    return 1
  fi
  
  ufw allow "${port}/${proto}" comment "${comment}"
  success "Allowed ${port}/${proto} (${comment})"
}

# -----------------------------------------------------------------------------
# Remove port
# -----------------------------------------------------------------------------

fw_deny_port() {
  local port="$1"
  local proto="${2:-tcp}"
  
  if ! has_command ufw; then
    warn "UFW not installed."
    return 1
  fi
  
  ufw delete allow "${port}/${proto}" 2>/dev/null || true
  success "Removed ${port}/${proto} from firewall."
}

# -----------------------------------------------------------------------------
# Show firewall status
# -----------------------------------------------------------------------------

show_firewall_status() {
  if ! has_command ufw; then
    warn "UFW not installed."
    return 1
  fi
  
  separator
  echo -e "${BOLD}UFW Firewall Status:${RESET}"
  separator
  ufw status verbose
  separator
}

# -----------------------------------------------------------------------------
# Disable firewall (for troubleshooting)
# -----------------------------------------------------------------------------

disable_firewall() {
  if ! has_command ufw; then
    warn "UFW not installed."
    return 0
  fi
  
  warn "Disabling firewall..."
  confirm "Are you sure? This will expose all ports." || return 1
  
  ufw --force disable
  warn "Firewall disabled. Re-enable with: ufw enable"
}

# -----------------------------------------------------------------------------
# Validate firewall is not blocking critical ports
# -----------------------------------------------------------------------------

validate_firewall() {
  if ! has_command ufw; then
    return 0
  fi
  
  local critical_ports=(22 80 443)
  local blocked=()
  
  for port in "${critical_ports[@]}"; do
    if ! ufw status | grep -q "${port}/tcp.*ALLOW"; then
      blocked+=("${port}")
    fi
  done
  
  if [[ ${#blocked[@]} -gt 0 ]]; then
    error "Critical ports blocked by firewall: ${blocked[*]}"
    error "This may cause connection issues!"
    return 1
  fi
  
  success "Firewall validation passed."
}
