@echo off
setlocal enabledelayedexpansion

REM AsciiDoc VSCode Extension Build Script for Windows
REM Supports: development, production, clean, and package builds

set "command=%~1"
if "%command%"=="" set "command=dev"

echo.
echo [INFO] AsciiDoc VSCode Extension Build Script
echo [INFO] Command: %command%
echo.

REM Check dependencies
echo [INFO] Checking dependencies...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js first.
    exit /b 1
)

where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed. Please install npm first.
    exit /b 1
)
echo [SUCCESS] Dependencies check passed

REM Main command handling
if /i "%command%"=="dev" goto :development_build
if /i "%command%"=="development" goto :development_build
if /i "%command%"=="prod" goto :production_build
if /i "%command%"=="production" goto :production_build
if /i "%command%"=="clean" goto :clean_build
if /i "%command%"=="install" goto :install_dependencies
if /i "%command%"=="test" goto :run_tests
if /i "%command%"=="check" goto :run_checks
if /i "%command%"=="package" goto :package_extension
if /i "%command%"=="all" goto :build_all
if /i "%command%"=="help" goto :show_help
if /i "%command%"=="-h" goto :show_help
if /i "%command%"=="--help" goto :show_help

echo [ERROR] Unknown command: %command%
goto :show_help

:development_build
echo [INFO] Starting development build...
call :copy_assets
if %errorlevel% neq 0 exit /b %errorlevel%
call :build_typescript
if %errorlevel% neq 0 exit /b %errorlevel%
call :build_preview
if %errorlevel% neq 0 exit /b %errorlevel%
echo [SUCCESS] Development build completed
goto :end

:production_build
echo [INFO] Starting production build...
call :run_checks
if %errorlevel% neq 0 exit /b %errorlevel%
call :copy_assets
if %errorlevel% neq 0 exit /b %errorlevel%
call :build_typescript
if %errorlevel% neq 0 exit /b %errorlevel%
call :build_preview
if %errorlevel% neq 0 exit /b %errorlevel%
call :build_web
if %errorlevel% neq 0 exit /b %errorlevel%
echo [SUCCESS] Production build completed
goto :end

:clean_build
echo [INFO] Cleaning build artifacts...
if exist dist rmdir /s /q dist
if exist out rmdir /s /q out
if exist media\fonts rmdir /s /q media\fonts
if exist media\font-awesome rmdir /s /q media\font-awesome
if exist media\mathjax rmdir /s /q media\mathjax
if exist media\mermaid rmdir /s /q media\mermaid
if exist media\highlightjs rmdir /s /q media\highlightjs
if exist *.vsix del /q *.vsix
echo [SUCCESS] Build artifacts cleaned
goto :end

:install_dependencies
echo [INFO] Installing dependencies...
npm ci
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    exit /b %errorlevel%
)
echo [SUCCESS] Dependencies installed
goto :end

:copy_assets
echo [INFO] Copying assets...
call npm run copy-assets
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy assets
    exit /b %errorlevel%
)
echo [SUCCESS] Assets copied
exit /b 0

:build_typescript
echo [INFO] Compiling TypeScript...
call npm run build-ext
if %errorlevel% neq 0 (
    echo [ERROR] TypeScript compilation failed
    exit /b %errorlevel%
)
echo [SUCCESS] TypeScript compiled
exit /b 0

:build_preview
echo [INFO] Building preview components...
call npm run build-preview
if %errorlevel% neq 0 (
    echo [ERROR] Preview build failed
    exit /b %errorlevel%
)
echo [SUCCESS] Preview components built
exit /b 0

:build_web
echo [INFO] Building web extension...
call npm run build-web
if %errorlevel% neq 0 (
    echo [ERROR] Web extension build failed
    exit /b %errorlevel%
)
echo [SUCCESS] Web extension built
exit /b 0

:run_checks
echo [INFO] Running code quality checks...
call npm run check
if %errorlevel% neq 0 (
    echo [ERROR] Code quality checks failed
    exit /b %errorlevel%
)
echo [SUCCESS] Code quality checks passed
exit /b 0

:run_tests
echo [INFO] Running tests...
call npm test
if %errorlevel% neq 0 (
    echo [ERROR] Tests failed
    exit /b %errorlevel%
)
echo [SUCCESS] Tests completed
goto :end

:package_extension
call :production_build
if %errorlevel% neq 0 exit /b %errorlevel%
echo [INFO] Packaging extension...
call npm run package
if %errorlevel% neq 0 (
    echo [ERROR] Packaging failed
    exit /b %errorlevel%
)
echo [SUCCESS] Extension packaged

REM Show package info
for %%f in (*.vsix) do (
    echo [INFO] Package created: %%f
    goto :end
)
goto :end

:build_all
call :clean_build
if %errorlevel% neq 0 exit /b %errorlevel%
call :install_dependencies
if %errorlevel% neq 0 exit /b %errorlevel%
call :package_extension
if %errorlevel% neq 0 exit /b %errorlevel%
goto :end

:show_help
echo Usage: %~nx0 [command]
echo.
echo Commands:
echo   dev       - Development build (default)
echo   prod      - Production build
echo   clean     - Clean build artifacts
echo   package   - Build and package for distribution
echo   test      - Run tests
echo   check     - Run code quality checks
echo   install   - Install dependencies
echo   all       - Clean, install, build, and package
echo.
echo Examples:
echo   %~nx0              # Development build
echo   %~nx0 prod         # Production build
echo   %~nx0 clean        # Clean build artifacts
echo   %~nx0 package      # Package extension
goto :end

:end
echo.
echo [SUCCESS] Build script completed successfully! 🎉 