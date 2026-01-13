#!/usr/bin/env bash
# Colloid theme installation and configuration functions for bd-configs installer

# Source utils for logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Theme selection variables (defaults based on user preferences)
SELECTED_THEME_VARIANT="grey"
SELECTED_COLOR_SCHEME="dark"
SELECTED_SIZE_VARIANT="standard"
SELECTED_TWEAKS="rimless float"

# Theme variant options
THEME_VARIANTS=(
    "default" "Default Blue"
    "grey" "Grey (Recommended)"
    "purple" "Purple"
    "pink" "Pink"
    "red" "Red"
    "orange" "Orange"
    "yellow" "Yellow"
    "green" "Green"
    "teal" "Teal"
)

# Color scheme options
COLOR_SCHEMES=(
    "dark" "Dark Mode (Recommended)"
    "light" "Light Mode"
    "standard" "Standard"
    "all" "Install All"
)

# Size variant options
SIZE_VARIANTS=(
    "standard" "Standard"
    "compact" "Compact"
)

# Tweaks options
TWEAKS=(
    "nord" "Nord Color Scheme"
    "dracula" "Dracula Color Scheme"
    "gruvbox" "Gruvbox Color Scheme"
    "everforest" "Everforest Color Scheme"
    "catppuccin" "Catppuccin Color Scheme"
    "rimless" "Remove Window Borders"
    "normal" "Standard Window Buttons"
    "float" "Floating Panel Style"
    "black" "Blackness Color Version"
)

# Interactive theme selection menu
select_colloid_theme_options() {
    while true; do
        clear
        print_separator
        echo -e "${CYAN}           COLLOID THEME CONFIGURATION${NC}"
        print_separator
        echo ""
        
        # Theme variant selection
        echo -e "${YELLOW}1) Theme Color Variant:${NC}"
        local current_theme="Not Set"
        for i in "${!THEME_VARIANTS[@]}"; do
            if [ "$((i % 2))" -eq 0 ]; then
                local key="${THEME_VARIANTS[$i]}"
                local desc="${THEME_VARIANTS[$((i + 1))]}"
                if [ "$SELECTED_THEME_VARIANT" = "$key" ]; then
                    echo -e "    ${GREEN}[${desc}]${NC}"
                    current_theme="$desc"
                else
                    echo -e "    [${desc}]"
                fi
            fi
        done
        echo ""
        
        # Color scheme selection
        echo -e "${YELLOW}2) Color Scheme:${NC}"
        local current_color="Not Set"
        for i in "${!COLOR_SCHEMES[@]}"; do
            if [ "$((i % 2))" -eq 0 ]; then
                local key="${COLOR_SCHEMES[$i]}"
                local desc="${COLOR_SCHEMES[$((i + 1))]}"
                if [ "$SELECTED_COLOR_SCHEME" = "$key" ]; then
                    echo -e "    ${GREEN}[${desc}]${NC}"
                    current_color="$desc"
                else
                    echo -e "    [${desc}]"
                fi
            fi
        done
        echo ""
        
        # Size variant selection
        echo -e "${YELLOW}3) Size Variant:${NC}"
        local current_size="Not Set"
        for i in "${!SIZE_VARIANTS[@]}"; do
            if [ "$((i % 2))" -eq 0 ]; then
                local key="${SIZE_VARIANTS[$i]}"
                local desc="${SIZE_VARIANTS[$((i + 1))]}"
                if [ "$SELECTED_SIZE_VARIANT" = "$key" ]; then
                    echo -e "    ${GREEN}[${desc}]${NC}"
                    current_size="$desc"
                else
                    echo -e "    [${desc}]"
                fi
            fi
        done
        echo ""
        
        # Tweaks selection
        echo -e "${YELLOW}4) Theme Tweaks:${NC}"
        local active_tweaks=""
        for i in "${!TWEAKS[@]}"; do
            if [ "$((i % 2))" -eq 0 ]; then
                local key="${TWEAKS[$i]}"
                local desc="${TWEAKS[$((i + 1))]}"
                if [[ "$SELECTED_TWEAKS" == *"$key"* ]]; then
                    echo -e "    ${GREEN}☑${NC} [${desc}]"
                    if [ -n "$active_tweaks" ]; then
                        active_tweaks="$active_tweaks, ${desc}"
                    else
                        active_tweaks="${desc}"
                    fi
                else
                    echo -e "    ☐ [${desc}]"
                fi
            fi
        done
        if [ -z "$active_tweaks" ]; then
            echo "    (None selected)"
        else
            log_info "Active: $active_tweaks"
        fi
        echo ""
        
        echo -e "${YELLOW}Current Selection:${NC} $current_theme, $current_color, $current_size"
        echo -e "${YELLOW}r)${NC} Reset to defaults (grey, dark, standard, rimless float)"
        echo -e "${YELLOW}c)${NC} Continue with current selection"
        echo -e "${YELLOW}q)${NC} Quit installer"
        print_separator
        echo ""
        
        read -p "Enter your choice (1-4, r, c, q): " choice
        
        case $choice in
            1) select_theme_variant ;;
            2) select_color_scheme ;;
            3) select_size_variant ;;
            4) toggle_tweak ;;
            r) reset_to_defaults ;;
            c) return 0 ;;
            q) exit 0 ;;
            *) log_warn "Invalid choice. Please try again." ;;
        esac
    done
}

