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
- **Status Bar**: [ashell](https://github.com/MalpenZibo/ashell)
- **Application Launcher**: [fuzzel](https://codeberg.org/dnkl/fuzzel)
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)

|   Name   |            Description            |
| :------: | :-------------------------------: |
| `Cosmic Files` |      `Super + e` Filebroswer      |
| `Zen` |      `Super + b` Web Browser      |
| `Fuzzel` | `Super + d` Applications Launcher |
|  `awww`  |         Wallpaper setting         |

#### ZSH changes

|       Name       |                Description                |
| :--------------: | :---------------------------------------: |
|      `exa`       |             `ls` replacement              |
|      `bat`       |             `cat` replacement             |
|    `starship`    |              Terminal Prompt              |
| Extraction Tools | `ex filename` to extract compressed files |

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

#### Niri wants

```bash
systemctl --user add-wants niri.service \
    AB.service \
    ashell.service \
    awww-daemon.service \
    hypridle.service \
    hyprpolkitagent.service \
    syncthing.service \
    wlsunset.service \
    aqi-fetch.timer \
```
