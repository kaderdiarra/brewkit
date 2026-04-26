#!/usr/bin/env bash
# Logging, error handling, and signal traps

LOG_DIR="${INSTALLER_ROOT}/logs"
LOG_FILE="${LOG_DIR}/install-$(date +%Y-%m-%d-%H%M%S).log"

init_log() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  log "Install started at $(date)"
  log "macOS $(sw_vers -productVersion) | $(uname -m)"
  log "Installer version: ${INSTALLER_VERSION:-unknown}"
}

log() {
  echo "[$(date +%H:%M:%S)] $1" >> "$LOG_FILE"
}


cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && $exit_code -ne 130 ]]; then
    log "Install failed with exit code: $exit_code"
  fi
  log "Install finished at $(date)"
  # Clean up flair temp files if the function exists
  if type cleanup_flair &>/dev/null; then
    cleanup_flair
  fi
}

handle_interrupt() {
  echo ""
  echo ""
  print_warn "Installation interrupted by user (Ctrl+C)"
  log "Install interrupted by user (SIGINT)"
  if [[ ${#RESULTS_SUCCESS[@]} -gt 0 ]] 2>/dev/null; then
    echo -e "  ${DIM}Successfully installed before interruption:${RESET}"
    for item in "${RESULTS_SUCCESS[@]}"; do
      echo -e "    ${CHECK} $item"
    done
  fi
  echo -e "  ${DIM}Log file: ${LOG_FILE}${RESET}"
  echo ""
  exit 130
}

trap cleanup EXIT
trap handle_interrupt INT TERM
