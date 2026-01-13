# V's Niri Desktop Config

A clean, minimal desktop environment configuration for Arch Linux featuring **Niri** compositor with **Colloid themes** and **ReGreet** display manager.

## Features

- **Niri Compositor**: Modern scrollable-tiling Wayland compositor
- **Colloid Themes**: Consistent, modern theming across all applications
- **ReGreet Display Manager**: Elegant GTK-based greeter with Wayland support
- **Automated Setup**: Interactive installer with theme customization
- **Symlinked Configs**: Easy configuration management - edit once, apply everywhere

## Directory Structure

```
bd-configs/
├── install.sh              # Main installer script
├── lib/                    # Installation libraries
│   ├── utils.sh           # Utility functions
│   ├── checks.sh          # System validation
│   ├── packages.sh        # Package management
│   ├── dotfiles.sh        # Configuration deployment
│   ├── themes.sh          # Colloid theme automation
│   └── greeter.sh         # ReGreet setup
├── packages/              # Package definitions
└── configs/               # Configuration files
    ├── niri/              # Niri-specific configs
    └── shared/            # Shared application configs
```

## What's Included

**Desktop Environment:**
- Niri compositor with Wayland support
- ReGreet display manager with Cage integration
- Colloid GTK and Icon themes with dark mode
- Bibata Modern Ice cursor theme

**Applications:**
- Kitty terminal
- Nemo file manager
- Fastfetch system information
- Optional: Zen Browser, Zed editor, Helix editor

**Customization:**
- Interactive Colloid theme selection
- Dark mode with rimless borders
- Floating panel style
- System-wide theme application

## Requirements

- Arch Linux or Arch-based distribution
- AUR helper (paru or yay)
- Internet connection for package installation

## Installation

```bash
git clone https://gitlab.com/theblackdon/bd-configs.git
cd bd-configs
./install.sh
```

The installer will guide you through:
1. **System validation** - Checks for required dependencies
2. **Theme selection** - Choose your Colloid theme variant and colors
3. **Optional apps** - Select additional applications
4. **Package installation** - Install all required packages
5. **Configuration setup** - Deploy configs via symlinks
6. **Theme application** - Apply selected themes system-wide
7. **Display manager** - Configure ReGreet with your chosen theme
8. **Completion** - Reboot to enjoy your new desktop

## Configuration

All configurations are symlinked from the repository, making customization easy:

```bash
cd bd-configs

# Edit Niri config
nano configs/niri/niri/config.kdl

# Edit terminal config
nano configs/shared/kitty/kitty.conf

# Edit GTK theme settings
nano configs/shared/gtk/settings.ini
```

Changes take effect immediately or after reloading Niri with `Super+Shift+R`.

## Key Bindings

- `Super + Return` - Open terminal (kitty)
- `Super + Space` - Application launcher (fuzzel)
- `Super + Q` - Close focused window
- `Super + F` - Open file manager (nemo)
- `Super + Shift + R` - Reload Niri configuration
- `Super + Arrow keys` - Navigate windows and workspaces

## Troubleshooting

**ReGreet doesn't start:**
```bash
sudo systemctl status greetd
sudo systemctl restart greetd
```

**Themes not applying:**
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Grey-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Grey-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
```

**Niri won't start:**
```bash
niri --verbose
journalctl --user -xe
```

## Credits

This configuration is based on [BD-Configs](https://gitlab.com/theblackdon/bd-configs) by TheBlackDon, which provided an excellent foundation for creating this streamlined Niri-only setup. The original project's multi-compositor approach inspired this focused implementation.

---

Made with ❤️ for a clean, minimal desktop experience
