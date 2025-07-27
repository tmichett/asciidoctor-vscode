# Build Scripts Documentation

This document describes the available build scripts for the AsciiDoc VSCode Extension.

## Available Build Scripts

We provide multiple build scripts for different platforms and preferences:

### 1. Cross-Platform Shell Script (`build.sh`)
```bash
./build.sh [command]
```
**Requirements**: Bash shell (Git Bash, WSL, Linux, macOS)

### 2. Windows Batch File (`build.bat`)
```cmd
build.bat [command]
```
**Requirements**: Windows Command Prompt

### 3. PowerShell Script (`build.ps1`)
```powershell
.\build.ps1 [command]
```
**Requirements**: PowerShell 5.0+ (Windows, Linux, macOS)

### 4. NPM Scripts
```bash
npm run [script-name]
```
**Requirements**: Node.js and npm

## Commands

All build scripts support the following commands:

| Command | Description |
|---------|-------------|
| `dev` or `development` | Development build (default) |
| `prod` or `production` | Production build with checks |
| `clean` | Clean build artifacts |
| `install` | Install dependencies |
| `test` | Run tests |
| `check` | Run code quality checks |
| `package` | Build and package for distribution |
| `all` | Clean, install, build, and package |
| `help` | Show help information |

## Build Process

The extension build process consists of several steps:

### 1. Asset Copying
- Copies fonts (Noto Serif, Open Sans, Roboto Mono)
- Copies Font Awesome icons and CSS
- Copies MathJax library
- Copies Mermaid library
- Copies Highlight.js library and themes

### 2. TypeScript Compilation
- Compiles TypeScript source code in `src/` directory
- Outputs to `dist/` directory
- Uses `tsconfig.json` configuration

### 3. Preview Components Build
- Builds preview components using Webpack
- Configuration: `extension-preview.webpack.config.js`
- Production mode optimization

### 4. Web Extension Build (Production only)
- Builds web-compatible version using Webpack
- Configuration: `extension-browser.webpack.config.js`
- Browser compatibility mode

### 5. Code Quality Checks (Production only)
- Runs Biome linter and formatter
- Checks code style and potential issues

### 6. Packaging (Package command only)
- Creates `.vsix` file using `vsce package`
- Includes all necessary files for distribution

## Examples

### Quick Development Build
```bash
# Using shell script
./build.sh

# Using PowerShell
.\build.ps1

# Using npm
npm run dev
```

### Production Build and Package
```bash
# Using shell script
./build.sh package

# Using PowerShell
.\build.ps1 package

# Using npm
npm run package
```

### Clean and Full Rebuild
```bash
# Using shell script
./build.sh all

# Using PowerShell
.\build.ps1 all

# Using npm (manual steps)
npm run clean
npm ci
npm run package
```

### Run Tests
```bash
# Using shell script
./build.sh test

# Using PowerShell
.\build.ps1 test

# Using npm
npm test
```

## NPM Scripts Reference

| Script | Description |
|--------|-------------|
| `npm run dev` | Development build |
| `npm run build` | Standard build (assets + TypeScript + preview) |
| `npm run build:clean` | Clean build |
| `npm run clean` | Clean build artifacts |
| `npm run build-ext` | Compile TypeScript only |
| `npm run build-preview` | Build preview components only |
| `npm run build-web` | Build web extension only |
| `npm run copy-assets` | Copy assets only |
| `npm run package` | Full build and package |
| `npm run check` | Run code quality checks |
| `npm test` | Run tests |

## Troubleshooting

### Common Issues

1. **Permission denied (Linux/macOS)**
   ```bash
   chmod +x build.sh
   ```

2. **PowerShell execution policy (Windows)**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Node.js/npm not found**
   - Install Node.js from [nodejs.org](https://nodejs.org/)
   - Restart your terminal/command prompt

4. **Dependencies not installed**
   ```bash
   npm ci
   # or
   ./build.sh install
   ```

5. **Build artifacts conflicts**
   ```bash
   npm run clean
   # or
   ./build.sh clean
   ```

### Build Output

Successful builds create:
- `dist/` - Compiled TypeScript
- `media/` - Copied assets (fonts, libraries)
- `*.vsix` - Extension package (package command only)

### File Sizes

Typical build output sizes:
- Development build: ~15-20 MB (media assets)
- Packaged extension: ~8-12 MB (compressed)

## Contributing

When modifying build scripts:
1. Test on multiple platforms
2. Update this documentation
3. Ensure backward compatibility with existing npm scripts
4. Add appropriate error handling 