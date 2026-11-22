# Ricer for NixOS

Original repository - https://github.com/ezequielgk/Ricer

A CLI script to apply color palettes to wallpapers using [lutgen](https://github.com/ozwaldorf/lutgen-rs).

This version also includes **Noctalia Ricer**, which creates complete [Noctalia](https://github.com/noctalia-dev/noctalia) palettes from wallpapers using [recol](https://github.com/nlkli/recol).

## Requirements

- **Nix** with `nix-shell` available.
- An internet connection on first use so Nix can download the runtime dependencies and Cargo can build `recol`.

The scripts declare their runtime dependencies in their `nix-shell` shebangs. You do not need to install `lutgen`, `fzf`, `chafa`, `ffmpeg`, `jq`, Python, Cargo, Rust, or the other command-line tools globally, and you do not need to copy a long `nix-shell -p ...` command.

`recol` is built automatically the first time either Noctalia script needs it. The binary is cached under:

```text
${XDG_DATA_HOME:-~/.local/share}/noctalia-ricer/recol/bin/recol
```

Later runs reuse that binary. The scripts start their own temporary Nix environments when launched.

## Installation

### 1. Download the repository

Clone the repository:

```bash
git clone https://github.com/bwoah-md/ricer.git
```

Navigate into the downloaded directory:

```bash
cd ricer
```

### 2. Run the installer

Make the installer executable and run it:

```bash
chmod +x install.sh
./install.sh
```

The installer copies the three executable scripts into `~/.local/bin`:

- `ricer`
- `noctalia-ricer`
- `wallpaper-to-noctalia`

Make sure `~/.local/bin` is included in your `PATH`. For Fish, add it with:

```fish
fish_add_path ~/.local/bin
```

### 3. Start using Ricer

Run any of the scripts directly:

```bash
ricer
```

```bash
noctalia-ricer
```

```bash
wallpaper-to-noctalia ~/Pictures/wallpaper.png
```

All required dependencies are provided through temporary Nix environments. No system-wide dependency installation is necessary.

### 4. Remove recol (Optional)

If you no longer need recol, remove its cached installation:

```bash
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/noctalia-ricer/recol"
```

**Disclaimer:** If you remove recol and want to use `noctalia-ricer` or `wallpaper-to-noctalia` again, the scripts will need to download and recompile recol on the next run. This may take some time depending on your internet connection and system.

## Ricer (Lutgen edition)

Run:

```bash
ricer
```

At startup, Ricer imports available Noctalia palettes and prepares the Lutgen palette registry. Its palette picker includes:

1. Noctalia custom palettes from `~/.config/noctalia/palettes/`.
2. Noctalia community palettes from `~/.local/state/noctalia/community-palettes/`.
3. Noctalia built-in palettes.
4. Lutgen's built-in palettes.

Choose a wallpaper folder, select a palette, and process the images. Processed files are saved separately so the originals remain unchanged.

## Noctalia Ricer (recol edition)

Generates complete Noctalia palettes (Material Design 3 colors and terminal colors) from wallpapers using [recol](https://github.com/nlkli/recol).

### Usage

```bash
noctalia-ricer                  # interactive fzf interface
wallpaper-to-noctalia IMAGE     # generate a palette directly
wallpaper-to-noctalia IMAGE NAME
wallpaper-to-noctalia --migrate [FILES...]
```

The interactive flow lets you select a folder or individual images, tune saturation, contrast, brightness, temperature, tint, vibrance, hue and normalization, preview the result, choose Dark / Light / Both, and save the palette in:

```text
~/.config/noctalia/palettes/
```

The generated JSON palettes are detected by Noctalia automatically; they are not added to `registry.json`.

### Live palette mode

Menu option **`5. Live palette`** can keep a palette synchronized with the current wallpaper:

1. It installs a `wallpaper_changed` hook in `~/.config/noctalia/config.toml`, pointing to `~/.config/noctalia/hooks/live-palette.sh`.
2. When the wallpaper changes, the hook regenerates the palette using the saved settings.
3. If the Live palette is active, the hook asks Noctalia to reload its configuration so the updated colors are applied.

The hook uses the installed `~/.local/bin/wallpaper-to-noctalia` helper. Keep that helper installed at the path shown in the Installation section. Live mode requires Noctalia v5+ and the `noctalia` IPC command to be available in the user's environment.

Choose **Regenerate & apply now** to activate the hook, **Tune settings** to adjust its parameters, or **Toggle** to disable it.

The default live palette is `Live.json`. It can be renamed from the menu. A stamp cache skips work when the wallpaper and settings have not changed.

**Save copy (freeze current)** snapshots the current live palette into a separate palette. The snapshot does not change when the Live palette is regenerated.

### Features

- Community palette format 2 (`"version": 2`, snake_case roles).
- Dark and light variants.
- Unified background: `surface` and `terminal.background` use the same color.
- Minimum luminance floor to avoid pitch-black backgrounds from very dark wallpapers.
- Stamp-based cache using the settings and image modification time.
- Parallel image processing (`MAX_JOBS=N`, default `4`).
- Palette management: edit, rename, and delete palettes from the interactive menu.
- Custom palette names retain Title Case, with an overwrite prompt when a name already exists.
- Settings are saved in `~/.config/noctalia-ricer.conf`.
- `wallpaper-to-noctalia --migrate [FILES...]` converts older format 1 palettes to format 2 in place.

### Notes

- Images with very few unique colors can cause `recol` to fail. The script retries using an FFmpeg JPEG re-encode and, when necessary, added noise.
- The first use of either Noctalia script may take longer because `recol` is compiled once. Subsequent runs use the cached executable.
