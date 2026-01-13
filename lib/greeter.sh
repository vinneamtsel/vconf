#!/usr/bin/env bash
# ReGreet greeter setup functions for bd-configs installer

# Source utils for logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Install ReGreet and dependencies
install_regreet_packages() {
    local repo_dir="$1"
    log_step "Installing ReGreet Display Manager"

    if [ ! -f "$repo_dir/packages/themes.txt" ]; then
        log_error "Theme packages file not found: $repo_dir/packages/themes.txt"
        return 1
    fi

    # Check if AUR_HELPER is set
    if [ -z "${AUR_HELPER:-}" ]; then
        log_error "AUR_HELPER variable is not set. Please ensure system checks have run."
        return 1
    fi

    log_info "Installing ReGreet and dependencies..."

    # Install from themes package list (colloid themes are there)
    install_package_list "$repo_dir/packages/themes.txt" "Theme Packages"

    if [ $? -eq 0 ]; then
        log_success "ReGreet dependencies installed successfully"
        return 0
    else
        log_error "Failed to install ReGreet dependencies"
        return 1
    fi
}

# Disable conflicting display managers
disable_other_display_managers() {
    log_info "Checking for conflicting display managers..."

    local disabled_any=false
    for dm in gdm sddm lightdm lxdm; do
        if systemctl is-enabled "${dm}.service" &>/dev/null; then
            log_warn "Disabling ${dm} display manager..."
            sudo systemctl disable "${dm}.service"
            disabled_any=true
        fi
    done

    if [ "$disabled_any" = false ]; then
        log_info "No conflicting display managers found"
    else
        log_success "Conflicting display managers disabled"
    fi
}

# Enable greetd service
enable_greetd() {
    log_info "Enabling greetd service..."

    if systemctl is-enabled greetd.service &>/dev/null; then
        log_info "greetd is already enabled"
    else
        sudo systemctl enable greetd.service
        log_success "greetd service enabled"
    fi
}

# Create ReGreet configuration directory and config file
configure_regreet() {
    local theme_color="$1"     # grey, default, purple, etc.
    local color_scheme="$2"    # dark, light, standard
    local size_variant="$3"    # standard, compact
    local tweaks="$4"          # rimless, float, etc.

    log_info "Configuring ReGreet with Colloid themes..."

    # Create ReGreet config directory
    sudo mkdir -p /etc/greetd

    # Determine theme names based on user selection
    local gtk_theme_name="Colloid-${color_scheme^}"
    local icon_theme_name="Colloid-${color_scheme}"

    # Handle special case for standard vs light/dark naming
    if [ "$color_scheme" = "standard" ]; then
        gtk_theme_name="Colloid-Dark"
        icon_theme_name="Colloid-dark"
    fi

    # Create ReGreet configuration with Colloid themes
    sudo tee /etc/greetd/regreet.toml > /dev/null << EOFREGREET
[GTK]
application_prefer_dark_theme = true
theme_name = "$gtk_theme_name"
icon_theme_name = "$icon_theme_name"
cursor_theme_name = "Bibata-Modern-Ice"
cursor_size = 24
font_name = ""

[commands]
reboot = [ "loginctl", "reboot" ]
poweroff = [ "loginctl", "poweroff" ]
EOFREGREET

    log_success "ReGreet configuration created"
    log_info "GTK theme: $gtk_theme_name"
    log_info "Icon theme: $icon_theme_name"
    log_info "Cursor theme: Bibata-Modern-Ice"
}

# Configure greetd to use ReGreet with Cage
configure_greetd_regreet() {
    log_info "Configuring greetd to use ReGreet with Cage..."

    sudo mkdir -p /etc/greetd

    # Create greetd config with ReGreet in Cage
    sudo tee /etc/greetd/config.toml > /dev/null << EOFGREETD
[terminal]
vt = 1

[default_session]
command = "env GTK_USE_PORTAL=0 GDK_DEBUG=no-portals cage -s -mlast -- regreet"
user = "greeter"
EOFGREETD

    log_success "greetd configuration created"
}

# Create Niri config for ReGreet session
create_regreet_niri_config() {
    log_info "Creating Niri configuration for ReGreet session..."

    sudo mkdir -p /etc/greetd

    # Create Niri KDL config for ReGreet
    sudo tee /etc/greetd/niri.kdl > /dev/null << EOFNIRI
spawn-at-startup "regreet; niri msg action quit --skip-confirmation"
hotkey-overlay {
    skip-at-startup
}
cursor {
    xcursor-theme "Bibata-Modern-Ice"
    xcursor-size 24
}
EOFNIRI

    log_success "ReGreet Niri configuration created"
}

# Create Wayland session file for ReGreet-enabled Niri
create_niri_regreet_session() {
    log_info "Creating Wayland session file for ReGreet..."

    sudo mkdir -p /usr/share/wayland-sessions

    # Create session file
    sudo tee /usr/share/wayland-sessions/niri-regreet.desktop > /dev/null << EOFSESSION
[Desktop Entry]
Name=Niri (ReGreet)
Comment=Niri with ReGreet display manager
Exec=niri --config /etc/greetd/niri.kdl
Type=Application
EOFSESSION

    log_success "ReGreet Wayland session created"
}

# Main ReGreet setup function
setup_regreet() {
    local repo_dir="$1"
    local theme_color="${2:-grey}"
    local color_scheme="${3:-dark}"
    local size_variant="${4:-standard}"
    local tweaks="${5:-rimless float}"

    log_step "Setting Up ReGreet Display Manager"

    log_info "This step requires sudo privileges to configure the display manager"
    echo ""

    install_regreet_packages "$repo_dir" || return 1
    disable_other_display_managers
    enable_greetd
    configure_greetd_regreet
    create_regreet_niri_config
    create_niri_regreet_session
    configure_regreet "$theme_color" "$color_scheme" "$size_variant" "$tweaks"

    echo ""
    log_success "ReGreet setup complete!"
    echo ""
    log_info "ReGreet configuration:"
    echo "  • Theme: Colloid-${color_scheme^} with tweaks: $tweaks"
    echo "  • Display Manager: greetd + Cage + ReGreet"
    echo "  • Session: Niri (ReGreet)"
    echo ""
    log_info "You can edit the ReGreet config at: /etc/greetd/regreet.toml"
    log_warn "You will need to reboot to use the new display manager"
    echo ""
}