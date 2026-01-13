#!/usr/bin/env bash
# Dotfiles deployment functions for Niri-only bd-configs installer

# Source utils for logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Create symlink (removing existing files/symlinks first)
create_symlink() {
    local source="$1"
    local target="$2"

    # Create parent directory if it doesn't exist
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"

    # Remove existing file/symlink if present
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
    fi

    # Create symlink
    ln -sf "$source" "$target"
}

# Deploy shared configurations
deploy_shared_configs() {
    local repo_dir="$1"
    local user_home=$(get_user_home)
    local config_dir="$user_home/.config"

    log_info "Deploying shared configurations..."

    local shared_configs=(
        "kitty"
        "gtk-3.0"
        "gtk-4.0"
        "fastfetch"
    )

    for config in "${shared_configs[@]}"; do
        if [ -d "$repo_dir/configs/shared/$config" ]; then
            log_info "Linking $config..."
            create_symlink "$repo_dir/configs/shared/$config" "$config_dir/$config"
        fi
    done

    # Handle Qt configs separately to process $HOME variable
    for qt_config in "qt5ct" "qt6ct"; do
        if [ -d "$repo_dir/configs/shared/$qt_config" ]; then
            log_info "Processing $qt_config config with path expansion..."
            mkdir -p "$config_dir/$qt_config"
            if [ -f "$repo_dir/configs/shared/$qt_config/${qt_config}.conf" ]; then
                sed "s|\$HOME|$user_home|g" "$repo_dir/configs/shared/$qt_config/${qt_config}.conf" > "$config_dir/$qt_config/${qt_config}.conf"
            fi
            # Copy other files if they exist
            find "$repo_dir/configs/shared/$qt_config" -type f ! -name "${qt_config}.conf" -exec cp {} "$config_dir/$qt_config/" \; 2>/dev/null || true
        fi
    done

    log_success "Shared configurations deployed"
}

# Deploy Niri configurations only (no DMS)
deploy_niri_configs() {
    local repo_dir="$1"
    local user_home=$(get_user_home)
    local config_dir="$user_home/.config"

    log_info "Deploying Niri configurations..."

    # Link niri directory
    if [ -d "$repo_dir/configs/niri/niri" ]; then
        log_info "Linking Niri configs..."
        create_symlink "$repo_dir/configs/niri/niri" "$config_dir/niri"
    fi

    log_success "Niri configurations deployed"
}

# Main deployment function
deploy_configurations() {
    local repo_dir="$1"
    # Note: No compositor selection parameter needed - always Niri

    log_step "Deploying Configurations"

    # Always deploy shared configs (remove fish since removed)
    deploy_shared_configs "$repo_dir"

    # Deploy Niri configs (always - Niri-only installer)
    deploy_niri_configs "$repo_dir"

    log_success "All configurations deployed successfully"
}