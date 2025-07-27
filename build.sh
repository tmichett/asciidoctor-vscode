#!/bin/bash

# AsciiDoc VSCode Extension Build Script
# Supports: development, production, clean, and package builds

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  dev       - Development build (default)"
    echo "  prod      - Production build"
    echo "  clean     - Clean build artifacts"
    echo "  package   - Build and package for distribution"
    echo "  test      - Run tests"
    echo "  check     - Run code quality checks"
    echo "  install   - Install dependencies"
    echo "  all       - Clean, install, build, and package"
    echo ""
    echo "Examples:"
    echo "  $0              # Development build"
    echo "  $0 prod         # Production build"
    echo "  $0 clean        # Clean build artifacts"
    echo "  $0 package      # Package extension"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install npm first."
        exit 1
    fi
    
    log_success "Dependencies check passed"
}

install_dependencies() {
    log_info "Installing dependencies..."
    npm ci
    log_success "Dependencies installed"
}

clean_build() {
    log_info "Cleaning build artifacts..."
    
    # Remove build directories
    rm -rf dist/
    rm -rf out/
    rm -rf media/fonts/
    rm -rf media/font-awesome/
    rm -rf media/mathjax/
    rm -rf media/mermaid/
    rm -rf media/highlightjs/
    
    # Remove package files
    rm -f *.vsix
    
    log_success "Build artifacts cleaned"
}

copy_assets() {
    log_info "Copying assets..."
    npm run copy-assets
    log_success "Assets copied"
}

build_typescript() {
    log_info "Compiling TypeScript..."
    npm run build-ext
    log_success "TypeScript compiled"
}

build_preview() {
    log_info "Building preview components..."
    npm run build-preview
    log_success "Preview components built"
}

build_web() {
    log_info "Building web extension..."
    npm run build-web
    log_success "Web extension built"
}

run_checks() {
    log_info "Running code quality checks..."
    npm run check
    log_success "Code quality checks passed"
}

run_tests() {
    log_info "Running tests..."
    npm test
    log_success "Tests completed"
}

package_extension() {
    log_info "Packaging extension..."
    npm run package
    log_success "Extension packaged"
    
    # Show package info
    if ls *.vsix 1> /dev/null 2>&1; then
        VSIX_FILE=$(ls *.vsix | head -n1)
        VSIX_SIZE=$(du -h "$VSIX_FILE" | cut -f1)
        log_info "Package created: $VSIX_FILE ($VSIX_SIZE)"
    fi
}

development_build() {
    log_info "Starting development build..."
    copy_assets
    build_typescript
    build_preview
    log_success "Development build completed"
}

production_build() {
    log_info "Starting production build..."
    run_checks
    copy_assets
    build_typescript
    build_preview
    build_web
    log_success "Production build completed"
}

# Main script logic
main() {
    local command=${1:-dev}
    
    log_info "AsciiDoc VSCode Extension Build Script"
    log_info "Command: $command"
    echo ""
    
    check_dependencies
    
    case $command in
        "dev"|"development")
            development_build
            ;;
        "prod"|"production")
            production_build
            ;;
        "clean")
            clean_build
            ;;
        "install")
            install_dependencies
            ;;
        "test")
            run_tests
            ;;
        "check")
            run_checks
            ;;
        "package")
            production_build
            package_extension
            ;;
        "all")
            clean_build
            install_dependencies
            production_build
            package_extension
            ;;
        "help"|"-h"|"--help")
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $command"
            print_usage
            exit 1
            ;;
    esac
    
    echo ""
    log_success "Build script completed successfully! 🎉"
}

# Run main function with all arguments
main "$@" 