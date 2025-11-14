#!/usr/bin/env bash
#
# NeoVim IDE Configuration - Installation Script
# ================================================
#
# Installs all dependencies for the NeoVim IDE configuration.
#
# Supported Platforms:
# - macOS + Homebrew
# - Ubuntu 24.04 LTS (Noble Numbat) + Homebrew
# - Ubuntu 24.04 LTS (Noble Numbat) + apt
# - Ubuntu 22.04 LTS (Jammy Jellyfish) + Homebrew
# - Ubuntu 22.04 LTS (Jammy Jellyfish) + apt
#
# Requirements:
# - mise (https://mise.jdx.dev/)
# - For macOS: Homebrew (https://brew.sh/)
# - For Ubuntu: Either Homebrew or apt
# - Internet connection
#
# Usage:
#   ./install.sh                    # Auto-detect and install
#   ./install.sh --use-homebrew     # Force Homebrew (Linux)
#   ./install.sh --use-apt          # Force apt (Ubuntu)
#   ./install.sh --help             # Show help

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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Log file location
LOG_FILE="${SCRIPT_DIR}/install.log"

# Supported Ubuntu LTS versions
readonly SUPPORTED_UBUNTU_LTS=("22.04" "24.04")

# Package manager preference (set by flags or auto-detected)
PKG_MANAGER=""

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

# Log message to file with timestamp (only for warnings and errors)
log_to_file() {
	local level="$1"
	shift
	local message="$*"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	# Initialize log file with header if this is the first warning/error
	if [[ ! -f "$LOG_FILE" ]]; then
		{
			echo "═══════════════════════════════════════════════════════════════"
			echo "NeoVim IDE Configuration - Installation Log"
			echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
			echo "═══════════════════════════════════════════════════════════════"
			echo ""
		} >"$LOG_FILE"
	fi

	echo "[$timestamp] [$level] $message" >>"$LOG_FILE"
}

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
	log_to_file "WARNING" "$*"
}

print_error() {
	color_echo "${RED}❌${NC} $*" >&2
	log_to_file "ERROR" "$*"
}

# Check if command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Detect OS and version
detect_os() {
	local os_name=""
	local os_version=""

	if [[ "$OSTYPE" == "darwin"* ]]; then
		os_name="macos"
		os_version=$(sw_vers -productVersion)
		print_info "Detected: macOS $os_version"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		if [[ -f /etc/os-release ]]; then
			# shellcheck disable=SC1091
			source /etc/os-release
			if [[ "$ID" == "ubuntu" ]]; then
				os_name="ubuntu"
				os_version="$VERSION_ID"
				print_info "Detected: Ubuntu $os_version ($VERSION_CODENAME)"

				# Check if supported LTS version
				local supported=false
				for lts in "${SUPPORTED_UBUNTU_LTS[@]}"; do
					if [[ "$os_version" == "$lts" ]]; then
						supported=true
						break
					fi
				done

				if ! $supported; then
					print_warning "Ubuntu $os_version is not a tested LTS version"
					print_warning "Supported versions: ${SUPPORTED_UBUNTU_LTS[*]}"
					print_warning "Installation may work but is not officially supported"
				fi
			else
				print_error "Unsupported Linux distribution: $ID"
				print_error "This script only supports Ubuntu Linux"
				exit 1
			fi
		else
			print_error "Cannot detect Linux distribution"
			exit 1
		fi
	else
		print_error "Unsupported operating system: $OSTYPE"
		exit 1
	fi

	echo "$os_name:$os_version"
}

# Detect or set package manager
detect_package_manager() {
	# If already set by flag, validate it
	if [[ -n "$PKG_MANAGER" ]]; then
		print_info "Using package manager: $PKG_MANAGER (specified by flag)"
		return
	fi

	# Auto-detect based on OS
	if [[ "$OSTYPE" == "darwin"* ]]; then
		PKG_MANAGER="brew"
		print_info "Using package manager: Homebrew (macOS default)"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Prefer Homebrew if installed, otherwise apt
		if command_exists brew; then
			PKG_MANAGER="brew"
			print_info "Using package manager: Homebrew (detected)"
		else
			PKG_MANAGER="apt"
			print_info "Using package manager: apt (Ubuntu default)"
		fi
	else
		print_error "Unable to detect package manager for OS: $OSTYPE"
		exit 1
	fi
}

# Check if Homebrew is installed
check_homebrew() {
	if ! command_exists brew; then
		print_error "Homebrew is not installed"
		echo ""
		if [[ "$OSTYPE" == "darwin"* ]]; then
			echo "Install Homebrew:"
			echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
		else
			echo "Install Homebrew on Linux:"
			echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
			echo ""
			echo "Or use apt instead: ./install.sh --use-apt"
		fi
		exit 1
	fi
	print_success "Homebrew is installed: $(brew --version | head -1)"
}

