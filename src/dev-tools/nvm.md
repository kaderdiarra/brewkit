# NVM (Node Version Manager)

Install and switch between multiple Node.js versions on a single machine.

- **Repo**: https://github.com/nvm-sh/nvm

## Install

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

## Essential Commands

```bash
nvm install --lts         # Install latest LTS version
nvm install 22            # Install specific version
nvm use 22                # Switch to version in current shell
nvm alias default 22      # Set default for new shells
nvm ls                    # List installed versions
nvm ls-remote --lts       # List available LTS versions
```

## Useful Global npm Packages

```bash
npm install -g lite-server     # Auto-refreshing static file server
npm install -g http-server     # Quick HTTP server
npm install -g license         # Generate open source licenses
npm install -g gitignore       # Auto-generate .gitignore by project type
```
