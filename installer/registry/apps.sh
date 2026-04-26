#!/usr/bin/env bash
# App registry — pipe-delimited: "key|Display Name|brew_install_args|check_type|check_value|description|url"

APP_ENTRIES=(
  "alttab|AltTab|--cask alt-tab|app|/Applications/AltTab.app|Windows-style alt-tab with window previews|https://alt-tab-macos.com"
  "arc|Arc|--cask arc|app|/Applications/Arc.app|Clean Chromium-based browser with sidebar tabs|https://arc.net"
  "dbeaver|DBeaver|--cask dbeaver-community|app|/Applications/DBeaver.app|Universal database management tool|https://dbeaver.io"
  "hidden-bar|Hidden Bar|--cask hiddenbar|app|/Applications/Hidden Bar.app|Free menu bar icon manager|https://github.com/dwarvesf/hidden"
  "iterm2|iTerm2|--cask iterm2|app|/Applications/iTerm.app|Feature-rich terminal emulator|https://iterm2.com"
  "itsycal|Itsycal|--cask itsycal|app|/Applications/Itsycal.app|Tiny menu bar calendar|https://www.mowglii.com/itsycal"
  "kap|Kap|--cask kap|app|/Applications/Kap.app|Open-source screen recorder|https://getkap.co"
  "keka|Keka|--cask keka|app|/Applications/Keka.app|File archiver (7z, ZIP, RAR)|https://www.keka.io"
  "notchnook|NotchNook|--cask notchnook|app|/Applications/NotchNook.app|MacBook notch utility area|https://lo.cafe/notchnook"
  "raycast|Raycast|--cask raycast|app|/Applications/Raycast.app|Spotlight replacement|https://www.raycast.com"
  "rectangle|Rectangle|--cask rectangle|app|/Applications/Rectangle.app|Window management with shortcuts|https://rectangleapp.com"
  "stats|Stats|--cask stats|app|/Applications/Stats.app|Menu bar system monitor|https://github.com/exelban/stats"
  "sublime-text|Sublime Text|--cask sublime-text|app|/Applications/Sublime Text.app|Fast lightweight text editor|https://www.sublimetext.com"
  "time-out|Time Out|--cask time-out|app|/Applications/Time Out.app|Break timer for strain prevention|https://www.dejal.com/timeout"
  "aerospace|AeroSpace|--cask nikitabobko/tap/aerospace|app|/Applications/AeroSpace.app|i3-like tiling window manager (power-user alternative to Rectangle)|https://github.com/nikitabobko/AeroSpace"
  "linear|Linear|--cask linear|app|/Applications/Linear.app|Issue tracking and project management|https://linear.app"
)

# Field accessors — usage: get_field "entry_string" field_number (1-based)
# Fields: 1=key 2=name 3=brew_args 4=check_type 5=check_value 6=description 7=url
get_field() {
  echo "$1" | cut -d'|' -f"$2"
}

get_app_keys() {
  for entry in "${APP_ENTRIES[@]}"; do
    get_field "$entry" 1
  done
}

find_app_entry() {
  local search_key="$1"
  for entry in "${APP_ENTRIES[@]}"; do
    local key
    key=$(get_field "$entry" 1)
    if [[ "$key" == "$search_key" ]]; then
      echo "$entry"
      return
    fi
  done
}