# Check if mise is installed
check_mise() {
	if ! command_exists mise; then
		print_error "mise is not installed"
		echo ""
		echo "Install mise:"
		echo "  curl https://mise.run | sh"
		echo ""
		echo "Or visit: https://mise.jdx.dev/getting-started.html"
		echo ""
		echo "After installation, add to your shell profile:"
		echo "  eval \"\$(mise activate bash)\"  # for bash"
		echo "  eval \"\$(mise activate zsh)\"   # for zsh"
		exit 1
	fi
	print_success "mise is installed: $(mise --version)"
}

# Install tools via mise
install_mise_tools() {
	print_header "Installing development tools via mise"

	cd "$SCRIPT_DIR"

	# Install tools defined in .mise.toml
	print_info "Running: mise install"
	if mise install; then
		print_success "All mise tools installed successfully"
	else
		print_error "Failed to install some mise tools"
		print_warning "Check mise output above for details"
		return 1
	fi

	# Activate mise environment for this script
	eval "$(mise activate bash)"
	print_success "mise environment activated"
}

#------------------------------------------------------------------------------
# System Package Installation
#------------------------------------------------------------------------------

# Install system packages via Homebrew
install_homebrew_packages() {
	print_header "Installing system tools via Homebrew"

	# Required packages
	local required_packages=(
		"git"      # Git (if not already installed)
		"luarocks" # Lua package manager
	)

	# Optional but recommended packages
	local optional_packages=(
		"ripgrep"    # Fast grep (for Telescope)
		"fd"         # Fast find (for Telescope)
		"lazygit"    # Git TUI
		"bat"        # Better cat with syntax highlighting
		"delta"      # Better git diff viewer
		"eza"        # Better ls (formerly exa)
		"fzf"        # Fuzzy finder (general use)
		"gh"         # GitHub CLI
		"jq"         # JSON processor (for rest.nvim HTTP client)
		"tidy-html5" # HTML formatter (for rest.nvim)
		"tree"       # Directory tree viewer
		"shellcheck" # Shell script linter
		"shfmt"      # Shell script formatter
		"actionlint" # GitHub Actions workflow linter (for nvim-lint)
		"codespell"  # Spell checker (for nvim-lint)
		"gitlint"    # Git commit message linter (for nvim-lint)
		"checkmake"  # Makefile linter (for nvim-lint)
	)

	# Install required packages
	print_info "Installing required packages..."
	for package in "${required_packages[@]}"; do
		if brew list "$package" &>/dev/null; then
			print_success "$package is already installed"
		else
			print_info "Installing $package..."
			if brew install "$package"; then
				print_success "$package installed"
			else
				print_error "Failed to install $package (required)"
				return 1
			fi
		fi
	done

	# Install optional packages
	print_info "Installing optional packages..."
	for package in "${optional_packages[@]}"; do
		if brew list "$package" &>/dev/null; then
			print_success "$package is already installed"
		else
			print_info "Installing $package..."
			if brew install "$package"; then
				print_success "$package installed"
			else
				print_warning "Failed to install $package (optional)"
			fi
		fi
	done
}

