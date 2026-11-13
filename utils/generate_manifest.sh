#!/usr/bin/env bash
# =============================================================================
# generate_manifest.sh — Generate update_manifest.json with SHA256 checksums
# Usage: ./generate_manifest.sh [output_file]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
OUTPUT_FILE="${1:-${REPO_DIR}/update_manifest.json}"

# Get current version
VERSION=$(cat "${REPO_DIR}/version" 2>/dev/null || echo "0.0.0")

echo "Generating update manifest for version ${VERSION}..."

# Build JSON manually (more reliable than jq in minimal environments)
{
  echo "{"
  echo "  \"version\": \"${VERSION}\","
  echo "  \"timestamp\": \"$(date -Iseconds)\","
  echo "  \"files\": ["

  first=true
  for file in \
    "library/common.sh" \
    "library/logger.sh" \
    "library/validation.sh" \
    "library/service_manager.sh" \
    "library/dependency_manager.sh" \
    "library/firewall_manager.sh" \
    "update/updater.sh" \
    "menu/main.sh" \
    "service/ssh_user.sh" \
    "service/xray_user.sh" \
    "installer/main.sh" \
    "installer/xray.sh" \
    "installer/nginx.sh" \
    "installer/ssh_setup.sh" \
    "installer/ssl.sh" \
    "installer/openvpn.sh" \
    "backup/backup.sh" \
    "backup/restore.sh" \
    "monitoring/status.sh" \
    "monitoring/health_check.sh" \
    "utils/port_manager.sh" \
    "utils/cert_manager.sh"
  do
    full_path="${REPO_DIR}/${file}"
    if [[ -f "${full_path}" ]]; then
      sha256=$(sha256sum "${full_path}" | awk '{print $1}')
      if [[ "${first}" != "true" ]]; then
        echo ","
      fi
      first=false
      printf '    {"path": "%s", "sha256": "%s"}' "${file}" "${sha256}"
    fi
  done

  echo ""
  echo "  ]"
  echo "}"
} > "${OUTPUT_FILE}"

echo "Update manifest generated: ${OUTPUT_FILE}"
echo ""
echo "To use this manifest:"
echo "1. Copy ${OUTPUT_FILE} to your GitHub repo root"
echo "2. Commit and push to GitHub"
echo "3. Update the version file with a new version number"
echo ""
echo "Manifest preview:"
cat "${OUTPUT_FILE}" | head -20
