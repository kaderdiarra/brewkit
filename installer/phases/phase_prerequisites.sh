#!/usr/bin/env bash
# Phase 1: Check and install prerequisites (Xcode CLI tools, Homebrew, gum)
# Note: uses _fallback_confirm directly since gum isn't available yet

run_phase_prerequisites() {
  print_step "1" "5" "Prerequisites"
  print_phase_intro 1

  # Xcode CLI tools
  if is_xcode_cli_installed; then
    print_success "Xcode Command Line Tools"
  else
    print_arrow "Xcode Command Line Tools are required."
    if _fallback_confirm "Install Xcode CLI tools now?"; then
      xcode-select --install 2>/dev/null
      echo ""
      print_warn "Xcode CLI tools installer launched. Complete it, then re-run this installer."
      exit 1
    else
      print_error "Xcode CLI tools are required to continue."
      exit 1
    fi
  fi

  # Homebrew
  if is_brew_installed; then
    print_success "Homebrew $(brew --version 2>/dev/null | head -1 | awk '{print $2}')"
  else
    print_arrow "Homebrew is required to install packages."
    if _fallback_confirm "Install Homebrew now?"; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      # Add to PATH based on architecture
      if [[ "$(get_arch)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        eval "$(/usr/local/bin/brew shellenv)"
      fi

      if is_brew_installed; then
        print_success "Homebrew installed"
      else
        print_error "Homebrew installation failed"
        exit 1
      fi
    else
      print_error "Homebrew is required to continue."
      exit 1
    fi
  fi

  # gum (interactive UI)
  if is_gum_installed; then
    print_success "gum (interactive UI)"
  else
    print_arrow "Installing gum (for interactive UI)..."
    brew install gum 2>/dev/null
    if is_gum_installed; then
      print_success "gum installed"
    else
      print_warn "gum unavailable — using basic terminal prompts"
      USE_FALLBACK=true
    fi
  fi

  # fzf (fuzzy finder with inline preview)
  if is_fzf_installed; then
    print_success "fzf (inline tool preview)"
  else
    print_arrow "Installing fzf (for inline tool preview)..."
    brew install fzf 2>/dev/null
    if is_fzf_installed; then
      print_success "fzf installed"
    else
      print_warn "fzf unavailable — preview disabled, using standard selection"
    fi
  fi

  log "Prerequisites complete (fallback=${USE_FALLBACK})"
}
