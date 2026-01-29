#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_os() {
    print_status "Checking operating system..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script only supports macOS. Other operating systems are not supported yet."
        exit 1
    fi
    print_success "macOS detected"
}

# Check if git is installed
check_git() {
    print_status "Checking for git..."
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install git first and run this script again."
        print_error "You can install git from: https://git-scm.com/downloads"
        exit 1
    fi
    print_success "Git is installed: $(git --version)"
}

# Check and install Homebrew if needed
check_brew() {
    print_status "Checking for Homebrew..."
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install Homebrew first and run this script again."
        print_error "You can install Homebrew from: https://brew.sh"
        exit 1
    else
        print_success "Homebrew is already installed: $(brew --version | head -n1)"
    fi
}

# Install required software via Homebrew
install_dependencies() {
    print_status "Installing required dependencies with Homebrew..."
    
    # Update Homebrew
    print_status "Updating Homebrew..."
    brew update
    
    # List of required packages
    packages=(
        "neovim"
        "ripgrep"
        "fd"
        "fzf"
        "lazysql"
        "jesseduffield/lazydocker/lazydocker"
        "lazygit"
    )
    
    # Install Nerd Font (cask)
    print_status "Installing Hack Nerd Font..."
    if brew list --cask "font-hack-nerd-font" &>/dev/null; then
        print_warning "font-hack-nerd-font is already installed"
    else
        brew install --cask font-hack-nerd-font
        print_success "font-hack-nerd-font installed successfully"
    fi
    
    for package in "${packages[@]}"; do
        print_status "Installing $package..."
        if brew list "$package" &>/dev/null; then
            print_warning "$package is already installed"
        else
            brew install "$package"
            print_success "$package installed successfully"
        fi
    done
    
    print_success "All dependencies installed"
}

# Check if ~/.config/nvim already exists
check_nvim_config() {
    print_status "Checking for existing Neovim configuration..."
    
    if [[ -d "$HOME/.config/nvim" ]] && [[ -n "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]]; then
        print_error "Neovim configuration directory ~/.config/nvim already exists and is not empty."
        print_error "Please backup or remove the existing configuration before running this script."
        print_error "You can backup with: mv ~/.config/nvim ~/.config/nvim.backup"
        exit 1
    fi
    
    print_success "No existing Neovim configuration found"
}

# Clone the nvim config from GitHub
clone_config() {
    print_status "Cloning Neovim configuration from GitHub..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    

    git clone "https://github.com/RomanPodkovyrin/neovim.git" "$HOME/.config/nvim"

    
    print_success "Neovim configuration cloned successfully"
}

# Main installation process
main() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    LazyVim Configuration Installer for macOS${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    check_os
    check_git
    check_brew
    install_dependencies
    check_nvim_config
    clone_config
    
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}         Installation Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    print_success "LazyVim configuration has been installed successfully!"
    print_status "Next steps:"
    echo "  1. Change your terminal font to 'Hack Nerd Font' for proper icon display"
    echo "  2. Restart your terminal or run: source ~/.zprofile"
    echo "  3. Launch Neovim: nvim"
    echo "  4. LazyVim will automatically install plugins on first launch"
    echo ""
    print_warning "Note: The first launch may take a few minutes as plugins are downloaded and installed."
    print_warning "IMPORTANT: You must change your terminal font to 'Hack Nerd Font' or icons won't display correctly!"
}

# Run the installer
main "$@"