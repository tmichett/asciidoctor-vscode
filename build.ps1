# AsciiDoc VSCode Extension Build Script (PowerShell)
# Supports: development, production, clean, and package builds

param(
    [Parameter(Position = 0)]
    [ValidateSet("dev", "development", "prod", "production", "clean", "install", "test", "check", "package", "all", "help")]
    [string]$Command = "dev"
)

# Error handling
$ErrorActionPreference = "Stop"

# Functions for colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Help {
    Write-Host "Usage: .\build.ps1 [command]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host "  dev       - Development build (default)"
    Write-Host "  prod      - Production build"
    Write-Host "  clean     - Clean build artifacts"
    Write-Host "  package   - Build and package for distribution"
    Write-Host "  test      - Run tests"
    Write-Host "  check     - Run code quality checks"
    Write-Host "  install   - Install dependencies"
    Write-Host "  all       - Clean, install, build, and package"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\build.ps1              # Development build"
    Write-Host "  .\build.ps1 prod         # Production build"
    Write-Host "  .\build.ps1 clean        # Clean build artifacts"
    Write-Host "  .\build.ps1 package      # Package extension"
}

function Test-Dependencies {
    Write-Info "Checking dependencies..."
    
    try {
        $nodeVersion = node --version
        Write-Host "Node.js: $nodeVersion" -ForegroundColor Gray
    }
    catch {
        Write-Error "Node.js is not installed. Please install Node.js first."
        exit 1
    }
    
    try {
        $npmVersion = npm --version
        Write-Host "npm: $npmVersion" -ForegroundColor Gray
    }
    catch {
        Write-Error "npm is not installed. Please install npm first."
        exit 1
    }
    
    Write-Success "Dependencies check passed"
}

function Install-Dependencies {
    Write-Info "Installing dependencies..."
    try {
        npm ci
        Write-Success "Dependencies installed"
    }
    catch {
        Write-Error "Failed to install dependencies"
        throw
    }
}

function Clear-BuildArtifacts {
    Write-Info "Cleaning build artifacts..."
    
    $pathsToRemove = @(
        "dist",
        "out",
        "media\fonts",
        "media\font-awesome",
        "media\mathjax",
        "media\mermaid",
        "media\highlightjs"
    )
    
    foreach ($path in $pathsToRemove) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            Write-Host "Removed: $path" -ForegroundColor Gray
        }
    }
    
    # Remove VSIX files
    Get-ChildItem -Path "." -Filter "*.vsix" | Remove-Item -Force
    
    Write-Success "Build artifacts cleaned"
}

function Copy-Assets {
    Write-Info "Copying assets..."
    try {
        npm run copy-assets
        Write-Success "Assets copied"
    }
    catch {
        Write-Error "Failed to copy assets"
        throw
    }
}

function Build-TypeScript {
    Write-Info "Compiling TypeScript..."
    try {
        npm run build-ext
        Write-Success "TypeScript compiled"
    }
    catch {
        Write-Error "TypeScript compilation failed"
        throw
    }
}

function Build-Preview {
    Write-Info "Building preview components..."
    try {
        npm run build-preview
        Write-Success "Preview components built"
    }
    catch {
        Write-Error "Preview build failed"
        throw
    }
}

function Build-Web {
    Write-Info "Building web extension..."
    try {
        npm run build-web
        Write-Success "Web extension built"
    }
    catch {
        Write-Error "Web extension build failed"
        throw
    }
}

function Invoke-Checks {
    Write-Info "Running code quality checks..."
    try {
        npm run check
        Write-Success "Code quality checks passed"
    }
    catch {
        Write-Error "Code quality checks failed"
        throw
    }
}

function Invoke-Tests {
    Write-Info "Running tests..."
    try {
        npm test
        Write-Success "Tests completed"
    }
    catch {
        Write-Error "Tests failed"
        throw
    }
}

function New-Package {
    Write-Info "Packaging extension..."
    try {
        npm run package
        Write-Success "Extension packaged"
        
        # Show package info
        $vsixFiles = Get-ChildItem -Path "." -Filter "*.vsix"
        if ($vsixFiles) {
            $vsixFile = $vsixFiles[0]
            $size = [math]::Round($vsixFile.Length / 1MB, 2)
            Write-Info "Package created: $($vsixFile.Name) ($size MB)"
        }
    }
    catch {
        Write-Error "Packaging failed"
        throw
    }
}

function Start-DevelopmentBuild {
    Write-Info "Starting development build..."
    Copy-Assets
    Build-TypeScript
    Build-Preview
    Write-Success "Development build completed"
}

function Start-ProductionBuild {
    Write-Info "Starting production build..."
    Invoke-Checks
    Copy-Assets
    Build-TypeScript
    Build-Preview
    Build-Web
    Write-Success "Production build completed"
}

function Start-PackageBuild {
    Start-ProductionBuild
    New-Package
}

function Start-FullBuild {
    Clear-BuildArtifacts
    Install-Dependencies
    Start-PackageBuild
}

# Main script logic
Write-Host ""
Write-Info "AsciiDoc VSCode Extension Build Script"
Write-Info "Command: $Command"
Write-Host ""

Test-Dependencies

try {
    switch ($Command) {
        { $_ -in @("dev", "development") } {
            Start-DevelopmentBuild
        }
        { $_ -in @("prod", "production") } {
            Start-ProductionBuild
        }
        "clean" {
            Clear-BuildArtifacts
        }
        "install" {
            Install-Dependencies
        }
        "test" {
            Invoke-Tests
        }
        "check" {
            Invoke-Checks
        }
        "package" {
            Start-PackageBuild
        }
        "all" {
            Start-FullBuild
        }
        "help" {
            Show-Help
            exit 0
        }
    }
    
    Write-Host ""
    Write-Success "Build script completed successfully! 🎉"
}
catch {
    Write-Host ""
    Write-Error "Build script failed: $($_.Exception.Message)"
    exit 1
} 