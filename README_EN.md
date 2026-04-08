<div align="right">

[![TR](https://img.shields.io/badge/🇹🇷-Türkçe-red)](README.md)
[![EN](https://img.shields.io/badge/🇬🇧-English-blue)](README_EN.md)
[![RU](https://img.shields.io/badge/🇷🇺-Русский-blue)](README_RU.md)

</div>

# 📡 Keenetic Aria2 Manager

<div align="center">

![Version](https://img.shields.io/github/v/release/SoulsTurk/keenetic-aria2-manager?label=version&color=brightgreen)
![Stars](https://img.shields.io/github/stars/SoulsTurk/keenetic-aria2-manager?style=flat&color=yellow)
![Shell](https://img.shields.io/badge/shell-ash%20%2F%20bash-blue)
![Platform](https://img.shields.io/badge/platform-Keenetic%20OS-orange)
![License](https://img.shields.io/badge/license-GPL--3.0-red)

**Full-featured aria2 download manager for Keenetic routers**

*Installation · Management · Telegram Notifications · Backup · Web UI*

![Main Menu](https://github.com/SoulsTurk/keenetic-aria2-manager/raw/main/screenshots/en_screenshots/ana-menu_en.jpg)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Screenshots](#-screenshots)
- [Menu Structure](#-menu-structure)
- [Telegram Notifications](#-telegram-notifications)
- [Backup System](#-backup-system)
- [FAQ](#-faq)
- [License](#-license)

---

## ✨ Features

| Feature | Description |
|---|---|
| 🚀 **Multi-connection downloads** | Parallel downloading with split/segment support |
| 🌐 **AriaNg Web UI** | Built-in web server — no separate installation needed |
| 📱 **Telegram Notifications** | Instant notifications for every download event |
| 💾 **Backup & Restore** | Basic and full backup, one-click restore |
| 🔧 **51 Config Settings** | All aria2 settings across 8 categories |
| 🖥️ **System Health** | CPU, RAM, disk and network monitoring |
| 🔍 **Diagnostics & Test** | Automatic issue detection and resolution |
| 🌍 **Dual Language** | Turkish / English full support |
| 📦 **USB Support** | Automatic USB disk detection |

---

## 📦 Requirements

> [!IMPORTANT]
> **This script works only with Entware installed on a USB drive.**
> All files are written to the `/opt` directory. Entware **must** be installed on a USB disk.
> The script will not work if `/opt` is missing or Entware is not installed.

- ✅ Keenetic OS
- ✅ **Entware — must be installed on a USB drive**
- ✅ `opkg` package manager
- ✅ `curl` *(for Telegram notifications — installed automatically)*

---

## ⚡ Installation

### Quick Install

```bash
opkg update && opkg install curl && \
mkdir -p /opt/lib/opkg && \
curl -fsSL https://raw.githubusercontent.com/SoulsTurk/keenetic-aria2-manager/main/keenetic-aria2-manager.sh \
  -o /opt/lib/opkg/keenetic-aria2-manager.sh && \
chmod +x /opt/lib/opkg/keenetic-aria2-manager.sh && \
sh /opt/lib/opkg/keenetic-aria2-manager.sh
```

On first run the script automatically:
- Generates a 24-character RPC Secret Key
- Configures the download directory if a USB disk is detected
- Creates shortcuts: `aria2m` · `a2m` · `k2m` · `kam` · `aria2manager`

---

## 📸 Screenshots

### Main Menu
![Main Menu](screenshots/en_screenshots/ana-menu_en.jpg)

> System status, aria2 info, AriaNg address and all features on one screen.

---

### Menu 1 — aria2 Management
![aria2 Management](screenshots/en_screenshots/menu_1_en.jpg)

> Start/stop service, installation, update, AriaNg Web UI and RPC management.

---

### Settings Menu (Option 4)
![Settings](screenshots/en_screenshots/aria2ayarlarmenu4_en.jpg)

> Download directory, connection, speed, RPC, log settings and **C) Full Config Wizard** with 51 settings.

---

### AriaNg Web UI
![AriaNg](screenshots/en_screenshots/ariang_en.jpg)

> Built-in AriaNg web interface — open `http://192.168.1.1:6880` in your browser.

---

### Telegram Notifications
![Telegram Settings](screenshots/en_screenshots/telegram_ayarlar_en.jpg)

> Bot Token and Chat ID setup, curl installation and notification management.

---

### Notification Settings
![Notification Settings](screenshots/en_screenshots/telegram_bildirim_ayarlari_en.jpg)

> Choose which events to be notified about — service, downloads, WebUI, backup and more.

---

### Backup & Restore
![Backups](screenshots/en_screenshots/yedekler_en.jpg)

> Create basic and full backups, list backups, restore and delete.

---

### System Health
![System Health](screenshots/en_screenshots/sistem_sagligi_en.jpg)

> CPU, RAM, storage, network, aria2 status and download speed in real-time.

---

### Diagnostics & Test
![Diagnostics](screenshots/en_screenshots/tani_ve_test_en.jpg)

> Requirements, optional components, update check and feature tests.

---

### aria2 Update
![Update](screenshots/en_screenshots/dahili_aria2c_guncelleme_en.jpg)

> Safely update the aria2c binary via opkg.

---

### Full Uninstall
![Uninstall](screenshots/en_screenshots/tam_kaldirma_en.jpg)

> Safe removal with the option to keep or delete your backups.

---

### Language Selection
![Language](screenshots/en_screenshots/dil_secimi_en.jpg)

> Switch between Turkish / English instantly.

---

### Help & FAQ
![FAQ](screenshots/en_screenshots/sss_en.jpg)

> Frequently asked questions, menu descriptions and user guide.

---

## 🗂️ Menu Structure

```
Main Menu
├── 1) aria2 Management
│   ├── START / STOP / RESTART Service
│   ├── 4) Settings
│   │   ├── Download directory
│   │   ├── Connection settings
│   │   ├── Speed limits
│   │   ├── RPC settings
│   │   ├── File allocation method
│   │   ├── Log settings
│   │   └── C) Full Config Wizard (51 settings, 8 categories)
│   ├── 5) INSTALL aria2c (opkg)
│   ├── 6) Auto Start ON/OFF
│   ├── 7) Update aria2c
│   └── 8) AriaNg Web UI
├── 2) Add Download (URL)
├── 3) Current Downloads
├── 4) Scan USB / Set Download Dir
├── 5) View Logs
├── 6) Telegram Notifications
│   ├── ENABLED/DISABLED toggle
│   ├── Bot Token & Chat ID
│   ├── Notification Settings (10 event types)
│   ├── Send Test Message
│   └── Install curl
├── S) System Health
├── H) Diagnostics & Test
├── M) Help & User Guide
├── B) Backup & Restore
│   ├── 1) Basic Backup
│   ├── 2) Full Backup
│   ├── 3) Restore from Backup
│   └── 4) Delete Backups
├── L) Language / Dil
├── U) Check for Updates
└── K) Uninstall Manager
```

---

## 📱 Telegram Notifications

You can receive instant Telegram notifications for the following events:

| Notification | Emoji | Default |
|---|---|---|
| aria2 service started | ✅ | ON |
| aria2 service stopped | ⏹ | ON |
| Download added | ➕ | OFF |
| Download completed | ✅ | OFF |
| Download error | ❌ | OFF |
| Download stopped | ⏸ | OFF |
| WebUI started | 🖥️ | ON |
| WebUI stopped | ⏹ | ON |
| RPC Secret Key changed | 🔑 | ON |
| Backup created/deleted/restored | 💾🗑♻️ | ON |

**Setup:**
1. Create a bot via [BotFather](https://t.me/botfather)
2. Copy your Bot Token
3. Use [@userinfobot](https://t.me/userinfobot) to get your Chat ID
4. Menu 6 → 2) Set Bot Token & Chat ID

---

## 💾 Backup System

### Basic Backup
`aria2.conf`, `telegram.conf`, language preference

### Full Backup
Basic backup + session file, init script, all Telegram hook scripts, AriaNg port config

### Backup Format
```
aria2manager_backup_YYYYMMDD_HHMM_basic.tar.gz
aria2manager_backup_YYYYMMDD_HHMM_full.tar.gz
```

Backups are saved to `/opt/etc/aria2/backups/`.

> **Note:** Backups are not deleted when uninstalling — you will be asked.

---

## ❓ FAQ

**Q: Can I configure settings without installing aria2c?**  
A: Yes, Menu 1 → Settings → C) Config Wizard works without aria2c installed. Your settings are preserved after installation.

**Q: Do I need to download anything separately for AriaNg WebUI?**  
A: No. The manager hosts AriaNg internally. Menu 1 → 8) AriaNg Web UI → Install and Start is all you need.

**Q: Is curl required for Telegram notifications?**  
A: Yes. The manager installs curl automatically when Telegram is enabled. For manual installation use Menu 6 → 5) Install curl.

**Q: How do I update the script?**  
A: Main Menu → U) Check for Updates → confirm the update.

**Q: I want to reset all settings.**  
A: Menu 1 → Settings → 8) Reset config to defaults. Or use B) Restore from Backup.

---

## 🧑‍💻 Contributing

Pull requests and issues are welcome.

```
github.com/SoulsTurk/keenetic-aria2-manager
```

---

## ⚠️ Disclaimer

> [!WARNING]
> **Please read the following before using this script.**

This script performs **system-level configurations** on your Keenetic router:

- Starts and stops the `aria2c` background service
- Creates and deletes config, hook and init files under `/opt/etc/`
- **Opens the RPC API over the network** — default port `6800`, accessible from all interfaces
- **Serves the AriaNg WebUI over the network** — default port `6880`, accessible from the local network
- Manages `iptables` rules and the lighttpd web server
- Reads and writes files on the USB disk

### 🔐 Security Warnings

| Risk | Description | Mitigation |
|---|---|---|
| **RPC port exposed** | Port 6800 is reachable from the LAN | Set a strong RPC Secret Key |
| **WebUI port exposed** | Port 6880 is reachable from the LAN | Do not use on untrusted networks |
| **Secret Key** | A weak or empty key creates a security vulnerability | The script auto-generates a 24-char key — do not clear it |
| **Telegram Token** | Bot token and Chat ID are sensitive credentials | Never share them; protect the config file |
| **Downloaded files** | The script does not verify the content of downloaded URLs | Only download from trusted sources |

### ⚖️ Terms of Use

- This script is provided **as-is**, **without any warranty**
- Misconfiguration may cause connectivity loss or system issues
- **Use is entirely at the user's own risk**
- The developer cannot be held liable for any direct or indirect damages arising from the use of this script
- It is recommended to **take a backup** before making changes to your router (B) Backup & Restore)

---

## 📄 License

GPL-3.0 License — you may use and distribute it, but if you modify it you must share it as open source under the same license.

---

## 🙏 Acknowledgements & Inspiration

The development of this project was inspired by [RevolutionTR](https://github.com/RevolutionTR)'s **[keenetic-zapret-manager](https://github.com/RevolutionTR/keenetic-zapret-manager)** project.

The overall script architecture, feature set and menu structure were referenced during design. Thank you for the effort and the open source contribution. 🤝

---

<div align="center">

**Keenetic Aria2 Manager** · v1.0.1 · by [SoulsTurk](https://github.com/SoulsTurk)

</div>
