#!/usr/bin/env bash
# BD-Configs Niri-Only Installer
# Beautiful Dots for Niri with Colloid Themes & ReGreet

set -euo pipefail

# Get repository directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$REPO_DIR/lib/utils.sh"
source "$REPO_DIR/lib/checks.sh"
source "$REPO_DIR/lib/packages.sh"
source "$REPO_DIR/lib/dotfiles.sh"
source "$REPO_DIR/lib/themes.sh"
source "$REPO_DIR/lib/greeter.sh"

# Installation state variables
OPTIONAL_APPS=()

# Display welcome screen
show_welcome() {
    print_banner

    cat << 'EOF'
This installer will set up Beautiful Dots for Niri with:
  • Niri - Scrollable-tiling Wayland compositor
  • Colloid GTK/Icon Themes - Modern Material Design themes
  • ReGreet - Clean and customizable display manager
  • Cage - Minimal Wayland kiosk compositor
  • Bibata Modern Ice cursor theme
  • Your selected theme customizations

The installer will:
  1. Check your system requirements
  2. Let you choose Colloid theme options
  3. Install required packages and optional applications
  4. Deploy Niri configuration files (via symlinks)
  5. Install and configure Colloid themes
  6. Set up ReGreet display manager with Cage

Your existing .config will be backed up before any changes.

EOF

    if ! prompt_yes_no "Do you want to continue?" "y"; then
        echo ""
        log_info "Installation cancelled"
        exit 0
    fi
}

# User selection menu for optional apps
select_optional_apps() {
    log_step "Optional Applications"

    echo "Select optional applications to install (enter numbers separated by spaces, or press Enter to skip):"
    echo ""
    echo "1) Zen Browser (privacy-focused browser)"
    echo "2) Zed (modern code editor)"
    echo "3) Helium Browser (lightweight browser)"
    echo ""

    read -p "Enter your choices (e.g., '1 3' or just Enter to skip): " choices

    # Parse selections
    for choice in $choices; do
        case $choice in
            1) OPTIONAL_APPS+=("zen-browser-bin") ;;
            2) OPTIONAL_APPS+=("zed") ;;
            3) OPTIONAL_APPS+=("helium-browser-bin") ;;
            *) log_warn "Invalid choice '$choice' ignored" ;;
        esac
    done

    echo ""
    if [ ${#OPTIONAL_APPS[@]} -gt 0 ]; then
        log_info "Selected optional applications:"
        for app in "${OPTIONAL_APPS[@]}"; do
            echo "  • $app"
        done
    else
        log_info "No optional applications selected"
    fi
    echo ""
}

# Backup confirmation
confirm_backup() {
    log_step "Configuration Backup"

    log_info "Your existing ~/.config directory will be backed up before installation"
    echo ""

    if prompt_yes_no "Create backup of existing configurations?" "y"; then
        backup_existing_configs
    else
        log_warn "Skipping backup (not recommended)"
    fi
    echo ""
}

# Theme selection flow
select_theme_configuration() {
    log_step "Colloid Theme Selection"

    # Source theme selection functions
    source "$REPO_DIR/lib/themes.sh"

    # Run interactive theme selection
    select_colloid_theme_options

    # Display summary and confirm
    if ! display_theme_selection_summary; then
        log_info "Theme selection cancelled, restarting selection..."
        select_theme_configuration
        return
    fi

    # Export selections for other functions
    export SELECTED_THEME_VARIANT
    export SELECTED_COLOR_SCHEME
    export SELECTED_SIZE_VARIANT
    export SELECTED_TWEAKS
}

# Post-installation steps
post_install() {
    log_step "Post-Installation"

    echo ""
    print_separator
    echo ""
    log_success "Installation Complete!"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Reboot your system to activate ReGreet display manager"
    echo "  2. At the login screen, select 'Niri (ReGreet)' session"
    echo "  3. Log in and enjoy your beautiful desktop!"
    echo ""
    echo -e "${CYAN}Key Bindings:${NC}"
    echo "  • Super+Space    - Application launcher (fuzzel)"
    echo "  • Super+T        - Terminal (kitty)"
    echo "  • Super+Q        - Close window"
    echo "  • Super+F        - File manager (nemo)"
    echo ""
    echo -e "${CYAN}Configuration Files:${NC}"
    echo "  All configs are symlinked from: $REPO_DIR/configs/"
    echo "  Edit files in the repo and changes will apply immediately"
    echo ""
    echo -e "${CYAN}Theme Configuration:${NC}"
    echo "  Theme: Colloid-${SELECTED_COLOR_SCHEME^} (${SELECTED_THEME_VARIANT^})"
    echo "  Tweaks: $SELECTED_TWEAKS"
    echo "  Edit ReGreet config at: /etc/greetd/regreet.toml"
    echo ""
    echo -e "${CYAN}Troubleshooting:${NC}"
    echo "  If themes don't apply: Logout and login again"
    echo "  If ReGreet fails: Check logs at /var/log/regreet/log"
    echo "  If display issues: Run 'niri msg action quit' to restart"
    echo ""
    print_separator
    echo ""

    if prompt_yes_no "Reboot now?" "n"; then
        log_info "Rebooting..."
        sleep 2
        sudo reboot
    else
        log_info "Remember to reboot before using the new desktop environment"
    fi
}

# Main installation flow
main() {
    # Welcome screen
    show_welcome

    # Run system checks
    run_all_checks || die "System checks failed"

    # Theme selection
    select_theme_configuration

    # Optional apps selection
    select_optional_apps

    # Confirm backup
    confirm_backup

    # Install packages
    install_core_packages "$REPO_DIR" || die "Failed to install core packages"
    install_niri_packages "$REPO_DIR" || die "Failed to install Niri packages"
    install_theme_packages "$REPO_DIR" || die "Failed to install theme packages"
    install_required_apps "$REPO_DIR" || die "Failed to install required applications"

    if [ ${#OPTIONAL_APPS[@]} -gt 0 ]; then
        install_optional_apps "$REPO_DIR" "${OPTIONAL_APPS[@]}"
    fi

    # Deploy configurations
    deploy_configurations "$REPO_DIR" || die "Failed to deploy configurations"

    # Install and apply Colloid themes
    apply_themes "$REPO_DIR" "$SELECTED_THEME_VARIANT" "$SELECTED_COLOR_SCHEME" "$SELECTED_SIZE_VARIANT" "$SELECTED_TWEAKS" || die "Failed to apply themes"

    # Setup ReGreet greeter
    setup_regreet "$REPO_DIR" "$SELECTED_THEME_VARIANT" "$SELECTED_COLOR_SCHEME" "$SELECTED_SIZE_VARIANT" "$SELECTED_TWEAKS" || log_warn "ReGreet setup failed, but continuing with installation"

    # Post-installation
    post_install
}

# Update banner for Niri-only version
update_banner() {
    # Backup original function if it exists
    if declare -f print_banner >/dev/null; then
        # Save original but don't call it
        print_banner_original() {
            print_banner "$@"
        }
    fi

    # Override with Niri-only banner
    print_banner() {
        clear
        echo -e "${PURPLE}"
        cat << 'EOF'
 ╔════════════════════════════════════════╗
 ║                                              ║
  ║       BD-CONFIGS INSTALLER        ║
 ║                                              ║
  ║      Beautiful Dots for Niri        ║
  ║   with Colloid Themes & ReGreet     ║
 ║                                              ║
 ╚══════════════════════════════════════╝
EOF
        echo -e "${NC}"
        echo ""
    }
}

# Override the banner before running main
update_banner

# Run main installation
main