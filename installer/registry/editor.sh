#!/usr/bin/env bash
# VS Code extensions registry — pipe-delimited: "key|Display Name|extension_id|description|category|url"
# URL is optional — if empty, marketplace link is auto-generated from extension_id

EXT_ENTRIES=(
  "auto-barrel|Auto Barrel|imgildev.vscode-auto-barrel|Auto-generate barrel index files|productivity|"
  "auto-close-tag|Auto Close Tag|formulahendry.auto-close-tag|Auto-insert closing tags|essentials|"
  "auto-rename-tag|Auto Rename Tag|formulahendry.auto-rename-tag|Auto-rename paired tags|essentials|"
  "better-comments|Better Comments|aaron-bond.better-comments|Color-coded comments|productivity|"
  "bookmarks|Bookmarks|alefragnani.bookmarks|Mark and jump between lines|productivity|"
  "code-runner|Code Runner|formulahendry.code-runner|Run code in 40+ languages|productivity|"
  "codesnap|CodeSnap|adpyke.codesnap|Take code screenshots|productivity|"
  "code-spell-checker|Code Spell Checker|streetsidesoftware.code-spell-checker|Catch spelling mistakes|essentials|"
  "docker|Docker|ms-azuretools.vscode-docker|Manage containers|tools|"
  "dotenv|DotENV|mikestead.dotenv|.env syntax highlighting|essentials|"
  "error-lens|Error Lens|usernamehw.errorlens|Show errors inline|essentials|"
  "eslint|ESLint|dbaeumer.vscode-eslint|JS/TS linting|essentials|https://eslint.org"
  "font-size-shortcuts|Font Size Shortcuts|fosshaas.fontsize-shortcuts|Change font size only|productivity|"
  "github-copilot|GitHub Copilot|GitHub.copilot|AI code completion|git|https://github.com/features/copilot"
  "gitlens|GitLens|eamodio.gitlens|Git blame and history|git|https://gitlens.amod.io"
  "github-pr|GitHub Pull Requests|GitHub.vscode-pull-request-github|Review and manage PRs|git|"
  "import-cost|Import Cost|wix.vscode-import-cost|Show package size inline|productivity|"
  "npm-intellisense|npm IntelliSense|christian-kohler.npm-intellisense|Autocomplete npm modules|intellisense|"
  "path-intellisense|Path IntelliSense|christian-kohler.path-intellisense|Autocomplete file paths|intellisense|"
  "es7-react-snippets|ES7+ React Snippets|dsznajder.es7-react-js-snippets|React/Redux/JS snippets|snippets|"
  "jest-runner|Jest Runner|firsttris.vscode-jest-runner|Run Jest tests|testing|"
  "vscode-jest|Jest|orta.vscode-jest|Auto-run Jest inline|testing|"
  "playwright|Playwright|ms-playwright.playwright|Playwright runner|testing|https://playwright.dev"
  "paste-image|Paste Image|mushan.vscode-paste-image|Paste clipboard images|media|"
  "image-preview|Image Preview|kisstkondansen.vscode-gutter-preview|Preview images in gutter|media|"
  "paste-json-as-code|Paste JSON as Code|quicktype.quicktype|JSON to typed code|productivity|"
  "peacock|Peacock|johnpapa.vscode-peacock|Color-code your workspaces|productivity|"
  "postcss-intellisense|PostCSS IntelliSense|vunguyentuan.vscode-postcss|PostCSS support|intellisense|"
  "prettier|Prettier|esbenp.prettier-vscode|Code formatter|essentials|https://prettier.io"
  "pretty-ts-errors|Pretty TS Errors|yoavbls.pretty-ts-errors|Readable TS errors|essentials|"
  "project-manager|Project Manager|alefragnani.project-manager|Switch between projects easily|productivity|"
  "tailwind-css|Tailwind CSS|bradlc.vscode-tailwindcss|Tailwind autocomplete|intellisense|https://tailwindcss.com"
  "thunder-client|Thunder Client|rangav.vscode-thunder-client|REST API client|tools|"
  "todo-tree|Todo Tree|Gruntfuggly.todo-tree|Tree view of TODO/FIXME across project|productivity|"
  "turbo-console-log|Turbo Console Log|ChakrounAnas.turbo-console-log|Insert console.log with shortcuts|productivity|"
  "vim|Vim|vscodevim.vim|Vim keybindings|vim|"
  "vim-cheatsheet|Vim Cheatsheet|andenetalexander.vim-cheatsheet|Vim reference|vim|"
  "learn-vim|Learn Vim|vintharas.learn-vim|Interactive Vim tutorial|vim|"
  "remote-ssh|Remote SSH|ms-vscode-remote.remote-ssh|Develop over SSH|remote|"
  "remote-containers|Dev Containers|ms-vscode-remote.remote-containers|Develop in containers|remote|"
  "remote-explorer|Remote Explorer|ms-vscode.remote-explorer|Browse remotes|remote|"
  "yaml|YAML|redhat.vscode-yaml|YAML support|languages|"
  "markdownlint|markdownlint|DavidAnson.vscode-markdownlint|Markdown linting and style checking|languages|https://github.com/DavidAnson/vscode-markdownlint"
  "mdx|MDX|unifiedjs.vscode-mdx|MDX support|languages|"
  "quokka|Quokka.js|WallabyJs.quokka-vscode|Live JavaScript/TypeScript scratchpad|productivity|https://quokkajs.com"
  "sonarlint|SonarLint|SonarSource.sonarlint-vscode|Code quality and security linting|essentials|https://www.sonarsource.com/products/sonarlint"
  "excalidraw|Excalidraw|pomdtr.excalidraw-editor|Whiteboard and diagramming tool|tools|https://excalidraw.com"
  "github-theme|GitHub Theme|GitHub.github-vscode-theme|Official GitHub color themes|themes|"
  "one-dark-pro|One Dark Pro|zhuangtongfa.material-theme|Atom-inspired dark theme|themes|"
  "material-product-icons|Material Product Icons|PKief.material-product-icons|Material UI icons|themes|"
  "material-icon-theme|Material Icon Theme|pkief.material-icon-theme|Material file icons|themes|"
)

# Get unique category names
get_ext_categories() {
  local seen=""
  for entry in "${EXT_ENTRIES[@]}"; do
    local cat
    cat=$(get_field "$entry" 5)
    if ! echo "$seen" | grep -q "|${cat}|"; then
      echo "$cat"
      seen="${seen}|${cat}|"
    fi
  done
}