# Select theme variant
select_theme_variant() {
    echo ""
    log_info "Available theme variants:"
    for i in "${!THEME_VARIANTS[@]}"; do
        if [ "$((i % 2))" -eq 0 ]; then
            local key="${THEME_VARIANTS[$i]}"
            local desc="${THEME_VARIANTS[$((i + 1))]}"
            echo "  $((i/2 + 1)). $desc"
        fi
    done
    echo ""
    
    read -p "Select theme variant (1-$((${#THEME_VARIANTS[@]}/2)): " choice
    
    local max_choice=$((${#THEME_VARIANTS[@]}/2)
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_choice" ]; then
        local index=$(((choice - 1) * 2))
        SELECTED_THEME_VARIANT="${THEME_VARIANTS[$index]}"
        log_success "Theme variant set to: ${THEME_VARIANTS[$((index + 1))]}"
    else
        log_warn "Invalid choice. Keeping current selection."
    fi
}

# Select color scheme
select_color_scheme() {
    echo ""
    log_info "Available color schemes:"
    for i in "${!COLOR_SCHEMES[@]}"; do
        if [ "$((i % 2))" -eq 0 ]; then
            local key="${COLOR_SCHEMES[$i]}"
            local desc="${COLOR_SCHEMES[$((i + 1))]}"
            echo "  $((i/2 + 1)). $desc"
        fi
    done
    echo ""
    
    read -p "Select color scheme (1-$((${#COLOR_SCHEMES[@]}/2)): " choice
    
    local max_choice=$((${#COLOR_SCHEMES[@]}/2)
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_choice" ]; then
        local index=$(((choice - 1) * 2))
        SELECTED_COLOR_SCHEME="${COLOR_SCHEMES[$index]}"
        log_success "Color scheme set to: ${COLOR_SCHEMES[$((index + 1))]}"
    else
        log_warn "Invalid choice. Keeping current selection."
    fi
}

# Select size variant
select_size_variant() {
    echo ""
    log_info "Available size variants:"
    for i in "${!SIZE_VARIANTS[@]}"; do
        if [ "$((i % 2))" -eq 0 ]; then
            local key="${SIZE_VARIANTS[$i]}"
            local desc="${SIZE_VARIANTS[$((i + 1))]}"
            echo "  $((i/2 + 1)). $desc"
        fi
    done
    echo ""
    
    read -p "Select size variant (1-$((${#SIZE_VARIANTS[@]}/2)): " choice
    
    local max_choice=$((${#SIZE_VARIANTS[@]}/2)
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max_choice" ]; then
        local index=$(((choice - 1) * 2))
        SELECTED_SIZE_VARIANT="${SIZE_VARIANTS[$index]}"
        log_success "Size variant set to: ${SIZE_VARIANTS[$((index + 1))]}"
    else
        log_warn "Invalid choice. Keeping current selection."
    fi
}

# Toggle theme tweaks
toggle_tweak() {
    echo ""
    log_info "Available tweaks (current selection: $SELECTED_TWEAKS):"
    for i in "${!TWEAKS[@]}"; do
        if [ "$((i % 2))" -eq 0 ]; then
            local key="${TWEAKS[$i]}"
            local desc="${TWEAKS[$((i + 1))]}"
            local index=$((i/2 + 1))
            echo "  $index. $desc"
        fi
    done
    echo ""
    
    read -p "Select tweak to toggle (1-$((${#TWEAKS[@]}/2), 0 to finish): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le $((${#TWEAKS[@]}/2) ]; then
        if [ "$choice" -eq 0 ]; then
            log_info "Finished toggling tweaks."
            return
        fi
        
        local index=$(((choice - 1) * 2))
        local key="${TWEAKS[$index]}"
        
        if [[ "$SELECTED_TWEAKS" == *"$key"* ]]; then
            # Remove the tweak
            SELECTED_TWEAKS="${SELECTED_TWEAKS//$key/}"
            SELECTED_TWEAKS="${SELECTED_TWEAKS%% }"
            SELECTED_TWEAKS="${SELECTED_TWEAKS%% }"
            log_success "Removed tweak: ${TWEAKS[$((index + 1))]}"
        else
            # Add the tweak
            if [ -n "$SELECTED_TWEAKS" ]; then
                SELECTED_TWEAKS="$SELECTED_TWEAKS $key"
            else
                SELECTED_TWEAKS="$key"
            fi
            log_success "Added tweak: ${TWEAKS[$((index + 1))]}"
        fi
    else
        log_warn "Invalid choice."
    fi
}

# Reset to defaults
reset_to_defaults() {
    SELECTED_THEME_VARIANT="grey"
    SELECTED_COLOR_SCHEME="dark"
    SELECTED_SIZE_VARIANT="standard"
    SELECTED_TWEAKS="rimless float"
    log_success "Reset to defaults: Grey, Dark, Standard, Rimless + Float"
}

# Clone and install Colloid themes
install_colloid_themes() {
    local repo_dir="$1"
    log_step "Installing Colloid Themes"

    # Create temp directory for theme installation
    local temp_dir="/tmp/colloid-theme-install"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"

    log_info "Cloning Colloid GTK theme..."
    git clone https://github.com/vinceliuice/Colloid-gtk-theme.git "$temp_dir/colloid-gtk-theme" || {
        log_error "Failed to clone Colloid GTK theme repository"
        return 1
    }

    log_info "Cloning Colloid icon theme..."
    git clone https://github.com/vinceliuice/Colloid-icon-theme.git "$temp_dir/colloid-icon-theme" || {
        log_error "Failed to clone Colloid icon theme repository"
        return 1
    }

    # Install GTK theme with user selections
    cd "$temp_dir/colloid-gtk-theme"
    local install_cmd="./install.sh"
    
    # Build installation command
    [ "$SELECTED_THEME_VARIANT" != "default" ] && install_cmd="$install_cmd -t $SELECTED_THEME_VARIANT"
    [ "$SELECTED_COLOR_SCHEME" != "all" ] && install_cmd="$install_cmd -c $SELECTED_COLOR_SCHEME"
    [ "$SELECTED_SIZE_VARIANT" != "standard" ] && install_cmd="$install_cmd -s $SELECTED_SIZE_VARIANT"
    [ -n "$SELECTED_TWEAKS" ] && install_cmd="$install_cmd --tweaks $SELECTED_TWEAKS"
    
    # Install libadwaita for GTK4 apps
    install_cmd="$install_cmd -l"

    log_info "Installing Colloid GTK theme: $install_cmd"
    if [ -n "$SELECTED_TWEAKS" ] && [[ "$SELECTED_TWEAKS" == *"catppuccin"* ]]; then
        log_info "Theme selections: $SELECTED_THEME_VARIANT, $SELECTED_COLOR_SCHEME, $SELECTED_SIZE_VARIANT, tweaks: $SELECTED_TWEAKS"
    else
        log_info "Theme selections: $SELECTED_THEME_VARIANT, $SELECTED_COLOR_SCHEME, $SELECTED_SIZE_VARIANT, tweaks: $SELECTED_TWEAKS"
    fi
    
    eval "$install_cmd" || {
        log_error "Failed to install Colloid GTK theme"
        cd "$repo_dir"
        return 1
    }

    # Install icon theme
    cd "$temp_dir/colloid-icon-theme"
    log_info "Installing Colloid icon theme..."
    ./install.sh || {
        log_error "Failed to install Colloid icon theme"
        cd "$repo_dir"
        return 1
    }

    # Cleanup
    cd "$repo_dir"
    rm -rf "$temp_dir"

    log_success "Colloid themes installed successfully"
    return 0
}

# Apply system themes with Colloid settings
apply_colloid_themes() {
    local theme_color="$1"
    local color_scheme="$2" 
    local tweaks="$3"

    log_step "Applying Colloid Themes System-wide"

    # Determine theme name for gsettings
    local gtk_theme_name="Colloid-${color_scheme^}"
    if [ "$color_scheme" = "standard" ]; then
        gtk_theme_name="Colloid-Dark"
    elif [ "$color_scheme" = "dark" ]; then
        gtk_theme_name="Colloid-Dark"
    elif [ "$color_scheme" = "light" ]; then
        gtk_theme_name="Colloid-Light"
    fi

    # Apply GTK theme settings
    log_info "Applying GTK theme settings..."
    apply_gsettings() {
        local user=$(detect_user)
        local user_id=$(id -u "$user")
        
        if [ "$EUID" -eq 0 ]; then
            sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$user_id/bus" gsettings "$@" 2>/dev/null || true
        else
            gsettings "$@" 2>/dev/null || true
        fi
    }
    
    apply_gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme_name"
    apply_gsettings set org.gnome.desktop.interface icon-theme "Colloid-${color_scheme}"
    apply_gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice"
    apply_gsettings set org.gnome.desktop.interface font-name "Inter Variable 10"
    apply_gsettings set org.gnome.desktop.interface cursor-size 24
    
    log_success "GTK theme settings applied"

    # Create GTK2 configuration
    create_gtk2_config() {
        local user_home=$(get_user_home)
        local gtkrc="$user_home/.gtkrc-2.0"
        
        log_info "Creating GTK2 configuration..."
        
        cat > "$gtkrc" << 'EOFGTK2'
gtk-theme-name="$gtk_theme_name"
gtk-icon-theme-name="Colloid-'$color_scheme'"
gtk-font-name="Inter Variable 10"
gtk-cursor-theme-name="Bibata-Modern-Ice"
gtk-cursor-theme-size=24
EOFGTK2
        
        # Fix ownership if running as root
        if [ "$EUID" -eq 0 ]; then
            local user=$(detect_user)
            chown "$user:$user" "$gtkrc"
        fi
        
        log_success "GTK2 configuration created"
    }

    create_gtk2_config

    # Set default cursor theme
    set_cursor_theme() {
        local user_home=$(get_user_home)
        local icons_dir="$user_home/.icons/default"
        
        log_info "Setting default cursor theme..."
        
        mkdir -p "$icons_dir"
        
        cat > "$icons_dir/index.theme" << 'EOFCURSOR'
[Icon Theme]
Inherits=Bibata-Modern-Ice
EOFCURSOR
        
        # Fix ownership if running as root
        if [ "$EUID" -eq 0 ]; then
            local user=$(detect_user)
            chown -R "$user:$user" "$user_home/.icons"
        fi
        
        log_success "Default cursor theme set"
    }

    set_cursor_theme

    # Create Xresources for cursor
    create_xresources() {
        local user_home=$(get_user_home)
        local xresources="$user_home/.Xresources"
        
        log_info "Creating Xresources for cursor..."
        
        cat > "$xresources" << 'EOFXRES'
Xcursor.theme: Bibata-Modern-Ice
Xcursor.size: 24
EOFXRES
        
        # Fix ownership if running as root
        if [ "$EUID" -eq 0 ]; then
            local user=$(detect_user)
            chown "$user:$user" "$xresources"
        fi
        
        log_success "Xresources created"
    }

    create_xresources

    log_success "Colloid themes applied successfully"
    echo ""
    log_info "Theme changes will take full effect after logging out and back in"
    echo ""
    log_info "Applied theme: $gtk_theme_name with tweaks: $tweaks"
}

# Main theme application function
apply_themes() {
    local repo_dir="$1"
    local theme_color="${2:-grey}"
    local color_scheme="${3:-dark}"
    local size_variant="${4:-standard}"
    local tweaks="${5:-rimless float}"

    log_step "Applying Themes"
    
    # Install Colloid themes first
    install_colloid_themes "$repo_dir" || return 1
    
    # Apply system-wide theme settings
    apply_colloid_themes "$theme_color" "$color_scheme" "$tweaks"
}

# Display current theme selection summary
display_theme_selection_summary() {
    echo ""
    print_separator
    echo -e "${CYAN}           THEME SELECTION SUMMARY${NC}"
    print_separator
    echo ""
    echo -e "${YELLOW}Theme Variant:${NC} $SELECTED_THEME_VARIANT"
    echo -e "${YELLOW}Color Scheme:${NC} $SELECTED_COLOR_SCHEME"
    echo -e "${YELLOW}Size Variant:${NC} $SELECTED_SIZE_VARIANT"
    echo -e "${YELLOW}Active Tweaks:${NC} $SELECTED_TWEAKS"
    echo ""
    print_separator
    echo ""
    
    if prompt_yes_no "Continue with these theme selections?" "y"; then
        return 0
    else
        return 1
    fi
}

# Get current theme selections as command string (for logging/display)
get_theme_command_string() {
    local cmd="./install.sh"
    [ "$SELECTED_THEME_VARIANT" != "default" ] && cmd="$cmd -t $SELECTED_THEME_VARIANT"
    [ "$SELECTED_COLOR_SCHEME" != "all" ] && cmd="$cmd -c $SELECTED_COLOR_SCHEME"
    [ "$SELECTED_SIZE_VARIANT" != "standard" ] && cmd="$cmd -s $SELECTED_SIZE_VARIANT"
    [ -n "$SELECTED_TWEAKS" ] && cmd="$cmd --tweaks $SELECTED_TWEAKS"
    cmd="$cmd -l"
    echo "$cmd"
}