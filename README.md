# Debola

A custom Debian Trixie live ISO with Openbox desktop. Boot it, use it.

Built on Debian Trixie with [live-build](https://live-team.pages.debian.net/live-manual/). No GNOME, no tasksel, no bloat. A fast, keyboard-driven Openbox desktop with everything you actually need.

## What's in the Box

- **Debian Trixie** (amd64) with full `main contrib non-free non-free-firmware` repos
- **Openbox** window manager with lxpanel, thunar, alacritty
- **~180 hand-picked packages** -- no metapackages, no pulls, no surprises
- **Intel GPU firmware** and X driver out of the box
- **WiFi** (iwlwifi, realtek, atheros, brcm) and **Bluetooth** (bluez) support
- **Live user**: `debola` / `debola` with full NOPASSWD sudo
- **Auto-login** to a working desktop -- boot and go
- BIOS (syslinux) and UEFI (GRUB) boot support
- ISO-hybrid image -- dd to USB and boot
- **External repos** pre-configured for Firefox and Sublime Text
- **Handy aliases** -- `install packagename`, `remove packagename`, `search term`, and more

## Installing to Disk

This is a **live ISO only**. To set up Debola on a permanent system:

1. Install Debian Trixie normally (net-install or standard DVD)
2. After install, clone the [debola](https://github.com/rabmach/debola) repo
3. Run the restore scripts to apply all Debola configs:

```bash
git clone https://github.com/rabmach/debola.git
cd debola
chmod +x restore.sh
sudo ./restore.sh

--OR--

sudo ./tasks/01-repos.sh    # Add repos (Mozilla, Sublime Text)
sudo ./tasks/02-packages.sh # Install packages
sudo ./tasks/03-icons.sh    # Install icon themes
sudo ./tasks/04-config.sh   # Apply configs and dotfiles
sudo ./tasks/05-tweaks.sh   # System tweaks and settings
sudo ./tasks/06-finish.sh   # Final touches
```

The restore scripts handle everything: packages, configs, icons, wallpapers, aliases, and all the Openbox customizations.

## Building the ISO

### Prerequisites

A Debian-based host (amd64) with `sudo` access. The build script installs dependencies automatically, but for reference:

```
dctrl-tools live-build debootstrap isolinux loadlin
grub-efi-amd64-bin grub-efi-ia32-bin librsvg2-bin
appstream syslinux-common xorriso mtools
```

### Required: The Debola Assets Repo

This build pulls configs, scripts, themes, and dotfiles from the [debola](https://github.com/rabmach/debola) repo. By default, it expects `debola/` as a sibling directory:

```
parent/
  debola/      <- assets repo (configs, scripts, themes, wallpapers)
  debolaD/     <- this repo (build system)
```

Or set the path with `--assets`:

```bash
sudo ./build.sh --assets /path/to/debola
```

### Build

```bash
cd debolaD
sudo ./build.sh --clean
```

The `--clean` flag wipes previous build artifacts. Without it, live-build resumes from cached stages.

Build time varies with your hardware and network. Expect 10-40 minutes on a decent connection.

### Output

The finished ISO is written to `output/`:

```
output/debola-live-trixie-YYYYMMDD.iso
```

Write it to a USB stick:

```bash
sudo dd if=output/debola-live-trixie-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress
sync
```

### Booting

1. Boot from the USB
2. Select **Debola Live** from the boot menu
3. You're in. User: `debola`, Password: `debola`

## Handy Aliases

The live user comes with pre-configured aliases from `.bash_aliases`. No `sudo` required:

| Command | What it does |
|---------|-------------|
| `install packagename` | `sudo aptitude -y install` |
| `remove packagename` | `sudo aptitude purge` |
| `search term` | `aptitude search` |
| `apps` | Launch Synaptic package manager |
| `cpf` | Clean, purge, and fix broken packages |

See [MadCarter's](https://madcarters.com/config.html) for more handy aliases and keybinds, etc.
Or just fire-up the terminal with win+t and type: aliases and geany will open to the file.

## Project Structure

```
debolaD/
├── build.sh                  # Main build script
├── README.md
├── .gitignore
├── branding/                 # GRUB wallpaper source
├── config/
│   ├── package-lists/
│   │   └── debola.list.chroot
│   ├── bootloaders/
│   │   ├── grub-pc/          # UEFI boot theme
│   │   └── syslinux/         # BIOS boot splash
│   ├── hooks/
│   │   └── live/             # Build hooks (repos, user, desktop, config, icons)
│   └── includes.chroot/
│       └── usr/lib/live/config/  # Runtime hooks (skel copy, ownership, polkit, password)
└── output/                   # Built ISOs
```

## Workarounds

This build works around several known live-build issues:

- **Stages run individually** (`lb bootstrap`, `lb chroot`, `lb binary`) instead of `lb build`
- **Bootstrap cache is created manually** with `rsync -ax` because debootstrap leaves `/sys` mounted inside the chroot
- **Runtime hooks** copy skel to the live user's home, fix ownership, drive mounting permissions, printer access, and live user password at boot

## Customization

Edit `config/package-lists/debola.list.chroot` to add or remove packages. Edit the debola assets repo for configs, scripts, and themes.

## License

Debian is free software. So is this.
