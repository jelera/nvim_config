#!/usr/bin/env bash
#
# NeoVim IDE Configuration - Quick Start Script
# ==============================================
#
# This script provides a safe one-liner installation that:
# 1. Checks for existing NeoVim config
# 2. Prompts to backup if needed
# 3. Clones the repository
# 4. Runs the full installation
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash
#   Or:
#   bash <(curl -fsSL https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh)
#
# With auto-confirm flag:
#   curl -fsSL https://raw.githubusercontent.com/jelera/nvim_config/main/quick-start.sh | bash -s -- -y

set -e          # Exit on error
set -u          # Exit on undefined variable
set -o pipefail # Pipeline fails if any command fails

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Repository details
readonly REPO_OWNER="jelera"
readonly REPO_NAME="nvim_config"
readonly REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}.git"

# Installation paths
readonly NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
readonly TEMP_CLONE_DIR="/tmp/nvim_config_install_$$"

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

# Print colored messages
color_echo() {
    echo -e "$*"
}

print_header() {
    color_echo "\n${BOLD}${CYAN}🔧 $*${NC}\n"
}

print_info() {
    color_echo "${BLUE}ℹ️${NC}  $*"
}

print_success() {
    color_echo "${GREEN}✅${NC} $*"
}

print_warning() {
    color_echo "${YELLOW}⚠️${NC}  $*"
}

print_error() {
    color_echo "${RED}❌${NC} $*" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Cleanup temporary directory on exit
cleanup() {
    if [[ -d "$TEMP_CLONE_DIR" ]]; then
        print_info "Cleaning up temporary files..."
        rm -rf "$TEMP_CLONE_DIR"
    fi
}

trap cleanup EXIT

#------------------------------------------------------------------------------
# Main Installation
#------------------------------------------------------------------------------

main() {
    local auto_yes=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        --yes | -y)
            auto_yes=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
        esac
    done

    # Print banner
    echo ""
    color_echo "╔════════════════════════════════════════════════════════════════╗"
    color_echo "║  ${BOLD}NeoVim IDE Configuration - Quick Start${NC}                       ║"
    color_echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Check for git
    if ! command_exists git; then
        print_error "git is not installed"
        echo ""
        echo "Please install git first:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  brew install git"
        else
            echo "  sudo apt install git"
        fi
        exit 1
    fi

    # Check if config already exists
    if [[ -d "$NVIM_CONFIG_DIR" ]] || [[ -L "$NVIM_CONFIG_DIR" ]]; then
        print_warning "Existing NeoVim config found at: $NVIM_CONFIG_DIR"

        if [[ -L "$NVIM_CONFIG_DIR" ]]; then
            local link_target
            link_target=$(readlink "$NVIM_CONFIG_DIR" 2>/dev/null || echo "unknown")
            print_info "Current config is a symlink to: $link_target"
        fi

        echo ""
        print_info "The installation script will backup your existing config automatically"
        echo ""

        if [[ "$auto_yes" == "true" ]]; then
            print_info "Auto-confirming (--yes flag)"
            REPLY="y"
        else
            read -p "Continue with installation? [Y/n] " -n 1 -r
            echo ""
        fi

        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Installation cancelled by user"
            exit 0
        fi
    fi

    # Clone repository to temporary location
    print_header "Cloning repository"
    print_info "Cloning from: $REPO_URL"
    print_info "Temporary location: $TEMP_CLONE_DIR"
    echo ""

    if git clone --depth 1 "$REPO_URL" "$TEMP_CLONE_DIR"; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        exit 1
    fi

    # Change to temp directory
    cd "$TEMP_CLONE_DIR"

    # Run the installation script
    print_header "Running installation script"
    echo ""

    if [[ "$auto_yes" == "true" ]]; then
        print_info "Running in auto-confirm mode"
        if bash ./install.sh --yes; then
            print_success "Installation completed successfully!"
        else
            print_error "Installation failed"
            exit 1
        fi
    else
        if bash ./install.sh; then
            print_success "Installation completed successfully!"
        else
            print_error "Installation failed"
            exit 1
        fi
    fi

    # Success message
    echo ""
    color_echo "╔════════════════════════════════════════════════════════════════╗"
    color_echo "║  ${GREEN}${BOLD}NeoVim IDE Configuration Installed!${NC}                          ║"
    color_echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    color_echo "${BOLD}📝 Next Steps:${NC}"
    color_echo "  ${CYAN}1.${NC} Restart your shell or activate mise:"
    color_echo "     ${YELLOW}eval \"\$(mise activate bash)\"${NC}  # for bash"
    color_echo "     ${YELLOW}eval \"\$(mise activate zsh)\"${NC}   # for zsh"
    echo ""
    color_echo "  ${CYAN}2.${NC} Start NeoVim:"
    color_echo "     ${YELLOW}nvim${NC}"
    echo ""
    color_echo "  ${CYAN}3.${NC} Plugins will install automatically on first launch"
    echo ""
    color_echo "${BOLD}📚 Configuration Location:${NC}"
    echo "  $NVIM_CONFIG_DIR"
    echo ""

    # Check for backup directory
    local backup_found=false
    for backup in "$NVIM_CONFIG_DIR.backup."*; do
        if [[ -d "$backup" ]]; then
            backup_found=true
            break
        fi
    done

    if $backup_found; then
        color_echo "${BOLD}💾 Backup Location:${NC}"
        # shellcheck disable=SC2012
        ls -td "$NVIM_CONFIG_DIR.backup."* 2>/dev/null | head -1 | while read -r backup; do
            echo "  $backup"
        done
        echo ""
    fi
}

# Run main function with all arguments
main "$@"