# Add third-party APT repositories (verified, no snap)
add_apt_repositories() {
	print_header "Adding third-party APT repositories"

	# Note: We don't use ubuntu_version here, but keeping detect_os call
	# in case we need version-specific logic in the future
	detect_os >/dev/null

	# Neovim stable PPA (official)
	if ! grep -q "neovim-ppa/stable" /etc/apt/sources.list.d/* 2>/dev/null; then
		print_info "Adding Neovim stable PPA..."
		sudo add-apt-repository -y ppa:neovim-ppa/stable
		print_success "Neovim PPA added"
	else
		print_success "Neovim PPA already configured"
	fi

	# Git stable PPA (official)
	if ! grep -q "git-core/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
		print_info "Adding Git stable PPA..."
		sudo add-apt-repository -y ppa:git-core/ppa
		print_success "Git PPA added"
	else
		print_success "Git PPA already configured"
	fi

	# Lazygit PPA (community maintained but trusted)
	if ! grep -q "lazygit-team/release" /etc/apt/sources.list.d/* 2>/dev/null; then
		print_info "Adding Lazygit PPA..."
		sudo add-apt-repository -y ppa:lazygit-team/release
		print_success "Lazygit PPA added"
	else
		print_success "Lazygit PPA already configured"
	fi

	print_info "Updating package lists..."
	sudo apt-get update
}

# Install system packages via apt
install_apt_packages() {
	print_header "Installing system tools via apt"

	# Update package lists
	print_info "Updating package lists..."
	sudo apt-get update

	# Essential packages
	local essential_packages=(
		"build-essential"            # Compilers and build tools
		"curl"                       # For downloading
		"wget"                       # For downloading
		"git"                        # Version control
		"unzip"                      # Archive extraction
		"zip"                        # Archive creation
		"software-properties-common" # For add-apt-repository
	)

	print_info "Installing essential packages..."
	# shellcheck disable=SC2068
	sudo apt-get install -y ${essential_packages[@]}

	# Required packages
	local required_packages=(
		"neovim"   # NeoVim (from PPA)
		"luarocks" # Lua package manager
	)

	# Optional but recommended packages
	local optional_packages=(
		"ripgrep"    # Fast grep (for Telescope)
		"fd-find"    # Fast find (fd is called fd-find on Ubuntu)
		"lazygit"    # Git TUI (from PPA)
		"bat"        # Better cat with syntax highlighting
		"fzf"        # Fuzzy finder
		"jq"         # JSON processor (for rest.nvim HTTP client)
		"tidy"       # HTML formatter (for rest.nvim)
		"tree"       # Directory tree viewer
		"shellcheck" # Shell script linter
		"shfmt"      # Shell script formatter
		"codespell"  # Spell checker (for nvim-lint)
	)

	# Install required packages
	print_info "Installing required packages..."
	for package in "${required_packages[@]}"; do
		if dpkg -l | grep -q "^ii  $package "; then
			print_success "$package is already installed"
		else
			print_info "Installing $package..."
			if sudo apt-get install -y "$package"; then
				print_success "$package installed"
			else
				print_error "Failed to install $package (required)"
				return 1
			fi
		fi
	done

	# Install optional packages
	print_info "Installing optional packages..."
	for package in "${optional_packages[@]}"; do
		if dpkg -l | grep -q "^ii  $package "; then
			print_success "$package is already installed"
		else
			print_info "Installing $package..."
			if sudo apt-get install -y "$package"; then
				print_success "$package installed"
			else
				print_warning "Failed to install $package (optional)"
			fi
		fi
	done

	# Create symlink for fd (Ubuntu calls it fd-find)
	if command_exists fdfind && ! command_exists fd; then
		print_info "Creating fd symlink..."
		sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
		print_success "fd symlink created"
	fi

	# Create symlink for bat (Ubuntu calls it batcat)
	if command_exists batcat && ! command_exists bat; then
		print_info "Creating bat symlink..."
		sudo ln -sf "$(which batcat)" /usr/local/bin/bat
		print_success "bat symlink created"
	fi

	# Install delta (better git diff) - not in apt, install via cargo or download
	if ! command_exists delta; then
		print_info "delta not available via apt (will install via cargo later if rust is available)"
	fi

	# Install eza (better ls) - not in standard apt repos
	if ! command_exists eza; then
		print_info "eza not available via apt (optional, can install manually from https://github.com/eza-community/eza)"
	fi

	# Linters for nvim-lint (not in apt, can install via pip or Homebrew)
	if ! command_exists actionlint; then
		print_info "actionlint not available via apt (optional linter for nvim-lint)"
		print_info "Install via: go install github.com/rhysd/actionlint/cmd/actionlint@latest"
	fi
	if ! command_exists gitlint; then
		print_info "gitlint not available via apt (optional linter for nvim-lint)"
		print_info "Install via: pip install --user gitlint"
	fi
	if ! command_exists checkmake; then
		print_info "checkmake not available via apt (optional linter for nvim-lint)"
		print_info "Install via: go install github.com/mrtazz/checkmake/cmd/checkmake@latest"
	fi
}

# Install system packages based on package manager
install_system_packages() {
	if [[ "$PKG_MANAGER" == "brew" ]]; then
		check_homebrew
		install_homebrew_packages
	elif [[ "$PKG_MANAGER" == "apt" ]]; then
		add_apt_repositories
		install_apt_packages
	else
		print_error "Unknown package manager: $PKG_MANAGER"
		exit 1
	fi
}

#------------------------------------------------------------------------------
# Language-specific Package Installation
#------------------------------------------------------------------------------

# Install Lua packages via luarocks
install_lua_packages() {
	print_header "Installing Lua development tools"

	if ! command_exists luarocks; then
		print_error "luarocks not found (should have been installed earlier)"
		return 1
	fi

	local lua_packages=(
		"busted"   # Testing framework (required)
		"luacheck" # Lua linter (required for development)
		"luacov"   # Code coverage tool (optional)
		"lanes"    # Multithreading support (for busted)
	)

	for package in "${lua_packages[@]}"; do
		print_info "Installing $package..."
		# Try local install first, fall back to user install
		if luarocks install --local "$package" 2>/dev/null; then
			print_success "$package installed (local)"
		elif luarocks install --tree="$HOME/.luarocks" "$package" 2>/dev/null; then
			print_success "$package installed (user)"
		elif luarocks show "$package" >/dev/null 2>&1; then
			print_success "$package already installed"
		else
			print_warning "Failed to install $package (may need manual installation)"
		fi
	done

	# Set up luarocks path
	print_info "Configuring luarocks path..."
	local luarocks_path
	luarocks_path=$(luarocks path --lr-path 2>/dev/null || echo "")
	local luarocks_cpath
	luarocks_cpath=$(luarocks path --lr-cpath 2>/dev/null || echo "")

	if [[ -n "$luarocks_path" ]]; then
		export LUA_PATH="$luarocks_path"
		export LUA_CPATH="$luarocks_cpath"
		print_success "luarocks path configured"
	fi
}

# Install Node.js global packages
install_node_packages() {
	print_header "Installing Node.js global packages"

	if ! command_exists npm; then
		print_warning "npm not found (node should be installed by mise)"
		print_warning "Run: eval \"\$(mise activate bash)\" and try again"
		return 1
	fi

	local node_packages=(
		"neovim"                           # NeoVim Node.js provider (required)
		"tree-sitter-cli"                  # TreeSitter CLI (required for parsers)
		"eslint"                           # JavaScript/TypeScript linter
		"typescript"                       # TypeScript compiler
		"@typescript-eslint/parser"        # TypeScript parser for ESLint
		"@typescript-eslint/eslint-plugin" # TypeScript rules for ESLint
		"eslint-config-standard"           # Standard.js config for ESLint (optional)
		"markdownlint-cli"                 # Markdown linter
		"prettier"                         # Code formatter (JS/TS/JSON/Markdown/YAML)
		"eslint-config-prettier"           # Disable ESLint rules that conflict with Prettier
		"eslint-plugin-prettier"           # Run Prettier as an ESLint rule
		"@olrtg/emmet-language-server"     # Emmet abbreviations LSP
		"ts-node"                          # TypeScript REPL for iron.nvim
	)

	for package in "${node_packages[@]}"; do
		print_info "Installing $package..."
		if npm install -g "$package"; then
			print_success "$package installed"
		else
			print_warning "Failed to install $package"
		fi
	done

	print_info "Node.js version: $(node --version)"
	print_info "npm version: $(npm --version)"
}

# Install Python packages
install_python_packages() {
	print_header "Installing Python packages"

	if ! command_exists python3; then
		print_warning "python3 not found (should be installed by mise)"
		return 1
	fi

	local pip_cmd="python3 -m pip"

	# Ensure pip is installed
	if ! python3 -m pip --version &>/dev/null; then
		print_info "Installing pip..."
		python3 -m ensurepip --default-pip || python3 -m ensurepip --user
	fi

	local python_packages=(
		"pynvim"     # NeoVim Python provider (required)
		"debugpy"    # Python debugger for DAP (optional but recommended)
		"ruff"       # Fast Python linter and formatter (required for lint-check.sh)
		"mypy"       # Python type checker (required for type-check.sh)
		"black"      # Python formatter (for auto-fixing, works with ruff)
		"gitlint"    # Git commit message linter (for nvim-lint)
		"aider-chat" # AI pair programming tool (optional but recommended)
	)

	for package in "${python_packages[@]}"; do
		print_info "Installing $package..."
		if $pip_cmd install --user "$package"; then
			print_success "$package installed"
		else
			print_warning "Failed to install $package"
		fi
	done

	print_info "Python version: $(python3 --version)"
}

# Install Ruby gems
install_ruby_gems() {
	print_header "Installing Ruby gems"

	if ! command_exists gem; then
		print_warning "gem not found (ruby should be installed by mise)"
		return 1
	fi

	local ruby_gems=(
		"neovim"              # NeoVim Ruby provider (required)
		"solargraph"          # Ruby LSP for Rails projects
		"debug"               # Ruby debugger (rdbg) for DAP integration
		"rubocop"             # Ruby linter and formatter
		"rubocop-performance" # Performance cops for RuboCop
		"rubocop-rspec"       # RSpec cops for RuboCop
		"rubocop-rails"       # Rails cops for RuboCop
		"standardrb"          # Ruby Standard Style (alternative to Rubocop)
	)

	for gem_name in "${ruby_gems[@]}"; do
		print_info "Installing $gem_name..."
		if gem install --user-install "$gem_name"; then
			print_success "$gem_name installed"
		else
			print_warning "Failed to install $gem_name"
		fi
	done

	print_info "Ruby version: $(ruby --version)"
}

# Install Rust-based tools via cargo
install_cargo_tools() {
	print_header "Installing Rust-based development tools"

	if ! command_exists cargo; then
		print_warning "cargo not found (rust should be installed by mise)"
		return 1
	fi

	# Required cargo tools
	local required_tools=(
		"stylua" # Lua formatter (required for auto-fix.sh)
	)

	# Optional cargo tools
	local optional_tools=(
		"git-delta" # Better git diff viewer (installs as 'delta')
		"eza"       # Better ls (formerly exa)
	)

	# Install required tools
	for tool in "${required_tools[@]}"; do
		local bin_name="$tool"
		if [[ "$tool" == "git-delta" ]]; then
			bin_name="delta"
		fi

		if command_exists "$bin_name"; then
			print_success "$tool already installed"
		else
			print_info "Installing $tool..."
			if cargo install "$tool"; then
				print_success "$tool installed"
			else
				print_error "Failed to install $tool (required)"
				return 1
			fi
		fi
	done

	# Install optional tools
	for tool in "${optional_tools[@]}"; do
		local bin_name="$tool"
		if [[ "$tool" == "git-delta" ]]; then
			bin_name="delta"
		fi

		if command_exists "$bin_name"; then
			print_success "$tool already installed"
		else
			print_info "Installing $tool..."
			if cargo install "$tool"; then
				print_success "$tool installed"
			else
				print_warning "Failed to install $tool (optional)"
			fi
		fi
	done

	print_info "Cargo version: $(cargo --version)"
}

#------------------------------------------------------------------------------
# Font Installation
#------------------------------------------------------------------------------

# Install Nerd Fonts
install_nerd_fonts() {
	print_header "Installing Nerd Fonts"

	print_info "Nerd Fonts provide icons for file types and UI elements 💎"
	print_info "They are large downloads (~100-200 MB per font) 📥"
	print_info "Installing fonts automatically... (use --skip-optional to skip)"
	echo ""

	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS: Use Homebrew Cask
		print_info "Installing Nerd Fonts via Homebrew..."

		local fonts=(
			"font-hack-nerd-font"           # Hack (popular monospace)
			"font-jetbrains-mono-nerd-font" # JetBrains Mono (popular for coding)
			"font-fira-code-nerd-font"      # Fira Code (ligatures)
		)

		for font in "${fonts[@]}"; do
			if brew list --cask "$font" &>/dev/null; then
				print_success "$font is already installed"
			else
				print_info "Installing $font..."
				if brew install --cask "$font"; then
					print_success "$font installed"
				else
					print_warning "Failed to install $font"
				fi
			fi
		done

		print_success "Nerd Fonts installed!"
		print_info "To use: Set your terminal font to 'Hack Nerd Font', 'JetBrainsMono Nerd Font', or 'FiraCode Nerd Font'"

	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# Linux: Download and install manually
		print_info "Installing Nerd Fonts manually..."

		local fonts_dir="$HOME/.local/share/fonts"
		mkdir -p "$fonts_dir"

		local temp_dir
		temp_dir=$(mktemp -d)

		# Download popular Nerd Fonts
		local font_urls=(
			"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"
			"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
			"https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
		)

		for url in "${font_urls[@]}"; do
			local font_name
			font_name=$(basename "$url" .zip)
			print_info "Downloading $font_name..."

			if curl -L -o "$temp_dir/$font_name.zip" "$url"; then
				print_info "Extracting $font_name..."
				unzip -q "$temp_dir/$font_name.zip" -d "$fonts_dir/$font_name"
				print_success "$font_name installed"
			else
				print_warning "Failed to download $font_name"
			fi
		done

		# Update font cache
		print_info "Updating font cache..."
		if fc-cache -fv &>/dev/null; then
			print_success "Font cache updated"
		else
			print_warning "Failed to update font cache (you may need to restart)"
		fi

		# Cleanup
		rm -rf "$temp_dir"

		print_success "Nerd Fonts installed!"
		print_info "To use: Set your terminal font to 'Hack Nerd Font', 'JetBrainsMono Nerd Font', or 'FiraCode Nerd Font'"
	fi
}

#------------------------------------------------------------------------------
# Configuration Setup
#------------------------------------------------------------------------------

# Setup NeoVim configuration
setup_nvim_config() {
	print_header "Setting up NeoVim configuration"

	local auto_yes="${1:-false}"
	local nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

	# Backup existing config if it exists and is not a symlink
	if [[ -d "$nvim_config_dir" ]] && [[ ! -L "$nvim_config_dir" ]]; then
		local backup_dir
		backup_dir="${nvim_config_dir}.backup.$(date +%Y%m%d_%H%M%S)"

		print_warning "Existing NeoVim config found at: $nvim_config_dir"
		print_info "This will be backed up to: $backup_dir"
		echo ""

		if [[ "$auto_yes" == "true" ]]; then
			print_info "Auto-confirming backup (--yes flag)"
			REPLY="y"
		else
			read -p "Continue with backup and installation? [Y/n] " -n 1 -r
			echo ""
		fi

		if [[ $REPLY =~ ^[Nn]$ ]]; then
			print_info "Installation cancelled by user"
			exit 0
		fi

		print_info "Backing up existing config..."
		mv "$nvim_config_dir" "$backup_dir"
		print_success "Backup created at: $backup_dir"
	fi

	# Remove broken symlink if it exists
	if [[ -L "$nvim_config_dir" ]] && [[ ! -e "$nvim_config_dir" ]]; then
		print_warning "Removing broken symlink"
		rm "$nvim_config_dir"
	fi

	# Create parent directory if needed
	mkdir -p "$(dirname "$nvim_config_dir")"

	# Create symlink
	if [[ ! -e "$nvim_config_dir" ]]; then
		print_info "Creating symlink: $nvim_config_dir -> $SCRIPT_DIR"
		ln -sf "$SCRIPT_DIR" "$nvim_config_dir"
		print_success "NeoVim config linked"
	else
		print_success "NeoVim config already linked"
	fi

	# Verify symlink
	if [[ -L "$nvim_config_dir" ]]; then
		local link_target
		link_target=$(readlink "$nvim_config_dir")
		print_info "Symlink target: $link_target"
	fi
}

#------------------------------------------------------------------------------
# Verification
#------------------------------------------------------------------------------

# Verify installation
verify_installation() {
	print_header "Verifying installation"

	local all_good=true
	local warnings=0

	# Check core development tools (from mise)
	echo ""
	color_echo "${BOLD}📦 Core Development Tools (mise):${NC}"

	local core_tools=(
		"nvim:NeoVim:nvim --version | head -1"
		"node:Node.js:node --version"
		"npm:npm:npm --version"
		"python3:Python:python3 --version"
		"ruby:Ruby:ruby --version"
		"lua:Lua:lua -v"
		"go:Go:go version"
		"cargo:Rust:cargo --version"
	)

	for tool_spec in "${core_tools[@]}"; do
		IFS=':' read -r cmd name version_cmd <<<"$tool_spec"
		if command_exists "$cmd"; then
			local version
			version=$(eval "$version_cmd" 2>&1 | head -1)
			printf "  ${GREEN}✓${NC} %-15s %s\n" "$name" "$version"
		else
			printf "  ${RED}✗${NC} %-15s ${RED}Not found${NC}\n" "$name"
			all_good=false
		fi
	done

	# Check system tools
	echo ""
	color_echo "${BOLD}🔧 System Tools:${NC}"

	local system_tools=(
		"git:Git:git --version"
		"luarocks:LuaRocks:luarocks --version | head -1"
	)

	for tool_spec in "${system_tools[@]}"; do
		IFS=':' read -r cmd name version_cmd <<<"$tool_spec"
		if command_exists "$cmd"; then
			local version
			version=$(eval "$version_cmd" 2>&1 | head -1)
			printf "  ${GREEN}✓${NC} %-15s %s\n" "$name" "$version"
		else
			printf "  ${RED}✗${NC} %-15s ${RED}Not found${NC}\n" "$name"
			all_good=false
		fi
	done

	# Check optional tools
	echo ""
	color_echo "${BOLD}🎨 Optional Tools:${NC}"

	local optional_tools=(
		"rg:ripgrep"
		"fd:fd-find"
		"lazygit:lazygit"
		"bat:bat"
		"delta:delta"
		"eza:eza"
		"fzf:fzf"
		"gh:GitHub CLI"
		"jq:jq"
		"tree:tree"
		"actionlint:actionlint"
		"codespell:codespell"
		"gitlint:gitlint"
		"checkmake:checkmake"
	)

	for tool_spec in "${optional_tools[@]}"; do
		IFS=':' read -r cmd name <<<"$tool_spec"
		if command_exists "$cmd"; then
			printf "  ${GREEN}✓${NC} %-15s installed\n" "$name"
		else
			printf "  ${YELLOW}○${NC} %-15s ${YELLOW}not installed (optional)${NC}\n" "$name"
			((warnings++))
		fi
	done

	# Check for Nerd Fonts
	echo ""
	color_echo "${BOLD}🔤 Fonts:${NC}"
	local nerd_fonts_installed=false

	if [[ "$OSTYPE" == "darwin"* ]]; then
		# Check macOS fonts via fc-list or system_profiler
		if fc-list 2>/dev/null | grep -i "nerd font" &>/dev/null; then
			nerd_fonts_installed=true
		fi
	else
		# Check Linux fonts via fc-list
		if command_exists fc-list && fc-list 2>/dev/null | grep -i "nerd font" &>/dev/null; then
			nerd_fonts_installed=true
		fi
	fi

	if $nerd_fonts_installed; then
		printf "  ${GREEN}✓${NC} %-15s installed\n" "Nerd Fonts"
	else
		printf "  ${YELLOW}○${NC} %-15s ${YELLOW}not installed (optional but recommended for icons)${NC}\n" "Nerd Fonts"
		((warnings++))
	fi

	# Check Lua packages
	echo ""
	color_echo "${BOLD}🌙 Lua Packages:${NC}"

	local lua_packages=("busted" "luacheck")
	for package in "${lua_packages[@]}"; do
		if command_exists "$package"; then
			printf "  ${GREEN}✓${NC} %-15s installed\n" "$package"
		elif luarocks show "$package" &>/dev/null; then
			printf "  ${GREEN}✓${NC} %-15s installed (via luarocks)\n" "$package"
		else
			printf "  ${YELLOW}○${NC} %-15s ${YELLOW}not found${NC}\n" "$package"
			((warnings++))
		fi
	done

	# Check NeoVim providers
	echo ""
	color_echo "${BOLD}🔌 NeoVim Providers:${NC}"

	if command_exists nvim; then
		# Note: We could use checkhealth output, but direct checks are more reliable
		# provider_status=$(nvim --headless -c 'checkhealth provider' -c 'quit' 2>&1 || echo "")

		# Check each provider
		local providers=("python3" "node" "ruby")
		for provider in "${providers[@]}"; do
			if python3 -c "import pynvim" 2>/dev/null && [[ "$provider" == "python3" ]]; then
				printf "  ${GREEN}✓${NC} %-15s provider OK\n" "$provider"
			elif command_exists neovim-node-host && [[ "$provider" == "node" ]]; then
				printf "  ${GREEN}✓${NC} %-15s provider OK\n" "$provider"
			elif gem list | grep -q "^neovim " && [[ "$provider" == "ruby" ]]; then
				printf "  ${GREEN}✓${NC} %-15s provider OK\n" "$provider"
			else
				printf "  ${YELLOW}○${NC} %-15s ${YELLOW}provider not configured${NC}\n" "$provider"
				((warnings++))
			fi
		done
	else
		print_warning "Cannot check NeoVim providers (nvim not found)"
	fi

	# Summary
	echo ""
	echo "═══════════════════════════════════════════════════════════════"

	if $all_good && [[ $warnings -eq 0 ]]; then
		print_success "All required tools are installed and configured!"
		return 0
	elif $all_good; then
		print_success "All required tools are installed!"
		print_warning "$warnings optional components missing (see above)"
		return 0
	else
		print_error "Some required tools are missing!"
		print_warning "Please review the output above and install missing tools"
		return 1
	fi
}

#------------------------------------------------------------------------------
# Help and Usage
#------------------------------------------------------------------------------

show_help() {
	cat <<EOF
${BOLD}NeoVim IDE Configuration - Installation Script${NC}
═══════════════════════════════════════════════════════════════

${BOLD}Usage:${NC}
  $0 [OPTIONS]

${BOLD}Options:${NC}
  --help              Show this help message
  --yes, -y           Auto-confirm all prompts (non-interactive mode)
  --use-homebrew      Force use of Homebrew (Linux only)
  --use-apt           Force use of apt (Ubuntu only)
  --skip-optional     Skip installation of optional tools
  --verify-only       Only verify installation, don't install anything
  --no-config         Don't setup NeoVim config symlink

${BOLD}Supported Platforms:${NC}
  ✓ macOS + Homebrew
  ✓ Ubuntu 24.04 LTS (Noble Numbat) + Homebrew
  ✓ Ubuntu 24.04 LTS (Noble Numbat) + apt
  ✓ Ubuntu 22.04 LTS (Jammy Jellyfish) + Homebrew
  ✓ Ubuntu 22.04 LTS (Jammy Jellyfish) + apt

${BOLD}Description:${NC}
  This script installs all dependencies for the NeoVim IDE configuration:

  ${CYAN}1.${NC} Checks for mise (tool version manager)
  ${CYAN}2.${NC} Installs development tools via mise (neovim, node, python, ruby, lua, go, rust)
  ${CYAN}3.${NC} Installs system packages (git, luarocks, ripgrep, fd, lazygit, bat, delta, etc.)
  ${CYAN}4.${NC} Installs Lua packages (busted, luacheck, luacov)
  ${CYAN}5.${NC} Installs language-specific packages (npm, pip, gem, cargo tools)
  ${CYAN}6.${NC} Installs linters for nvim-lint (actionlint, codespell, gitlint, checkmake)
  ${CYAN}7.${NC} Installs Nerd Fonts (optional, with user prompt)
  ${CYAN}8.${NC} Sets up NeoVim configuration symlink
  ${CYAN}9.${NC} Verifies installation

${BOLD}Requirements:${NC}
  • mise (https://mise.jdx.dev/) - ${YELLOW}Required${NC}
  • Homebrew (macOS) or apt (Ubuntu) - ${YELLOW}Required${NC}
  • Internet connection - ${YELLOW}Required${NC}

${BOLD}Examples:${NC}
  ${CYAN}# Full installation (auto-detect package manager)${NC}
  ./install.sh

  ${CYAN}# Use Homebrew on Ubuntu${NC}
  ./install.sh --use-homebrew

  ${CYAN}# Use apt on Ubuntu${NC}
  ./install.sh --use-apt

  ${CYAN}# Skip optional tools${NC}
  ./install.sh --skip-optional

  ${CYAN}# Just verify what's installed${NC}
  ./install.sh --verify-only

${BOLD}After Installation:${NC}
  1. Restart your shell or run: ${CYAN}eval "\$(mise activate bash)"${NC}
  2. Start NeoVim: ${CYAN}nvim${NC}
  3. Wait for plugins to auto-install (via lazy.nvim)
  4. Run tests: ${CYAN}cd $SCRIPT_DIR && busted${NC}

${BOLD}For More Information:${NC}
  • See: README.md
  • See: CLAUDE.md (development plan)
  • Issues: Report bugs to the repository

EOF
}

#------------------------------------------------------------------------------
# Main Installation Flow
#------------------------------------------------------------------------------

main() {
	local skip_optional=false
	local verify_only=false
	local no_config=false
	local auto_yes=false

	# Parse command-line arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		--help | -h)
			show_help
			exit 0
			;;
		--use-homebrew)
			PKG_MANAGER="brew"
			shift
			;;
		--use-apt)
			PKG_MANAGER="apt"
			shift
			;;
		--skip-optional)
			skip_optional=true
			shift
			;;
		--verify-only)
			verify_only=true
			shift
			;;
		--no-config)
			no_config=true
			shift
			;;
		--yes | -y)
			auto_yes=true
			shift
			;;
		*)
			print_error "Unknown option: $1"
			echo "Use --help for usage information"
			exit 1
			;;
		esac
	done

	# Print banner
	echo ""
	color_echo "╔════════════════════════════════════════════════════════════════╗"
	color_echo "║  ${BOLD}NeoVim IDE Configuration - Installation Script${NC}                ║"
	color_echo "╚════════════════════════════════════════════════════════════════╝"
	echo ""

	# Verify-only mode
	if $verify_only; then
		verify_installation
		exit $?
	fi

	# Start installation
	print_info "Starting installation..."
	echo ""

	# Step 1: Detect OS and package manager
	detect_package_manager

	# Step 2: Check prerequisites
	check_mise

	# Step 3: Install development tools via mise
	install_mise_tools

	# Step 4: Install system packages
	install_system_packages

	# Step 5: Install Lua packages
	install_lua_packages

	# Step 6: Install language-specific packages
	install_node_packages
	install_python_packages
	install_ruby_gems
	install_cargo_tools

	# Step 7: Install Nerd Fonts (optional, with prompt)
	if ! $skip_optional; then
		install_nerd_fonts
	else
		print_info "Skipping Nerd Fonts installation (--skip-optional flag)"
	fi

	# Step 8: Setup NeoVim configuration
	if ! $no_config; then
		setup_nvim_config "$auto_yes"
	else
		print_info "Skipping NeoVim config setup (--no-config flag)"
	fi

	# Step 9: Verify installation
	echo ""
	if verify_installation; then
		echo ""
		color_echo "╔════════════════════════════════════════════════════════════════╗"
		color_echo "║  ${GREEN}${BOLD}Installation Complete!${NC}                                        ║"
		color_echo "╚════════════════════════════════════════════════════════════════╝"
		echo ""

		# Check if there were any warnings/errors logged
		if [[ -f "$LOG_FILE" ]]; then
			color_echo "${YELLOW}⚠️  Some warnings were encountered during installation${NC}"
			color_echo "   Check the log file for details: ${YELLOW}$LOG_FILE${NC}"
			echo ""
		fi

		color_echo "${BOLD}📝 Next Steps:${NC}"
		color_echo "  ${CYAN}1.${NC} Restart your shell or activate mise:"
		color_echo "     ${YELLOW}eval \"\$(mise activate bash)\"${NC}  # for bash"
		color_echo "     ${YELLOW}eval \"\$(mise activate zsh)\"${NC}   # for zsh"
		echo ""
		color_echo "  ${CYAN}2.${NC} Start NeoVim:"
		color_echo "     ${YELLOW}nvim${NC}"
		echo ""
		color_echo "  ${CYAN}3.${NC} Wait for plugins to install automatically (lazy.nvim)"
		echo ""
		color_echo "  ${CYAN}4.${NC} Run the test suite:"
		color_echo "     ${YELLOW}cd $SCRIPT_DIR && busted${NC}"
		echo ""
		color_echo "  ${CYAN}5.${NC} Check health:"
		color_echo "     ${YELLOW}:checkhealth${NC} (inside NeoVim)"
		echo ""
		color_echo "${BOLD}📚 Documentation:${NC}"
		echo "  • README.md - User guide"
		echo "  • CLAUDE.md - Development plan"
		echo "  • docs/ - Additional documentation"
		echo ""
	else
		echo ""
		color_echo "╔════════════════════════════════════════════════════════════════╗"
		color_echo "║  ${YELLOW}${BOLD}Installation Completed with Warnings${NC}                          ║"
		color_echo "╚════════════════════════════════════════════════════════════════╝"
		echo ""
		print_warning "Some components are missing or not configured properly"
		print_warning "Review the verification output above"
		echo ""
		color_echo "${BOLD}🔍 Troubleshooting:${NC}"
		color_echo "  • Run: ${YELLOW}./install.sh --verify-only${NC} to check what's missing"
		echo "  • See: docs/TROUBLESHOOTING.md"
		echo "  • Check: mise doctor"
		if [[ -f "$LOG_FILE" ]]; then
			color_echo "  • View log: ${YELLOW}cat $LOG_FILE${NC}"
			echo ""
			color_echo "${BOLD}📋 Full log with errors and warnings:${NC} ${YELLOW}$LOG_FILE${NC}"
		fi
		echo ""
	fi
}

# Run main function with all arguments
main "$@"
