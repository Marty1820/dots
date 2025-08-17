<div align="center">

# Marty's Dots

![GitHub last commit](https://img.shields.io/github/last-commit/Marty1820/configs?style=for-the-badge&labelColor=44475a&color=bd93f9) ![GitHub repo size](https://img.shields.io/github/repo-size/Marty1820/configs?style=for-the-badge&labelColor=44475a&color=bd93f9)

</div>

**Warning:** Works on my machine doesn't mean it'll work on yours. Use at your own risk.
Lots of older configs in another repo [here](https://github.com/Marty1820/old-dotfiles)

## Screenshot

![niri fetch](/.screenshots/niri.png?raw=true "Niri Screenshot")

## Details

- **Shell**: [ZSH](https://www.zsh.org/)
- **WM**: [Niri](https://github.com/YaLTeR/niri)
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar)
- **Application Launcher**: [fuzzel](https://codeberg.org/dnkl/fuzzel)
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)

|    Name    |        Description         |
| :--------: | :------------------------: |
|  `NeoVim`  |        `Super + a`         |
|  `Thunar`  |        `Super + e`         |
| `WaterFox` |        `Super + b`         |
|  `Fuzzel`  | `Super + d` = applications |

#### ZSH changes

|        Name         |                Description                |
| :-----------------: | :---------------------------------------: |
|        `exa`        |             `ls` replacement              |
|        `bat`        |             `cat` replacement             |
|     `starship`      |              Terminal Prompt              |
| Decompression Tools | `ex filename` to extract compressed files |

## Installation instructions

### Prerequisites

Install [GNU stow](https://www.gnu.org/software/stow/):

```bash
sudo apt install stow   # Debian/Ubuntu
sudo pacman -S stow     # Arch
```

Clone Repo

```bash
git clone https://github.com/Marty1820/configs.git ~/dots
cd ~/dots
```

Stow the files

```bash
stow .
```

#### Bootstrap

```bash
git clone https://github.com/Marty1820/configs.git ~/dots && cd ~/dots && stow .
```

No overwriting files:

```bash
git clone https://github.com/Marty1820/configs.git ~/dots && cd ~/dots && stow --adopt .
```

#### Extra file needed for wlsunset and weather module in Waybar

```bash
nvim ~/.local/state/location.toml
```

Example contents:

```toml
API_KEY = "OPEN_WEATHER_API_KEY"
LAT = "LATITUDE"
LON = "LONGITUDE"
```

#### Niri wants

```bash
systemctl --user add-wants niri.service AB.service swaybg.service swayidle.service waybar.service wlsunset.service weather.timer
```
