#!/bin/sh

# ============================================
# KEENETIC ARIA2 MANAGER
# Geliştirici: SoulsTurk
# GitHub: https://github.com/SoulsTurk/keenetic-aria2-manager
# ============================================

# --- CRLF Otomatik Düzeltme / Auto CRLF Fix ---
# GitHub'dan Windows satır sonu (CRLF \r\n) ile indirilirse kendini düzeltir.
_CR=$(printf '\r')
if grep -qF "$_CR" "$0" 2>/dev/null; then
 sed -i "s/${_CR}//g" "$0" 2>/dev/null
 exec sh "$0" "$@"
fi

export PATH="/sbin:/usr/sbin:/bin:/usr/bin:/opt/sbin:/opt/bin:$PATH"

# --- Sürüm / Version ---
SCRIPT_VERSION="v1.0.1"
UPDATE_URL="https://raw.githubusercontent.com/SoulsTurk/keenetic-aria2-manager/main/keenetic-aria2-manager.sh"

# --- Renkler / Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
DIM_CYAN='\033[2;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# --- Yollar / Paths ---
SCRIPT_PATH="/opt/lib/opkg/keenetic-aria2-manager.sh"
CONF_DIR="/opt/etc/aria2"
ARIA2_CONF="$CONF_DIR/aria2.conf"
ARIA2_SESSION="$CONF_DIR/aria2.session"
ARIA2_LOG="/opt/var/log/aria2.log"
PID_FILE="/opt/var/run/aria2c.pid"
INIT_FILE="/opt/etc/init.d/S99aria2"
LOCK_FILE="/tmp/keenetic-aria2-manager.lock"
LANG_FILE="$CONF_DIR/lang"
TG_CONF="$CONF_DIR/telegram.conf"
TG_HOOK_MAIN="$CONF_DIR/tg_notify.sh"
BACKUP_DIR="$CONF_DIR/backups"
TG_HOOK_COMPLETE="$CONF_DIR/tg_on_complete.sh"
TG_HOOK_ERROR="$CONF_DIR/tg_on_error.sh"
TG_HOOK_START_DL="$CONF_DIR/tg_on_dl_start.sh"
TG_HOOK_STOP_DL="$CONF_DIR/tg_on_dl_stop.sh"

# --- Varsayılan Config / Default Config ---
DEFAULT_DIR="/tmp/mnt/USB"
DEFAULT_MAX_CONCURRENT=3
DEFAULT_MAX_CONNECTION=10
DEFAULT_SPLIT=10
DEFAULT_MIN_SPLIT="20M"
DEFAULT_RPC_PORT=6800
DEFAULT_RPC_SECRET=""
DEFAULT_DL_LIMIT=0
DEFAULT_UL_LIMIT=0
DEFAULT_FILE_ALLOC="none"
DEFAULT_DISK_CACHE="64M"
DEFAULT_LOG_LEVEL="notice"

# --- Dizinleri Hazırla / Prepare Dirs ---
[ -d "$CONF_DIR" ] || mkdir -p "$CONF_DIR"
[ -d "/opt/var/log" ] || mkdir -p "/opt/var/log"
[ -d "/opt/var/run" ] || mkdir -p "/opt/var/run"
[ -f "$ARIA2_SESSION" ] || touch "$ARIA2_SESSION"

# ============================================
# DİL SİSTEMİ / LANGUAGE SYSTEM
# ============================================
LANG_SEL="tr"
[ -f "$LANG_FILE" ] && LANG_SEL=$(cat "$LANG_FILE" 2>/dev/null)
[ "$LANG_SEL" != "tr" ] && [ "$LANG_SEL" != "en" ] && [ "$LANG_SEL" != "ru" ] && LANG_SEL="tr"

load_lang() {
 if [ "$LANG_SEL" = "en" ]; then
 L_INSTALLED="INSTALLED"; L_NOT_INSTALLED="NOT INSTALLED"
 L_RUNNING="RUNNING"; L_STOPPED="INACTIVE"
 L_ACTIVE="ACTIVE"; L_INACTIVE="INACTIVE"
 L_DL_DIR="DL dir"; L_AUTO_START="Auto start"
 L_SERVICE="Service"; L_ARIA2C="aria2c"
 L_NOT_SET="[NOT SET]"; L_RPC="RPC"
 L_PORT="port"; L_INSTALL_HINT="(Menu 1 -> Install)"
 L_MAIN_MENU="MAIN MENU"; L_YOUR_CHOICE="Your choice"
 L_BACK_MAIN="Back to Main Menu"; L_EXIT="Exit"
 L_ARIA2_MGMT="aria2 Management"; L_ARIA2_MGMT_SUB="(service, settings, install)"
 L_ADD_DL="Add Download"; L_ADD_DL_SUB="(URL)"
 L_DOWNLOADS="Current Downloads"; L_SCAN_USB="Scan USB / Set Download Dir"
 L_VIEW_LOGS="View Logs"; L_CHECK_UPDATE="Check for Updates"
 L_UNINSTALL_MGR="Uninstall Manager"; L_LANG_MENU="Language / Dil"
 L_ARIA2_MGMT_TITLE="aria2 MANAGEMENT"
 L_START_SVC="START Service"; L_STOP_SVC="STOP Service"
 L_RESTART_SVC="RESTART Service"; L_SETTINGS="Settings"
 L_INSTALL_ARIA2="INSTALL aria2c (opkg)"; L_AUTO_TOGGLE="Auto Start ON/OFF"
 L_AUTO_SHORT="Auto start"
 L_SVC_NOT_INSTALLED="aria2 not installed. Use option 5 to install aria2c."
 L_SVC_CONF_MISSING="Config file not found. Creating default config..."
 L_SVC_ALREADY_RUNNING="aria2 is already running."
 L_SVC_STARTING="Starting aria2..."; L_SVC_STARTED="aria2 started."
 L_SVC_START_FAIL="aria2 could not be started!"
 L_SVC_LOG_HINT="Log:";
 L_SVC_STARTING_PROC="aria2c starting..."
 L_SVC_WAITING="seconds waiting..."
 L_SVC_LOG_TAIL="--- Last log lines ---"
 L_SVC_LOG_NOT_FOUND="Log file not found:"
 L_SVC_CONF_MISSING_TXT="Config file missing!"
 L_SVC_BINARY_NOT_FOUND="NOT FOUND"
 L_SVC_STOPPING="Stopping aria2..."
 L_SVC_STOPPED_OK="aria2 stopped."; L_SVC_STOP_FAIL="Could not stop. Force killing..."
 L_SVC_FORCE_KILLED="Force killed."; L_SVC_NOT_RUNNING="aria2 is not running."
 L_SVC_RESTARTING="Restarting..."; L_SVC_RESTART_OK="Service restarted."
 L_SVC_RESTART_FAIL="Service could not auto-restart. Use Menu 1 -> START."
 L_INSTALL_TITLE="ARIA2 INSTALLATION"
 L_ALREADY_INSTALLED="aria2c is already installed."
 L_PKG_UPDATING="Updating package list..."; L_PKG_INSTALLING="Installing aria2..."
 L_INSTALL_OK="aria2 installed successfully!"; L_INSTALL_FAIL="Installation failed! Check internet and opkg settings."
 L_POST_INSTALL_TITLE="POST-INSTALL AUTO SETUP"
 L_POST_INSTALL_MSG="Running post-install auto configuration..."
 L_CREATING_CONF="Creating default config file..."
 L_SCANNING_USB="Scanning USB devices..."
 L_USB_DETECTED="USB device(s) detected:"
 L_USB_FREE="Free"; L_USB_TOTAL="Total"
 L_USB_USE_Q="Use '%s' as download directory? [Y/N]: "
 L_USB_MANUAL="Enter directory manually: "
 L_USB_SELECT="Which directory? (number, default 1): "
 L_DL_DIR_SET="Download directory:"; L_SETUP_DONE="Basic setup complete!"
 L_HINT_SETTINGS="Detailed settings: Menu 1 -> Settings"
 L_HINT_START="Start service: Menu 1 -> START Service"
 L_CONF_CREATED="Config file created:"
 L_USB_TITLE="USB DEVICE SCAN"; L_USB_SEARCHING="Searching for connected devices..."
 L_USB_NONE="No USB device found."; L_USB_CHECK="Make sure your USB drive is plugged in."
 L_USB_DETECTED2="Detected devices:"; L_USB_USED="Used"
 L_USB_SELECT_NUM="Select number to set as download dir (0 = cancel): "
 L_USB_DIR_SET="Download directory set to:"; L_USB_RESTART_Q="Restart service? [Y/N]: "
 L_USB_RESTARTING="Restarting..."; L_USB_RESTARTED="Service restarted."
 L_INVALID="Invalid selection."
 L_ADD_DL_TITLE="ADD DOWNLOAD"; L_ARIA2_NOT_RUNNING="aria2 not running. Use Menu 1 -> START."
 L_URL_PROMPT="Download URL: "; L_DIR_PROMPT="Save directory (blank = default '%s'): "
 L_DL_QUEUED="Download queued!"; L_DL_GID="GID"; L_DL_FAIL="Download could not be added."
 L_SERVER_RESP="Server response:"; L_RPC_HINT="Check RPC settings and port."
 L_DL_LIST_TITLE="DOWNLOAD LIST"; L_ACTIVE_DL="ACTIVE DOWNLOADS:"
 L_WAITING_DL="WAITING DOWNLOADS:"; L_COMPLETED_DL="RECENTLY COMPLETED:"
 L_NO_ACTIVE="(No active downloads)"; L_NO_WAITING="(No waiting downloads)"
 L_NO_COMPLETED="(No completed downloads)"; L_PRESS_ENTER="Press Enter to continue..."
 L_SETTINGS_TITLE="SETTINGS MENU"; L_SET_DL_DIR="Download directory"
 L_SET_CONCURRENT="Concurrent downloads"; L_SET_MAX_CONN="Max connections/server"
 L_SET_SPLIT="Split count"; L_SET_DL_SPEED="DL speed limit"; L_SET_UL_SPEED="UL speed limit"
 L_SET_UNLIMITED="0=unlimited"; L_SET_RPC="RPC"; L_SET_RPC_SECRET="RPC password"
 L_RPC_SECRET_LABEL="RPC Secret Key"
 L_SET_ALLOC="File allocation"; L_SET_LOG_LEVEL="Log level"
 L_SET_CHANGE_DIR="Change download directory"; L_SET_CONN="Connection settings"
 L_SET_SPEED="Speed limit settings"; L_SET_RPC_MENU="RPC settings"
 L_SET_ALLOC_MENU="File allocation method"; L_SET_LOG_MENU="Log settings"
 L_SET_SHOW_CONF="Show full config file"; L_SET_RESET_CONF="Reset config to defaults"
 L_SET_BACK="Back to main menu"; L_SET_CONFIGURED="CONFIGURED"; L_SET_EMPTY="[EMPTY]"
 L_CONN_TITLE="CONNECTION SETTINGS"; L_CONN_HINT="Leave blank to keep current value."
 L_CONN_CONCURRENT="Max concurrent downloads"; L_CONN_MAXCONN="Max connections/server (1-16)"
 L_CONN_SPLIT="Splits per file"; L_CONN_MINSPLIT="Min split size (e.g. 20M)"
 L_CONN_CACHE="Disk cache (e.g. 64M)"; L_CONN_UPDATED="Connection settings updated."
 L_SPEED_TITLE="SPEED LIMIT SETTINGS"; L_SPEED_HINT="0 = Unlimited"
 L_SPEED_EXAMPLE="Example: 1M = 1 MB/s | 512K = 512 KB/s"
 L_SPEED_DL="Download speed limit"; L_SPEED_UL="Upload speed limit"
 L_SPEED_UPDATED="Speed limits updated."
 L_RPC_TITLE="RPC SETTINGS"; L_RPC_HINT2="RPC enables AriaNg, webui-aria2, etc."
 L_RPC_ENABLE="RPC enabled? (true/false)"; L_RPC_PORT2="RPC port"
 L_RPC_SECRET2="RPC password (blank = none)"; L_RPC_ALL="Allow all interfaces (true/false)"
 L_RPC_ORIGIN="Allow all origins (true/false)"; L_RPC_UPDATED="RPC settings updated."
 L_ALLOC_TITLE="FILE ALLOCATION METHOD"
 L_ALLOC_NONE="No allocation (fastest start)"
 L_ALLOC_PREALLOC="Pre-allocate (FAT32 recommended)"
 L_ALLOC_FALLOC="Fast allocate (ext4/NTFS recommended)"
 L_ALLOC_TRUNC="Truncate method"; L_ALLOC_CURRENT="Current"
 L_ALLOC_PROMPT="Your choice [1-4, blank to skip]: "; L_ALLOC_NOCHANGE="No changes made."
 L_LOG_TITLE="LOG SETTINGS"; L_LOG_PATH="Log file path"; L_LOG_LEVEL2="Log level"
 L_LOG_LEVELS="1) debug 2) info 3) notice 4) warn 5) error"
 L_LOG_UPDATED="Log settings updated."
 L_CONF_FILE="CONFIG FILE"; L_CONF_NOT_FOUND="Config file not found."
 L_CONF_RESET_Q="Reset config? All settings will be lost! [Y/N]: "
 L_CURRENT="current"; L_BLANK_SKIP="blank to skip"; L_CHOICE_PROMPT="Your choice"
 L_CONF_HEADER="Keenetic Aria2 Manager - Configuration"
 L_UPDATE_TITLE="UPDATE CHECK"; L_UPDATE_CONNECTING="Connecting to GitHub..."
 L_UPDATE_FAIL="Could not reach update server."; L_UPDATE_CHECK_URL="Checked URL:"
 L_UPDATE_NO_VER="Version info not found in downloaded file."
 L_UPDATE_CURR="Current version"; L_UPDATE_REMOTE="GitHub version"
 L_UPDATE_AVAIL="New version available!"; L_UPDATE_Q="Update now? [Y/N]: "
 L_UPDATE_IN_PROGRESS="Updating..."; L_UPDATE_STOPPING="Stopping service..."
 L_UPDATE_DONE="File updated:"; L_UPDATE_RESTARTING="Restarting service..."
 L_UPDATE_RESTART_OK="Service restarted."
 L_UPDATE_RESTART_FAIL="Could not auto-restart. Use Menu 1 -> START."
 L_UPDATE_LATEST="Already on latest version"; L_UPDATE_CANCEL="Update cancelled."
 # === HEADER EXTRA ===
 L_HDR_SYSTEM="System"
 L_HDR_UPTIME="Uptime"
 L_HDR_DISK_FREE="Disk Free"
 L_HDR_ACTIVE_DL="Active DL"
 L_HDR_ACTIVE_DL_SVC_DOWN="Service stopped"
 L_HDR_ACTIVE_DL_NONE="No downloads"
 L_HDR_TELEGRAM="Telegram"
 L_HDR_GITHUB="GitHub"
 L_HDR_RAM="RAM Free"
 L_HDR_WAN_IP="WAN IP"
 L_HDR_OS_VER="KeeneticOS"
 L_HDR_LOAD="CPU Load"
 L_HDR_DL_SPEED="DL Speed"
 L_HDR_ABOUT="ABOUT"
 L_HDR_FEATURES="FEATURES"
 # === HEALTH MENU ===
 L_HEALTH_MENU="System Health"
 L_HEALTH_TITLE="SYSTEM HEALTH CHECK"
 L_HEALTH_SEC_CPU="CPU & LOAD"
 L_HEALTH_SEC_RAM="MEMORY"
 L_HEALTH_SEC_DISK="STORAGE"
 L_HEALTH_SEC_NET="NETWORK"
 L_HEALTH_SEC_PROC="PROCESSES"
 L_HEALTH_SEC_ARIA2="ARIA2"
 L_HEALTH_CPU_USAGE="CPU Usage"
 L_HEALTH_LOAD_1="Load 1m"
 L_HEALTH_LOAD_5="Load 5m"
 L_HEALTH_LOAD_15="Load 15m"
 L_HEALTH_TEMP="Temperature"
 L_HEALTH_RAM_USED="RAM Used"
 L_HEALTH_RAM_FREE="RAM Free"
 L_HEALTH_RAM_TOTAL="RAM Total"
 L_HEALTH_RAM_BUFCACHE="Buf/Cache"
 L_HEALTH_SWAP_USED="Swap Used"
 L_HEALTH_SWAP_TOTAL="Swap Total"
 L_HEALTH_WAN_IP="WAN IP"
 L_HEALTH_LAN_IP="LAN IP"
 L_HEALTH_DNS_PING="DNS Ping"
 L_HEALTH_GW_PING="Gateway Ping"
 L_HEALTH_RX="RX Total"
 L_HEALTH_TX="TX Total"
 L_HEALTH_CONN="Active Conns"
 L_HEALTH_PROC_COUNT="Processes"
 L_HEALTH_ARIA2_PID="aria2 PID"
 L_HEALTH_ARIA2_RSS="aria2 RAM"
 L_HEALTH_ARIA2_ACTIVE="Active DL"
 L_HEALTH_ARIA2_WAITING="Waiting DL"
 L_HEALTH_ARIA2_STOPPED="Recent DL"
 L_HEALTH_ARIA2_SPEED="DL Speed"
 L_HEALTH_ARIA2_UPSPEED="UL Speed"
 L_HEALTH_ARIA2_SESSIONS="Session File"
 L_HEALTH_REFRESHING="Refreshing..."
 L_HEALTH_AUTO_REF="Auto-refresh (5s) — press any key to stop"
 L_HEALTH_PRESS_R=" R) Refresh A) Auto-refresh 0) Back"
 L_HEALTH_OK="OK"
 L_HEALTH_WARN="WARN"
 L_HEALTH_CRIT="CRIT"
 L_HEALTH_NA="N/A"
 L_HEALTH_MS="ms"
 L_HEALTH_TIMEOUT="timeout"
 L_HDR_DESC1="aria2 download manager for Keenetic routers"
 L_HDR_DESC2="Add downloads via RPC | AriaNg WebUI | Speed limits"
 L_HDR_DESC3="Telegram notifications | Auto-start | USB disk management"
 L_HDR_FEAT1="Multi-connection downloads with split/segment support"
 L_HDR_FEAT2="AriaNg WebUI — manage downloads from any browser"
 L_HDR_FEAT3="Telegram notifications for every download event"
 L_HDR_FEAT4="USB disk auto-detect & download directory setup"
 # === DIAG MENU ===
 L_DIAG_MENU="Diagnostics & Test"
 L_HELP_MENU="Help & User Guide"
 L_DIAG_TITLE="DIAGNOSTICS & REQUIREMENTS"
 L_DIAG_SEC_CORE="── CORE REQUIREMENTS ──"
 L_DIAG_SEC_OPT="── OPTIONAL COMPONENTS ──"
 L_DIAG_SEC_UPDATE="── UPDATE CHECK ──"
 L_DIAG_SEC_FUNC="── FEATURE TESTS ──"
 L_DIAG_OK="OK"
 L_DIAG_FAIL="MISSING"
 L_DIAG_WARN="WARN"
 L_DIAG_RUNNING="RUNNING"
 L_DIAG_STOPPED="INACTIVE"
 L_DIAG_ACTIVE="ACTIVE"
 L_DIAG_INACTIVE="INACTIVE"
 L_DIAG_OPTIONAL="optional"
 L_DIAG_NOT_INSTALLED="Not installed"
 L_DIAG_INSTALLED="Installed"
 L_DIAG_CONF_OK="Config OK"
 L_DIAG_CONF_MISS="Config MISSING"
 L_DIAG_SESSION_OK="Session file OK"
 L_DIAG_SESSION_MISS="Session file missing"
 L_DIAG_LOGDIR_OK="Log dir OK"
 L_DIAG_LOGDIR_MISS="Log dir missing"
 L_DIAG_RPC_OK="RPC responding"
 L_DIAG_RPC_FAIL="RPC not responding"
 L_DIAG_RPC_DISABLED="RPC disabled in config"
 L_DIAG_DL_DIR_OK="Download dir exists"
 L_DIAG_DL_DIR_MISS="Download dir MISSING"
 L_DIAG_DL_DIR_NOTSET="Download dir not set"
 L_DIAG_AUTOSTART_ON="Autostart enabled"
 L_DIAG_AUTOSTART_OFF="Autostart disabled"
 L_DIAG_TG_ENABLED="Telegram ENABLED"
 L_DIAG_TG_DISABLED="Telegram disabled"
 L_DIAG_TG_NO_TOKEN="Token not set!"
 L_DIAG_TG_NO_CHAT="Chat ID not set!"
 L_DIAG_CURL_OK="curl installed"
 L_DIAG_CURL_MISS="curl MISSING — needed for RPC/Telegram/Update"
 L_DIAG_OPKG_OK="opkg available"
 L_DIAG_OPKG_MISS="opkg not found"
 L_DIAG_ENTWARE_OK="Entware /opt OK"
 L_DIAG_ENTWARE_MISS="Entware /opt MISSING"
 L_DIAG_ARIANG_RUNNING="AriaNg running"
 L_DIAG_ARIANG_STOPPED="AriaNg stopped"
 L_DIAG_ARIANG_NOT_INST="Not installed"
 L_DIAG_LIGHTTPD_OK="lighttpd installed"
 L_DIAG_LIGHTTPD_MISS="lighttpd not installed"
 L_DIAG_UPDATE_MGR="Manager script"
 L_DIAG_UPDATE_ARIA2="aria2c binary"
 L_DIAG_UPDATE_CHECKING="Checking..."
 L_DIAG_UPDATE_LATEST="Up to date"
 L_DIAG_UPDATE_AVAIL="Update available"
 L_DIAG_UPDATE_FAIL="Could not check"
 L_DIAG_SUMMARY="SUMMARY"
 L_DIAG_ALL_OK="All core requirements satisfied."
 L_DIAG_ISSUES="Issues found:"
 L_DIAG_PRESS_R=" R) Refresh F) Fix issues 0) Back"
 L_DIAG_FIX_TITLE="FIX / INSTALL MISSING"
 L_DIAG_FIX_ARIA2="Install aria2c"
 L_DIAG_FIX_CONF="Create default config"
 L_DIAG_FIX_SESSION="Create session file"
 L_DIAG_FIX_LOGDIR="Create log directory"
 L_DIAG_FIX_DLDIR="Set download directory"
 L_DIAG_FIX_CURL="Install curl"
 L_DIAG_FIX_AUTOSTART="Enable autostart"
 L_DIAG_FIX_NOTHING="Nothing to fix — all OK!"
 L_DIAG_FIX_DONE="Fix completed."
 # diag label strings
 L_DIAG_LBL_LOGDIR="Log directory"
 L_DIAG_LBL_DLDIR="Download directory"
 L_DIAG_LBL_SERVICE="aria2c service"
 L_DIAG_LBL_AUTOSTART="Autostart"
 L_DIAG_LBL_USB="USB disk"
 L_DIAG_LBL_RPC_TEST="RPC func test"
 L_DIAG_LBL_INTERNET="Internet"
 L_DIAG_LBL_TGHOOKS="Telegram hooks"
 L_DIAG_D_OPTBIN="/opt/bin present"
 L_DIAG_D_OPTNO="exists but opkg missing"
 L_DIAG_D_RPCSVCDOWN="enabled (service down)"
 L_DIAG_D_FREE="Free"
 L_DIAG_D_DISKS="disk(s) connected"
 L_DIAG_D_NODISK="No USB disk found"
 L_DIAG_D_ACTIVE="Active"
 L_DIAG_D_WAITING="Waiting"
 L_DIAG_D_NORPC="getGlobalStat no response"
 L_DIAG_D_SVCRPC="Service down or RPC disabled"
 L_DIAG_D_GITHUB="github.com reachable"
 L_DIAG_D_CFONE="1.1.1.1 reachable"
 L_DIAG_D_NOINET="No connection / GitHub unreachable"
 L_DIAG_D_HOOKSOK="tg_notify.sh + on_complete + on_error"
 L_DIAG_D_HOOKSMISS="Some hook files missing (auto-created on service start)"
 L_DIAG_D_GHVER="Version unreadable from GitHub"
 L_DIAG_D_LOCAL="Local"
 L_DIAG_D_NEW="New"
 L_DIAG_D_NOSERVER="Server unreachable"
 L_DIAG_D_INSTALLED="Installed"
 L_DIAG_D_AVAILPKG="Available"
 L_DIAG_D_OPKGFAIL="Could not get info from opkg"
 L_DIAG_D_MENU1="Menu 1 → Install"
 L_DIAG_D_FIXDIR="Enter download dir manually: "
 L_UNINSTALL_TITLE="MANAGER UNINSTALL"; L_UNINSTALL_INFO="This will:"
 L_UNINSTALL_1="Stop the running aria2 service"
 L_UNINSTALL_2="Remove init.d autostart file"
 L_UNINSTALL_3="Remove shortcuts (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)"
 L_UNINSTALL_4="Remove this manager script"
 L_UNINSTALL_KEEP="Config files and downloads are NOT touched!"
 L_UNINSTALL_CONFIRM="Type YES to continue (blank to cancel): "
 L_UNINSTALL_STOPPING="Stopping service..."; L_UNINSTALL_DONE="Manager removed."
 L_UNINSTALL_CONF_KEPT="Config files remain at:"; L_UNINSTALL_CANCEL="Operation cancelled."
 L_UNINSTALL_CONFIRM_WORD="YES"
 L_AUTO_INSTALLED="Autostart already set up. Remove it? [Y/N]: "
 L_AUTO_REMOVED="Autostart removed."; L_AUTO_INSTALLED_OK="Autostart installed:"
 L_LOCK_MSG="Script appears already running (lock file exists)."
 L_LOCK_PID="Previous session PID:"; L_LOCK_PID_DEAD="(process not running)"
 L_LOCK_Q="Start new session? [Y/N]: "; L_LOCK_CLEARED="Lock cleared, starting new session..."
 L_LOCK_EXIT="Exiting."
 L_LANG_TITLE="LANGUAGE / DİL"; L_LANG_CURRENT="Current language:"
 L_LANG_SELECT="Select language:"; L_LANG_TR="Türkçe"; L_LANG_EN="English"; L_LANG_RU="Русский"
 L_LANG_CHANGED="Language changed."; L_LANG_BACK="Back"
 L_CONFIRM_YES="Y"; L_CONFIRM_YES2="y"
 # === TELEGRAM ===
 L_TG_MENU="Telegram Notifications"
 L_TG_TITLE="TELEGRAM NOTIFICATIONS"
 L_TG_STATUS="Status"; L_TG_ENABLED_STATUS="ENABLED"; L_TG_DISABLED_STATUS="DISABLED"
 L_TG_TOKEN="Bot Token"; L_TG_CHAT="Chat ID"; L_TG_NOT_SET="[NOT SET]"
 L_TG_NOTIFICATIONS="Active Notifications"
 L_TG_OPT_TOKEN="Set Bot Token"; L_TG_OPT_CHAT="Set Chat ID"
 L_TG_OPT_TOGGLE="Enable / Disable Telegram"; L_TG_OPT_NOTIFY="Notification Settings"
        L_TG_ABOUT_TITLE="ABOUT"
        L_TG_ABOUT_DESC="Telegram notifications automatically send a message on every download event."
        L_TG_ABOUT_CURL="curl is required for notifications to work."
        L_TG_ABOUT_AUTO="Telegram service installs curl automatically on first run."
        L_TG_ABOUT_MANUAL="To install manually, use option 5 from this menu."
 L_TG_OPT_TEST="Send Test Message"; L_TG_OPT_BACK="Back to Main Menu"
 L_TG_TOKEN_PROMPT="Enter Bot Token (blank to cancel): "
 L_TG_TOKEN_SAVED="Bot Token saved."
 L_TG_CHAT_PROMPT="Enter Chat ID (blank to cancel): "
 L_TG_CHAT_SAVED="Chat ID saved."
 L_TG_TOGGLED_ON="Telegram notifications ENABLED."
 L_TG_TOGGLED_OFF="Telegram notifications DISABLED."
 L_TG_NEED_TOKEN="Bot Token and Chat ID must be set first!"
 L_TG_TEST_SENDING="Sending test message..."
 L_TG_TEST_OK="Test message sent successfully!"
 L_TG_TEST_FAIL="Failed to send. Check Token and Chat ID."
 L_TG_NOTIFY_TITLE="NOTIFICATION SETTINGS"
 L_TG_N_SVC_START="Service started"; L_TG_N_SVC_STOP="Service stopped"
 L_TG_N_DL_ADD="Download added"; L_TG_N_DL_COMPLETE="Download completed"
 L_TG_N_DL_ERROR="Download error"; L_TG_N_DL_STOP="Download stopped/cancelled"
 L_TG_N_ON="ON"; L_TG_N_OFF="OFF"; L_TG_N_SAVED="Notification preferences saved."
 L_TG_MSG_SVC_START="✅ aria2 service started"
 L_TG_MSG_SVC_STOP="⏹ aria2 service stopped"
 L_TG_MSG_DL_ADD="➕ Download added"
 L_TG_MSG_DL_COMPLETE="✅ Download completed"
 L_TG_MSG_DL_ERROR="❌ Download error"
 L_TG_MSG_DL_STOP="⏸ Download stopped"
 L_TG_MSG_TEST="🔔 Keenetic Aria2 Manager - Test notification"
 L_TG_MSG_SECRET_KEY="🔑 RPC Secret Key updated"
 L_TG_N_WEBUI_START="WebUI started"; L_TG_N_WEBUI_STOP="WebUI stopped"
 L_TG_N_SECRET_KEY="RPC Secret Key changed"
 L_TG_N_BACKUP_CREATED="Backup created"
 L_TG_N_BACKUP_DELETED="Backup deleted"
 L_TG_N_BACKUP_RESTORED="Backup restored"
 L_TG_MSG_BACKUP_CREATED="💾 Backup created"
 L_TG_MSG_BACKUP_DELETED="🗑 Backup deleted"
 L_TG_MSG_BACKUP_RESTORED="♻️ Backup restored"
 L_TG_MSG_WEBUI_START="🖥️ AriaNg WebUI started"
 L_TG_MSG_WEBUI_STOP="⏹ AriaNg WebUI stopped"
 L_TG_CURL_LABEL="Required component"
 L_TG_CURL_OK="INSTALLED"
 L_TG_CURL_MISSING="MISSING"
 L_TG_CURL_INSTALL_Q="curl is required for Telegram notifications. Install now? [Y/N]: "
 L_TG_OPT_CURL="Install curl"
 # === HEADER NEW ===
 L_SELECTED_DISK="Selected Disk"; L_DL_LOCATION="Download Location"
 L_DISK_NOT_SET="[NOT SET]"
 # === FOLDER SELECTION ===
 L_FOLDER_DEFAULT_INFO="Default: /aria2/downloads folder will be created on the disk."
 L_FOLDER_CHANGE_Q="Change the folder? [Y/N]: "
 L_FOLDER_PROMPT="Enter subfolder name (e.g. downloads, media): "
 L_FOLDER_CUSTOM_SET="Custom folder set:"
 L_FOLDER_DEFAULT_SET="Default folder set:"
 # === FULL UNINSTALL ===
 L_FULL_UNINSTALL_TITLE="FULL UNINSTALL"
 L_FULL_UNINSTALL_INFO="This will completely remove:"
 L_FULL_UNINSTALL_1="aria2 service (stopped + removed via opkg)"
 L_FULL_UNINSTALL_2="All config files and logs"
 L_FULL_UNINSTALL_3="Autostart file (init.d)"
 L_FULL_UNINSTALL_4="Shortcuts (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)"
 L_FULL_UNINSTALL_5="This manager script"
 L_FULL_UNINSTALL_6="AriaNg WebUI (files + lighttpd config + autostart)"
 L_FULL_UNINSTALL_DL_Q="Your download folder:"
 L_FULL_UNINSTALL_DL_DEL="Delete downloaded files too? [Y/N]: "
 L_FULL_UNINSTALL_DL_KEEP="Downloaded files will be kept."
 L_FULL_UNINSTALL_DL_DELETING="Deleting downloads..."
 L_FULL_UNINSTALL_DL_DELETED="Downloads deleted."
 L_FULL_UNINSTALL_CONFIRM="Type REMOVE to confirm full uninstall: "
 L_FULL_UNINSTALL_CONFIRM_WORD="REMOVE"
 L_FULL_UNINSTALL_STOPPING="Stopping aria2 service..."
 L_FULL_UNINSTALL_REMOVING_PKG="Removing aria2 package via opkg..."
 L_FULL_UNINSTALL_PKG_DONE="aria2 package removed."
 L_FULL_UNINSTALL_PKG_FAIL="opkg remove failed (may already be uninstalled)."
 L_FULL_UNINSTALL_CONF="Removing config files and logs..."
 L_FULL_UNINSTALL_DONE="Full uninstall complete. System is clean."
 L_FULL_UNINSTALL_CANCEL="Uninstall cancelled."
 L_FULL_UNINSTALL_ARIANG="Removing AriaNg WebUI..."
 L_FULL_UNINSTALL_ARIANG_STOP="Stopping AriaNg (lighttpd)..."
 L_FULL_UNINSTALL_ARIANG_HTML="Removing AriaNg HTML files:"
 L_FULL_UNINSTALL_ARIANG_CONF="Removing lighttpd config:"
 L_FULL_UNINSTALL_ARIANG_INIT="Removing AriaNg autostart:"
 L_FULL_UNINSTALL_ARIANG_PKG="Removing lighttpd package via opkg..."
 L_FULL_UNINSTALL_ARIANG_DONE="AriaNg removed."
 L_FULL_UNINSTALL_ARIANG_SKIP="AriaNg not installed, skipping."
 L_FULL_UNINSTALL_RESIDUAL="Removing residual files and directories..."
 L_FULL_UNINSTALL_RESIDUAL_DONE="Residual files cleaned."
 # === ARIA2 ONLY REMOVE ===
 L_ARIA2_ONLY_TITLE="REMOVE ARIA2 (INDEPENDENT)"
 L_ARIA2_ONLY_INFO="This will completely remove aria2 and its files:"
 L_ARIA2_ONLY_1="aria2 service (stopped + removed via opkg)"
 L_ARIA2_ONLY_2="All aria2 config files, logs and session"
 L_ARIA2_ONLY_3="Autostart file (init.d)"
 L_ARIA2_ONLY_4="AriaNg WebUI (if installed)"
 L_ARIA2_ONLY_5="All residual aria2 files and opkg info"
 L_ARIA2_ONLY_KEEP="Manager script and shortcuts are NOT removed."
 L_ARIA2_ONLY_DL_Q="Your download folder:"
 L_ARIA2_ONLY_DL_DEL="Delete downloaded files too? [Y/N]: "
 L_ARIA2_ONLY_DL_KEEP="Downloaded files will be kept."
 L_ARIA2_ONLY_DL_DELETING="Deleting downloads..."
 L_ARIA2_ONLY_DL_DELETED="Downloads deleted."
 L_ARIA2_ONLY_CONFIRM="Type REMOVE to confirm aria2 removal: "
 L_ARIA2_ONLY_CONFIRM_WORD="REMOVE"
 L_ARIA2_ONLY_CANCEL="Removal cancelled."
 L_ARIA2_ONLY_DONE="aria2 and all its files removed. Manager is still active."
 # === ARIA2 UPDATE ===
 L_ARIA2_UPDATE="Update aria2c"
 L_ARIANG_MENU="AriaNg Web UI"
 L_ARIANG_TITLE="ARIANG WEB UI"
 L_ARIANG_STATUS="Status"; L_ARIANG_INSTALL="Install AriaNg"
 L_ARIANG_UNINSTALL="Uninstall AriaNg"; L_ARIANG_START="Start Web UI"
 L_ARIANG_STOP="Stop Web UI"; L_ARIANG_BACK="Back"
 L_ARIANG_RUNNING="RUNNING"; L_ARIANG_STOPPED="INACTIVE"
 L_ARIANG_INSTALLED="INSTALLED"; L_ARIANG_NOT_INSTALLED="NOT INSTALLED"
 L_ARIANG_INSTALL_OK="AriaNg installed! Open in browser:"
 L_ARIANG_INSTALL_FAIL="Installation failed!"
 L_ARIANG_UNINSTALLING="Removing AriaNg..."; L_ARIANG_UNINSTALL_OK="AriaNg removed."
 L_ARIANG_STARTING="Starting web server..."; L_ARIANG_START_OK="Web server started."
 L_ARIANG_START_FAIL="Could not start web server!"
 L_ARIANG_STOPPING="Stopping web server..."; L_ARIANG_STOP_OK="Web server stopped."
 L_ARIANG_NOT_INST_ERR="AriaNg not installed. Use Install option."
 L_ARIANG_URL_LABEL="AriaNg URL"; L_ARIANG_PORT="Web UI port"
 L_ARIANG_LIGHTTPD_INST="Installing lighttpd..."; L_ARIANG_LIGHTTPD_FAIL="lighttpd install failed!"
 L_ARIANG_WRITING="Writing AriaNg files..."; L_ARIANG_CONFIRM_UNINST="Remove AriaNg? [Y/N]: "
 L_ARIA2_UPDATE_TITLE="ARIA2 UPDATE"
 L_ARIA2_UPDATE_CHECKING="Checking for aria2 updates..."
 L_ARIA2_UPDATE_CURR="Installed:"
 L_ARIA2_UPDATE_AVAIL="Available:"
 L_ARIA2_UPDATE_LATEST="aria2 is already up to date."
 L_ARIA2_UPDATE_FOUND="New version available!"
 L_ARIA2_UPDATE_Q="Update aria2 now? [Y/N]: "
 L_ARIA2_UPDATE_STOPPING="Stopping service before update..."
 L_ARIA2_UPDATE_IN_PROGRESS="Updating aria2..."
 L_ARIA2_UPDATE_DONE="aria2 updated successfully!"
 L_ARIA2_UPDATE_FAIL="Update failed!"
 L_ARIA2_UPDATE_RESTARTING="Restarting service..."
 L_ARIA2_UPDATE_NOT_INSTALLED="aria2 is not installed. Use Install option."
 L_ARIA2_UPDATE_NO_INFO="Could not retrieve version info from opkg."
 L_ARIA2_UPDATE_CANCEL="Update cancelled."
 # === DEPENDENCY CONFLICT CHECK ===
 L_DEP_CONFLICT_TITLE="Shared dependency detected"
 L_DEP_CONFLICT_INFO="The following other scripts / packages also use this package:"
 L_DEP_CONFLICT_OPT="What would you like to do?"
 L_DEP_SKIP="Keep the package (skip removal)"
 L_DEP_FORCE="Force remove anyway (may break other scripts!)"
 L_DEP_RECOMMENDED="Recommended"
 L_DEP_SKIPPED="Kept — not removed"
 L_DEP_OPKG_RDEPS="Installed packages depending on it (via opkg)"
 L_DEP_SCAN_INFO="Scanning for conflicts..."
 L_DEP_NO_CONFLICT="No conflicts found. Safe to remove."
 L_FULL_UNINSTALL_CURL="curl package (conflict check)..."
 L_FULL_UNINSTALL_CURL_SKIP="curl not installed, skipping."
 elif [ "$LANG_SEL" = "ru" ]; then
 # === РУССКИЙ ЯЗЫК / RUSSIAN ===
 L_INSTALLED="УСТАНОВЛЕН"; L_NOT_INSTALLED="НЕ УСТАНОВЛЕН"
 L_RUNNING="РАБОТАЕТ"; L_STOPPED="ОСТАНОВЛЕН"
 L_ACTIVE="АКТИВЕН"; L_INACTIVE="НЕАКТИВЕН"
 L_DL_DIR="Загр. дир."; L_AUTO_START="Автозапуск"
 L_SERVICE="Сервис"; L_ARIA2C="aria2c"
 L_NOT_SET="[НЕ УСТАНОВЛЕНО]"; L_RPC="RPC"
 L_PORT="порт"; L_INSTALL_HINT="(Меню 1 -> Установка)"
 L_MAIN_MENU="ГЛАВНОЕ МЕНЮ"; L_YOUR_CHOICE="Ваш выбор"
 L_BACK_MAIN="Назад в главное меню"; L_EXIT="Выход"
 L_ARIA2_MGMT="Управление aria2"; L_ARIA2_MGMT_SUB="(сервис, настройки, установка)"
 L_ADD_DL="Добавить загрузку"; L_ADD_DL_SUB="(URL)"
 L_DOWNLOADS="Текущие загрузки"; L_SCAN_USB="Сканировать USB / Задать директорию загрузок"
 L_VIEW_LOGS="Просмотр логов"; L_CHECK_UPDATE="Проверить обновления"
 L_UNINSTALL_MGR="Удалить менеджер"; L_LANG_MENU="Язык / Language"
 L_ARIA2_MGMT_TITLE="УПРАВЛЕНИЕ aria2"
 L_START_SVC="ЗАПУСТИТЬ сервис"; L_STOP_SVC="ОСТАНОВИТЬ сервис"
 L_RESTART_SVC="ПЕРЕЗАПУСТИТЬ сервис"; L_SETTINGS="Настройки"
 L_INSTALL_ARIA2="УСТАНОВИТЬ aria2c (opkg)"; L_AUTO_TOGGLE="Автозапуск ВКЛ/ВЫКЛ"
 L_AUTO_SHORT="Автозапуск"
 L_SVC_NOT_INSTALLED="aria2 не установлен. Используйте пункт 5 для установки aria2c."
 L_SVC_CONF_MISSING="Файл конфигурации не найден. Создаю конфиг по умолчанию..."
 L_SVC_ALREADY_RUNNING="aria2 уже запущен."
 L_SVC_STARTING="Запускаю aria2..."; L_SVC_STARTED="aria2 запущен."
 L_SVC_START_FAIL="Не удалось запустить aria2!"
 L_SVC_LOG_HINT="Лог:";
 L_SVC_STARTING_PROC="Запуск aria2c..."
 L_SVC_WAITING="секунд ожидания..."
 L_SVC_LOG_TAIL="--- Последние строки лога ---"
 L_SVC_LOG_NOT_FOUND="Файл лога не найден:"
 L_SVC_CONF_MISSING_TXT="Файл конфигурации отсутствует!"
 L_SVC_BINARY_NOT_FOUND="НЕ НАЙДЕН"
 L_SVC_STOPPING="Останавливаю aria2..."
 L_SVC_STOPPED_OK="aria2 остановлен."; L_SVC_STOP_FAIL="Не удалось остановить. Принудительное завершение..."
 L_SVC_FORCE_KILLED="Принудительно завершён."; L_SVC_NOT_RUNNING="aria2 не запущен."
 L_SVC_RESTARTING="Перезапуск..."; L_SVC_RESTART_OK="Сервис перезапущен."
 L_SVC_RESTART_FAIL="Не удалось автоматически перезапустить сервис. Используйте Меню 1 -> ЗАПУСК."
 L_INSTALL_TITLE="УСТАНОВКА ARIA2"
 L_ALREADY_INSTALLED="aria2c уже установлен."
 L_PKG_UPDATING="Обновляю список пакетов..."; L_PKG_INSTALLING="Устанавливаю aria2..."
 L_INSTALL_OK="aria2 успешно установлен!"; L_INSTALL_FAIL="Установка не удалась! Проверьте интернет и настройки opkg."
 L_POST_INSTALL_TITLE="АВТОМАТИЧЕСКАЯ НАСТРОЙКА ПОСЛЕ УСТАНОВКИ"
 L_POST_INSTALL_MSG="Запускаю автоматическую настройку после установки..."
 L_CREATING_CONF="Создаю файл конфигурации по умолчанию..."
 L_SCANNING_USB="Сканирую USB устройства..."
 L_USB_DETECTED="Обнаружены USB устройства:"
 L_USB_FREE="Свободно"; L_USB_TOTAL="Всего"
 L_USB_USE_Q="Использовать '%s' как директорию загрузок? [Д/Н]: "
 L_USB_MANUAL="Введите директорию вручную: "
 L_USB_SELECT="Какую директорию? (номер, по умолчанию 1): "
 L_DL_DIR_SET="Директория загрузок:"; L_SETUP_DONE="Базовая настройка завершена!"
 L_HINT_SETTINGS="Подробные настройки: Меню 1 -> Настройки"
 L_HINT_START="Запуск сервиса: Меню 1 -> ЗАПУСТИТЬ сервис"
 L_CONF_CREATED="Файл конфигурации создан:"
 L_USB_TITLE="СКАНИРОВАНИЕ USB УСТРОЙСТВ"; L_USB_SEARCHING="Поиск подключённых устройств..."
 L_USB_NONE="USB устройства не найдены."; L_USB_CHECK="Убедитесь, что USB накопитель подключён."
 L_USB_DETECTED2="Обнаруженные устройства:"; L_USB_USED="Исп."
 L_USB_SELECT_NUM="Выберите номер для установки директории загрузок (0 = отмена): "
 L_USB_DIR_SET="Директория загрузок установлена:"; L_USB_RESTART_Q="Перезапустить сервис? [Д/Н]: "
 L_USB_RESTARTING="Перезапуск..."; L_USB_RESTARTED="Сервис перезапущен."
 L_INVALID="Неверный выбор."
 L_ADD_DL_TITLE="ДОБАВИТЬ ЗАГРУЗКУ"; L_ARIA2_NOT_RUNNING="aria2 не запущен. Используйте Меню 1 -> ЗАПУСК."
 L_URL_PROMPT="URL загрузки: "; L_DIR_PROMPT="Директория сохранения (пусто = по умолчанию '%s'): "
 L_DL_QUEUED="Загрузка добавлена в очередь!"; L_DL_GID="GID"; L_DL_FAIL="Не удалось добавить загрузку."
 L_SERVER_RESP="Ответ сервера:"; L_RPC_HINT="Проверьте настройки RPC и порт."
 L_DL_LIST_TITLE="СПИСОК ЗАГРУЗОК"; L_ACTIVE_DL="АКТИВНЫЕ ЗАГРУЗКИ:"
 L_WAITING_DL="ОЖИДАЮЩИЕ ЗАГРУЗКИ:"; L_COMPLETED_DL="НЕДАВНО ЗАВЕРШЁННЫЕ:"
 L_NO_ACTIVE="(Нет активных загрузок)"; L_NO_WAITING="(Нет ожидающих загрузок)"
 L_NO_COMPLETED="(Нет завершённых загрузок)"; L_PRESS_ENTER="Нажмите Enter для продолжения..."
 L_SETTINGS_TITLE="МЕНЮ НАСТРОЕК"; L_SET_DL_DIR="Директория загрузок"
 L_SET_CONCURRENT="Одновременные загрузки"; L_SET_MAX_CONN="Макс. соединений/сервер"
 L_SET_SPLIT="Кол-во сегментов"; L_SET_DL_SPEED="Лимит скорости загрузки"; L_SET_UL_SPEED="Лимит скорости отдачи"
 L_SET_UNLIMITED="0=без ограничений"; L_SET_RPC="RPC"; L_SET_RPC_SECRET="Пароль RPC"
 L_RPC_SECRET_LABEL="Секретный ключ RPC"
 L_SET_ALLOC="Распределение файлов"; L_SET_LOG_LEVEL="Уровень логирования"
 L_SET_CHANGE_DIR="Сменить директорию загрузок"; L_SET_CONN="Настройки соединения"
 L_SET_SPEED="Настройки ограничения скорости"; L_SET_RPC_MENU="Настройки RPC"
 L_SET_ALLOC_MENU="Метод распределения файлов"; L_SET_LOG_MENU="Настройки лога"
 L_SET_SHOW_CONF="Показать весь файл конфигурации"; L_SET_RESET_CONF="Сбросить конфиг по умолчанию"
 L_SET_BACK="Назад в главное меню"; L_SET_CONFIGURED="НАСТРОЕН"; L_SET_EMPTY="[ПУСТО]"
 L_CONN_TITLE="НАСТРОЙКИ СОЕДИНЕНИЯ"; L_CONN_HINT="Оставьте пустым, чтобы сохранить текущее значение."
 L_CONN_CONCURRENT="Макс. одновременных загрузок"; L_CONN_MAXCONN="Макс. соединений/сервер (1-16)"
 L_CONN_SPLIT="Кол-во сегментов на файл"; L_CONN_MINSPLIT="Мин. размер сегмента (напр. 20M)"
 L_CONN_CACHE="Дисковый кэш (напр. 64M)"; L_CONN_UPDATED="Настройки соединения обновлены."
 L_SPEED_TITLE="НАСТРОЙКИ ОГРАНИЧЕНИЯ СКОРОСТИ"; L_SPEED_HINT="0 = Без ограничений"
 L_SPEED_EXAMPLE="Пример: 1M = 1 МБ/с | 512K = 512 КБ/с"
 L_SPEED_DL="Лимит скорости загрузки"; L_SPEED_UL="Лимит скорости отдачи"
 L_SPEED_UPDATED="Ограничения скорости обновлены."
 L_RPC_TITLE="НАСТРОЙКИ RPC"; L_RPC_HINT2="RPC позволяет использовать AriaNg, webui-aria2 и т.д."
 L_RPC_ENABLE="RPC включён? (true/false)"; L_RPC_PORT2="Порт RPC"
 L_RPC_SECRET2="Пароль RPC (пусто = без пароля)"; L_RPC_ALL="Разрешить все интерфейсы (true/false)"
 L_RPC_ORIGIN="Разрешить все источники (true/false)"; L_RPC_UPDATED="Настройки RPC обновлены."
 L_ALLOC_TITLE="МЕТОД РАСПРЕДЕЛЕНИЯ ФАЙЛОВ"
 L_ALLOC_NONE="Без распределения (самый быстрый старт)"
 L_ALLOC_PREALLOC="Предварительное выделение (для FAT32)"
 L_ALLOC_FALLOC="Быстрое выделение (для ext4/NTFS)"
 L_ALLOC_TRUNC="Метод усечения"; L_ALLOC_CURRENT="Текущий"
 L_ALLOC_PROMPT="Ваш выбор [1-4, пусто для пропуска]: "; L_ALLOC_NOCHANGE="Никаких изменений."
 L_LOG_TITLE="НАСТРОЙКИ ЛОГА"; L_LOG_PATH="Путь к файлу лога"; L_LOG_LEVEL2="Уровень логирования"
 L_LOG_LEVELS="1) debug 2) info 3) notice 4) warn 5) error"
 L_LOG_UPDATED="Настройки лога обновлены."
 L_CONF_FILE="ФАЙЛ КОНФИГУРАЦИИ"; L_CONF_NOT_FOUND="Файл конфигурации не найден."
 L_CONF_RESET_Q="Сбросить конфиг? Все настройки будут потеряны! [Д/Н]: "
 L_CURRENT="текущ."; L_BLANK_SKIP="пусто для пропуска"; L_CHOICE_PROMPT="Ваш выбор"
 L_CONF_HEADER="Keenetic Aria2 Manager - Конфигурация"
 L_UPDATE_TITLE="ПРОВЕРКА ОБНОВЛЕНИЙ"; L_UPDATE_CONNECTING="Подключение к GitHub..."
 L_UPDATE_FAIL="Не удалось подключиться к серверу обновлений."; L_UPDATE_CHECK_URL="Проверенный URL:"
 L_UPDATE_NO_VER="Информация о версии не найдена в загруженном файле."
 L_UPDATE_CURR="Текущая версия"; L_UPDATE_REMOTE="Версия на GitHub"
 L_UPDATE_AVAIL="Доступна новая версия!"; L_UPDATE_Q="Обновить сейчас? [Д/Н]: "
 L_UPDATE_IN_PROGRESS="Обновление..."; L_UPDATE_STOPPING="Остановка сервиса..."
 L_UPDATE_DONE="Файл обновлён:"; L_UPDATE_RESTARTING="Перезапуск сервиса..."
 L_UPDATE_RESTART_OK="Сервис перезапущен."
 L_UPDATE_RESTART_FAIL="Не удалось автоматически перезапустить сервис. Используйте Меню 1 -> ЗАПУСК."
 L_UPDATE_LATEST="Уже установлена последняя версия"; L_UPDATE_CANCEL="Обновление отменено."
 # === HEADER EXTRA ===
 L_HDR_SYSTEM="Система"
 L_HDR_UPTIME="Время работы"
 L_HDR_DISK_FREE="Диск своб."
 L_HDR_ACTIVE_DL="Акт. загр."
 L_HDR_ACTIVE_DL_SVC_DOWN="Сервис остановлен"
 L_HDR_ACTIVE_DL_NONE="Нет загрузок"
 L_HDR_TELEGRAM="Telegram"
 L_HDR_GITHUB="GitHub"
 L_HDR_RAM="RAM своб."
 L_HDR_WAN_IP="WAN IP"
 L_HDR_OS_VER="KeeneticOS"
 L_HDR_LOAD="Загрузка ЦП"
 L_HDR_DL_SPEED="Скор. загр."
 L_HDR_ABOUT="О ПРОГРАММЕ"
 L_HDR_FEATURES="ВОЗМОЖНОСТИ"
 # === HEALTH MENU ===
 L_HEALTH_MENU="Здоровье системы"
 L_HEALTH_TITLE="ПРОВЕРКА ЗДОРОВЬЯ СИСТЕМЫ"
 L_HEALTH_SEC_CPU="ЦП и НАГРУЗКА"
 L_HEALTH_SEC_RAM="ПАМЯТЬ"
 L_HEALTH_SEC_DISK="ХРАНИЛИЩЕ"
 L_HEALTH_SEC_NET="СЕТЬ"
 L_HEALTH_SEC_PROC="ПРОЦЕССЫ"
 L_HEALTH_SEC_ARIA2="ARIA2"
 L_HEALTH_CPU_USAGE="Загрузка ЦП"
 L_HEALTH_LOAD_1="Нагрузка 1м"
 L_HEALTH_LOAD_5="Нагрузка 5м"
 L_HEALTH_LOAD_15="Нагрузка 15м"
 L_HEALTH_TEMP="Температура"
 L_HEALTH_RAM_USED="RAM использовано"
 L_HEALTH_RAM_FREE="RAM свободно"
 L_HEALTH_RAM_TOTAL="RAM всего"
 L_HEALTH_RAM_BUFCACHE="Буфер/Кэш"
 L_HEALTH_SWAP_USED="Swap использовано"
 L_HEALTH_SWAP_TOTAL="Swap всего"
 L_HEALTH_WAN_IP="WAN IP"
 L_HEALTH_LAN_IP="LAN IP"
 L_HEALTH_DNS_PING="Пинг DNS"
 L_HEALTH_GW_PING="Пинг шлюза"
 L_HEALTH_RX="Получено всего"
 L_HEALTH_TX="Отправлено всего"
 L_HEALTH_CONN="Активные соед."
 L_HEALTH_PROC_COUNT="Процессы"
 L_HEALTH_ARIA2_PID="aria2 PID"
 L_HEALTH_ARIA2_RSS="aria2 RAM"
 L_HEALTH_ARIA2_ACTIVE="Акт. загр."
 L_HEALTH_ARIA2_WAITING="Ожид. загр."
 L_HEALTH_ARIA2_STOPPED="Недавние загр."
 L_HEALTH_ARIA2_SPEED="Скор. загр."
 L_HEALTH_ARIA2_UPSPEED="Скор. отдачи"
 L_HEALTH_ARIA2_SESSIONS="Файл сессии"
 L_HEALTH_REFRESHING="Обновление..."
 L_HEALTH_AUTO_REF="Автообновление (5с) — нажмите любую клавишу для остановки"
 L_HEALTH_PRESS_R=" R) Обновить A) Автообновление 0) Назад"
 L_HEALTH_OK="OK"
 L_HEALTH_WARN="ВНИМАНИЕ"
 L_HEALTH_CRIT="КРИТИЧНО"
 L_HEALTH_NA="Н/Д"
 L_HEALTH_MS="мс"
 L_HEALTH_TIMEOUT="тайм-аут"
 L_HDR_DESC1="Менеджер загрузок aria2 для роутеров Keenetic"
 L_HDR_DESC2="Добавляйте загрузки через RPC | AriaNg WebUI | Ограничения скорости"
 L_HDR_DESC3="Telegram уведомления | Автозапуск | Управление USB дисками"
 L_HDR_FEAT1="Многопоточные загрузки с поддержкой сегментации"
 L_HDR_FEAT2="AriaNg WebUI — управление загрузками из любого браузера"
 L_HDR_FEAT3="Telegram уведомления для каждого события загрузки"
 L_HDR_FEAT4="Автоопределение USB диска и настройка директории загрузок"
 # === DIAG MENU ===
 L_DIAG_MENU="Диагностика и тест"
 L_HELP_MENU="Помощь и руководство"
 L_DIAG_TITLE="ДИАГНОСТИКА И ТРЕБОВАНИЯ"
 L_DIAG_SEC_CORE="── ОСНОВНЫЕ ТРЕБОВАНИЯ ──"
 L_DIAG_SEC_OPT="── ОПЦИОНАЛЬНЫЕ КОМПОНЕНТЫ ──"
 L_DIAG_SEC_UPDATE="── ПРОВЕРКА ОБНОВЛЕНИЙ ──"
 L_DIAG_SEC_FUNC="── ТЕСТЫ ФУНКЦИЙ ──"
 L_DIAG_OK="OK"
 L_DIAG_FAIL="ОТСУТСТВУЕТ"
 L_DIAG_WARN="ВНИМАНИЕ"
 L_DIAG_RUNNING="РАБОТАЕТ"
 L_DIAG_STOPPED="ОСТАНОВЛЕН"
 L_DIAG_ACTIVE="АКТИВЕН"
 L_DIAG_INACTIVE="НЕАКТИВЕН"
 L_DIAG_OPTIONAL="опционально"
 L_DIAG_NOT_INSTALLED="Не установлен"
 L_DIAG_INSTALLED="Установлен"
 L_DIAG_CONF_OK="Конфиг OK"
 L_DIAG_CONF_MISS="Конфиг ОТСУТСТВУЕТ"
 L_DIAG_SESSION_OK="Файл сессии OK"
 L_DIAG_SESSION_MISS="Файл сессии отсутствует"
 L_DIAG_LOGDIR_OK="Директория лога OK"
 L_DIAG_LOGDIR_MISS="Директория лога отсутствует"
 L_DIAG_RPC_OK="RPC отвечает"
 L_DIAG_RPC_FAIL="RPC не отвечает"
 L_DIAG_RPC_DISABLED="RPC отключён в конфиге"
 L_DIAG_DL_DIR_OK="Директория загрузок существует"
 L_DIAG_DL_DIR_MISS="Директория загрузок ОТСУТСТВУЕТ"
 L_DIAG_DL_DIR_NOTSET="Директория загрузок не задана"
 L_DIAG_AUTOSTART_ON="Автозапуск включён"
 L_DIAG_AUTOSTART_OFF="Автозапуск отключён"
 L_DIAG_TG_ENABLED="Telegram ВКЛЮЧЁН"
 L_DIAG_TG_DISABLED="Telegram отключён"
 L_DIAG_TG_NO_TOKEN="Токен не задан!"
 L_DIAG_TG_NO_CHAT="Chat ID не задан!"
 L_DIAG_CURL_OK="curl установлен"
 L_DIAG_CURL_MISS="curl ОТСУТСТВУЕТ — нужен для RPC/Telegram/Обновлений"
 L_DIAG_OPKG_OK="opkg доступен"
 L_DIAG_OPKG_MISS="opkg не найден"
 L_DIAG_ENTWARE_OK="Entware /opt OK"
 L_DIAG_ENTWARE_MISS="Entware /opt ОТСУТСТВУЕТ"
 L_DIAG_ARIANG_RUNNING="AriaNg запущен"
 L_DIAG_ARIANG_STOPPED="AriaNg остановлен"
 L_DIAG_ARIANG_NOT_INST="Не установлен"
 L_DIAG_LIGHTTPD_OK="lighttpd установлен"
 L_DIAG_LIGHTTPD_MISS="lighttpd не установлен"
 L_DIAG_UPDATE_MGR="Скрипт менеджера"
 L_DIAG_UPDATE_ARIA2="Бинарный файл aria2c"
 L_DIAG_UPDATE_CHECKING="Проверка..."
 L_DIAG_UPDATE_LATEST="Актуальная версия"
 L_DIAG_UPDATE_AVAIL="Доступно обновление"
 L_DIAG_UPDATE_FAIL="Не удалось проверить"
 L_DIAG_SUMMARY="ИТОГО"
 L_DIAG_ALL_OK="Все основные требования выполнены."
 L_DIAG_ISSUES="Найдены проблемы:"
 L_DIAG_PRESS_R=" R) Обновить F) Исправить проблемы 0) Назад"
 L_DIAG_FIX_TITLE="ИСПРАВИТЬ / УСТАНОВИТЬ ОТСУТСТВУЮЩЕЕ"
 L_DIAG_FIX_ARIA2="Установить aria2c"
 L_DIAG_FIX_CONF="Создать стандартный конфиг"
 L_DIAG_FIX_SESSION="Создать файл сессии"
 L_DIAG_FIX_LOGDIR="Создать директорию лога"
 L_DIAG_FIX_DLDIR="Задать директорию загрузок"
 L_DIAG_FIX_CURL="Установить curl"
 L_DIAG_FIX_AUTOSTART="Включить автозапуск"
 L_DIAG_FIX_NOTHING="Исправлять нечего — всё OK!"
 L_DIAG_FIX_DONE="Исправление завершено."
 # diag label strings
 L_DIAG_LBL_LOGDIR="Директория лога"
 L_DIAG_LBL_DLDIR="Директория загрузок"
 L_DIAG_LBL_SERVICE="Сервис aria2c"
 L_DIAG_LBL_AUTOSTART="Автозапуск"
 L_DIAG_LBL_USB="USB диск"
 L_DIAG_LBL_RPC_TEST="Тест функции RPC"
 L_DIAG_LBL_INTERNET="Интернет"
 L_DIAG_LBL_TGHOOKS="Telegram хуки"
 L_DIAG_D_OPTBIN="/opt/bin присутствует"
 L_DIAG_D_OPTNO="существует, но opkg отсутствует"
 L_DIAG_D_RPCSVCDOWN="включён (сервис остановлен)"
 L_DIAG_D_FREE="Свободно"
 L_DIAG_D_DISKS="диск(и) подключены"
 L_DIAG_D_NODISK="USB диск не найден"
 L_DIAG_D_ACTIVE="Активные"
 L_DIAG_D_WAITING="Ожидающие"
 L_DIAG_D_NORPC="getGlobalStat не отвечает"
 L_DIAG_D_SVCRPC="Сервис остановлен или RPC отключён"
 L_DIAG_D_GITHUB="github.com доступен"
 L_DIAG_D_CFONE="1.1.1.1 доступен"
 L_DIAG_D_NOINET="Нет соединения / GitHub недоступен"
 L_DIAG_D_HOOKSOK="tg_notify.sh + on_complete + on_error"
 L_DIAG_D_HOOKSMISS="Некоторые файлы хуков отсутствуют (создаются при запуске сервиса)"
 L_DIAG_D_GHVER="Не удалось прочитать версию с GitHub"
 L_DIAG_D_LOCAL="Локальная"
 L_DIAG_D_NEW="Новая"
 L_DIAG_D_NOSERVER="Сервер недоступен"
 L_DIAG_D_INSTALLED="Установлен"
 L_DIAG_D_AVAILPKG="Доступен"
 L_DIAG_D_OPKGFAIL="Не удалось получить информацию от opkg"
 L_DIAG_D_MENU1="Меню 1 → Установка"
 L_DIAG_D_FIXDIR="Введите директорию загрузок вручную: "
 L_UNINSTALL_TITLE="УДАЛЕНИЕ МЕНЕДЖЕРА"; L_UNINSTALL_INFO="Это действие:"
 L_UNINSTALL_1="Остановит запущенный сервис aria2"
 L_UNINSTALL_2="Удалит файл автозапуска init.d"
 L_UNINSTALL_3="Удалит ярлыки (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)"
 L_UNINSTALL_4="Удалит этот скрипт менеджера"
 L_UNINSTALL_KEEP="Файлы конфигурации и загрузки НЕ будут затронуты!"
 L_UNINSTALL_CONFIRM="Введите YES для продолжения (пусто = отмена): "
 L_UNINSTALL_STOPPING="Остановка сервиса..."; L_UNINSTALL_DONE="Менеджер удалён."
 L_UNINSTALL_CONF_KEPT="Файлы конфигурации остались по адресу:"; L_UNINSTALL_CANCEL="Операция отменена."
 L_UNINSTALL_CONFIRM_WORD="YES"
 L_AUTO_INSTALLED="Автозапуск уже настроен. Удалить? [Д/Н]: "
 L_AUTO_REMOVED="Автозапуск удалён."; L_AUTO_INSTALLED_OK="Автозапуск установлен:"
 L_LOCK_MSG="Похоже, скрипт уже запущен (файл блокировки существует)."
 L_LOCK_PID="PID предыдущей сессии:"; L_LOCK_PID_DEAD="(процесс не запущен)"
 L_LOCK_Q="Начать новую сессию? [Д/Н]: "; L_LOCK_CLEARED="Блокировка снята, запускаю новую сессию..."
 L_LOCK_EXIT="Выход."
 L_LANG_TITLE="ЯЗЫК / LANGUAGE"; L_LANG_CURRENT="Текущий язык:"
 L_LANG_SELECT="Выберите язык:"; L_LANG_TR="Türkçe"; L_LANG_EN="English"; L_LANG_RU="Русский"
 L_LANG_CHANGED="Язык изменён."; L_LANG_BACK="Назад"
 L_CONFIRM_YES="Д"; L_CONFIRM_YES2="д"
 # === TELEGRAM ===
 L_TG_MENU="Telegram уведомления"
 L_TG_TITLE="TELEGRAM УВЕДОМЛЕНИЯ"
 L_TG_STATUS="Статус"; L_TG_ENABLED_STATUS="ВКЛЮЧЕНЫ"; L_TG_DISABLED_STATUS="ОТКЛЮЧЕНЫ"
 L_TG_TOKEN="Bot Token"; L_TG_CHAT="Chat ID"; L_TG_NOT_SET="[НЕ ЗАДАНО]"
 L_TG_NOTIFICATIONS="Активные уведомления"
 L_TG_OPT_TOKEN="Задать Bot Token"; L_TG_OPT_CHAT="Задать Chat ID"
 L_TG_OPT_TOGGLE="Включить / Отключить Telegram"; L_TG_OPT_NOTIFY="Настройки уведомлений"
 L_TG_ABOUT_TITLE="О ПРОГРАММЕ"
 L_TG_ABOUT_DESC="Telegram уведомления автоматически отправляют сообщение при каждом событии загрузки."
 L_TG_ABOUT_CURL="Для работы уведомлений требуется curl."
 L_TG_ABOUT_AUTO="Сервис Telegram устанавливает curl автоматически при первом запуске."
 L_TG_ABOUT_MANUAL="Для ручной установки используйте пункт 5 из этого меню."
 L_TG_OPT_TEST="Отправить тестовое сообщение"; L_TG_OPT_BACK="Назад в главное меню"
 L_TG_TOKEN_PROMPT="Введите Bot Token (пусто = отмена): "
 L_TG_TOKEN_SAVED="Bot Token сохранён."
 L_TG_CHAT_PROMPT="Введите Chat ID (пусто = отмена): "
 L_TG_CHAT_SAVED="Chat ID сохранён."
 L_TG_TOGGLED_ON="Telegram уведомления ВКЛЮЧЕНЫ."
 L_TG_TOGGLED_OFF="Telegram уведомления ОТКЛЮЧЕНЫ."
 L_TG_NEED_TOKEN="Сначала нужно задать Bot Token и Chat ID!"
 L_TG_TEST_SENDING="Отправляю тестовое сообщение..."
 L_TG_TEST_OK="Тестовое сообщение успешно отправлено!"
 L_TG_TEST_FAIL="Ошибка отправки. Проверьте Token и Chat ID."
 L_TG_NOTIFY_TITLE="НАСТРОЙКИ УВЕДОМЛЕНИЙ"
 L_TG_N_SVC_START="Сервис запущен"; L_TG_N_SVC_STOP="Сервис остановлен"
 L_TG_N_DL_ADD="Загрузка добавлена"; L_TG_N_DL_COMPLETE="Загрузка завершена"
 L_TG_N_DL_ERROR="Ошибка загрузки"; L_TG_N_DL_STOP="Загрузка остановлена/отменена"
 L_TG_N_ON="ВКЛ"; L_TG_N_OFF="ВЫКЛ"; L_TG_N_SAVED="Настройки уведомлений сохранены."
 L_TG_MSG_SVC_START="✅ Сервис aria2 запущен"
 L_TG_MSG_SVC_STOP="⏹ Сервис aria2 остановлен"
 L_TG_MSG_DL_ADD="➕ Загрузка добавлена"
 L_TG_MSG_DL_COMPLETE="✅ Загрузка завершена"
 L_TG_MSG_DL_ERROR="❌ Ошибка загрузки"
 L_TG_MSG_DL_STOP="⏸ Загрузка остановлена"
 L_TG_MSG_TEST="🔔 Keenetic Aria2 Manager - Тестовое уведомление"
 L_TG_MSG_SECRET_KEY="🔑 Секретный ключ RPC обновлён"
 L_TG_N_WEBUI_START="WebUI запущен"; L_TG_N_WEBUI_STOP="WebUI остановлен"
 L_TG_N_SECRET_KEY="Секретный ключ RPC изменён"
 L_TG_N_BACKUP_CREATED="Резервная копия создана"
 L_TG_N_BACKUP_DELETED="Резервная копия удалена"
 L_TG_N_BACKUP_RESTORED="Резервная копия восстановлена"
 L_TG_MSG_BACKUP_CREATED="💾 Резервная копия создана"
 L_TG_MSG_BACKUP_DELETED="🗑 Резервная копия удалена"
 L_TG_MSG_BACKUP_RESTORED="♻️ Резервная копия восстановлена"
 L_TG_MSG_WEBUI_START="🖥️ AriaNg WebUI запущен"
 L_TG_MSG_WEBUI_STOP="⏹ AriaNg WebUI остановлен"
 L_TG_CURL_LABEL="Необходимый компонент"
 L_TG_CURL_OK="УСТАНОВЛЕН"
 L_TG_CURL_MISSING="ОТСУТСТВУЕТ"
 L_TG_CURL_INSTALL_Q="Для Telegram уведомлений требуется curl. Установить сейчас? [Д/Н]: "
 L_TG_OPT_CURL="Установить curl"
 # === HEADER NEW ===
 L_SELECTED_DISK="Выбранный диск"; L_DL_LOCATION="Место загрузки"
 L_DISK_NOT_SET="[НЕ ЗАДАНО]"
 # === FOLDER SELECTION ===
 L_FOLDER_DEFAULT_INFO="По умолчанию: На диске будет создана папка /aria2/downloads."
 L_FOLDER_CHANGE_Q="Изменить папку? [Д/Н]: "
 L_FOLDER_PROMPT="Введите имя подпапки (напр. downloads, media): "
 L_FOLDER_CUSTOM_SET="Пользовательская папка установлена:"
 L_FOLDER_DEFAULT_SET="Папка по умолчанию установлена:"
 # === FULL UNINSTALL ===
 L_FULL_UNINSTALL_TITLE="ПОЛНОЕ УДАЛЕНИЕ"
 L_FULL_UNINSTALL_INFO="Это действие полностью удалит:"
 L_FULL_UNINSTALL_1="Сервис aria2 (остановлен + удалён через opkg)"
 L_FULL_UNINSTALL_2="Все файлы конфигурации и логи"
 L_FULL_UNINSTALL_3="Файл автозапуска (init.d)"
 L_FULL_UNINSTALL_4="Ярлыки (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)"
 L_FULL_UNINSTALL_5="Этот скрипт менеджера"
 L_FULL_UNINSTALL_6="AriaNg WebUI (файлы + конфиг lighttpd + автозапуск)"
 L_FULL_UNINSTALL_DL_Q="Ваша папка загрузок:"
 L_FULL_UNINSTALL_DL_DEL="Удалить также загруженные файлы? [Д/Н]: "
 L_FULL_UNINSTALL_DL_KEEP="Загруженные файлы будут сохранены."
 L_FULL_UNINSTALL_DL_DELETING="Удаление загрузок..."
 L_FULL_UNINSTALL_DL_DELETED="Загрузки удалены."
 L_FULL_UNINSTALL_CONFIRM="Введите REMOVE для подтверждения полного удаления: "
 L_FULL_UNINSTALL_CONFIRM_WORD="REMOVE"
 L_FULL_UNINSTALL_STOPPING="Остановка сервиса aria2..."
 L_FULL_UNINSTALL_REMOVING_PKG="Удаление пакета aria2 через opkg..."
 L_FULL_UNINSTALL_PKG_DONE="Пакет aria2 удалён."
 L_FULL_UNINSTALL_PKG_FAIL="opkg remove не удался (возможно, уже удалён)."
 L_FULL_UNINSTALL_CONF="Удаление файлов конфигурации и логов..."
 L_FULL_UNINSTALL_DONE="Полное удаление завершено. Система очищена."
 L_FULL_UNINSTALL_CANCEL="Удаление отменено."
 L_FULL_UNINSTALL_ARIANG="Удаление AriaNg WebUI..."
 L_FULL_UNINSTALL_ARIANG_STOP="Остановка AriaNg (lighttpd)..."
 L_FULL_UNINSTALL_ARIANG_HTML="Удаление HTML файлов AriaNg:"
 L_FULL_UNINSTALL_ARIANG_CONF="Удаление конфига lighttpd:"
 L_FULL_UNINSTALL_ARIANG_INIT="Удаление автозапуска AriaNg:"
 L_FULL_UNINSTALL_ARIANG_PKG="Удаление пакета lighttpd через opkg..."
 L_FULL_UNINSTALL_ARIANG_DONE="AriaNg удалён."
 L_FULL_UNINSTALL_ARIANG_SKIP="AriaNg не установлен, пропускаю."
 L_FULL_UNINSTALL_RESIDUAL="Удаление оставшихся файлов и директорий..."
 L_FULL_UNINSTALL_RESIDUAL_DONE="Оставшиеся файлы очищены."
 # === ARIA2 ONLY REMOVE ===
 L_ARIA2_ONLY_TITLE="УДАЛИТЬ ARIA2 (НЕЗАВИСИМО)"
 L_ARIA2_ONLY_INFO="Это действие полностью удалит aria2 и его файлы:"
 L_ARIA2_ONLY_1="Сервис aria2 (остановлен + удалён через opkg)"
 L_ARIA2_ONLY_2="Все файлы конфигурации aria2, логи и сессии"
 L_ARIA2_ONLY_3="Файл автозапуска (init.d)"
 L_ARIA2_ONLY_4="AriaNg WebUI (если установлен)"
 L_ARIA2_ONLY_5="Все оставшиеся файлы aria2 и информация opkg"
 L_ARIA2_ONLY_KEEP="Скрипт менеджера и ярлыки НЕ будут удалены."
 L_ARIA2_ONLY_DL_Q="Ваша папка загрузок:"
 L_ARIA2_ONLY_DL_DEL="Удалить также загруженные файлы? [Д/Н]: "
 L_ARIA2_ONLY_DL_KEEP="Загруженные файлы будут сохранены."
 L_ARIA2_ONLY_DL_DELETING="Удаление загрузок..."
 L_ARIA2_ONLY_DL_DELETED="Загрузки удалены."
 L_ARIA2_ONLY_CONFIRM="Введите REMOVE для подтверждения удаления aria2: "
 L_ARIA2_ONLY_CONFIRM_WORD="REMOVE"
 L_ARIA2_ONLY_CANCEL="Удаление отменено."
 L_ARIA2_ONLY_DONE="aria2 и все его файлы удалены. Менеджер остаётся активным."
 # === ARIA2 UPDATE ===
 L_ARIA2_UPDATE="Обновить aria2c"
 L_ARIANG_MENU="AriaNg Web UI"
 L_ARIANG_TITLE="ARIANG WEB UI"
 L_ARIANG_STATUS="Статус"; L_ARIANG_INSTALL="Установить AriaNg"
 L_ARIANG_UNINSTALL="Удалить AriaNg"; L_ARIANG_START="Запустить Web UI"
 L_ARIANG_STOP="Остановить Web UI"; L_ARIANG_BACK="Назад"
 L_ARIANG_RUNNING="РАБОТАЕТ"; L_ARIANG_STOPPED="ОСТАНОВЛЕН"
 L_ARIANG_INSTALLED="УСТАНОВЛЕН"; L_ARIANG_NOT_INSTALLED="НЕ УСТАНОВЛЕН"
 L_ARIANG_INSTALL_OK="AriaNg установлен! Откройте в браузере:"
 L_ARIANG_INSTALL_FAIL="Установка не удалась!"
 L_ARIANG_UNINSTALLING="Удаление AriaNg..."; L_ARIANG_UNINSTALL_OK="AriaNg удалён."
 L_ARIANG_STARTING="Запуск веб-сервера..."; L_ARIANG_START_OK="Веб-сервер запущен."
 L_ARIANG_START_FAIL="Не удалось запустить веб-сервер!"
 L_ARIANG_STOPPING="Остановка веб-сервера..."; L_ARIANG_STOP_OK="Веб-сервер остановлен."
 L_ARIANG_NOT_INST_ERR="AriaNg не установлен. Используйте пункт установки."
 L_ARIANG_URL_LABEL="URL AriaNg"; L_ARIANG_PORT="Порт Web UI"
 L_ARIANG_LIGHTTPD_INST="Установка lighttpd..."; L_ARIANG_LIGHTTPD_FAIL="Установка lighttpd не удалась!"
 L_ARIANG_WRITING="Запись файлов AriaNg..."; L_ARIANG_CONFIRM_UNINST="Удалить AriaNg? [Д/Н]: "
 L_ARIA2_UPDATE_TITLE="ОБНОВЛЕНИЕ ARIA2"
 L_ARIA2_UPDATE_CHECKING="Проверка обновлений aria2..."
 L_ARIA2_UPDATE_CURR="Установлен:"
 L_ARIA2_UPDATE_AVAIL="Доступен:"
 L_ARIA2_UPDATE_LATEST="aria2 уже обновлён."
 L_ARIA2_UPDATE_FOUND="Доступна новая версия!"
 L_ARIA2_UPDATE_Q="Обновить aria2 сейчас? [Д/Н]: "
 L_ARIA2_UPDATE_STOPPING="Остановка сервиса перед обновлением..."
 L_ARIA2_UPDATE_IN_PROGRESS="Обновление aria2..."
 L_ARIA2_UPDATE_DONE="aria2 успешно обновлён!"
 L_ARIA2_UPDATE_FAIL="Обновление не удалось!"
 L_ARIA2_UPDATE_RESTARTING="Перезапуск сервиса..."
 L_ARIA2_UPDATE_NOT_INSTALLED="aria2 не установлен. Используйте пункт установки."
 L_ARIA2_UPDATE_NO_INFO="Не удалось получить информацию о версии от opkg."
 L_ARIA2_UPDATE_CANCEL="Обновление отменено."
 # === DEPENDENCY CONFLICT CHECK ===
 L_DEP_CONFLICT_TITLE="Обнаружена общая зависимость"
 L_DEP_CONFLICT_INFO="Следующие скрипты/пакеты также используют этот пакет:"
 L_DEP_CONFLICT_OPT="Что вы хотите сделать?"
 L_DEP_SKIP="Оставить пакет (пропустить удаление)"
 L_DEP_FORCE="Принудительно удалить (может сломать другие скрипты!)"
 L_DEP_RECOMMENDED="Рекомендуется"
 L_DEP_SKIPPED="Оставлен — не удалён"
 L_DEP_OPKG_RDEPS="Установленные пакеты, зависящие от него (через opkg)"
 L_DEP_SCAN_INFO="Сканирование конфликтов..."
 L_DEP_NO_CONFLICT="Конфликтов не найдено. Безопасно для удаления."
 L_FULL_UNINSTALL_CURL="Пакет curl (проверка конфликтов)..."
 L_FULL_UNINSTALL_CURL_SKIP="curl не установлен, пропускаю."
 else
 L_INSTALLED="KURULU"; L_NOT_INSTALLED="KURULU DEĞİL"
 L_RUNNING="ÇALIŞIYOR"; L_STOPPED="KAPALI"
 L_ACTIVE="AKTİF"; L_INACTIVE="PASİF"
 L_DL_DIR="İnd. dizin"; L_AUTO_START="Oto başlat"
 L_SERVICE="Servis"; L_ARIA2C="aria2c"
 L_NOT_SET="[AYARLANMAMIŞ]"; L_RPC="RPC"
 L_PORT="port"; L_INSTALL_HINT="(Menü 1 -> Kur)"
 L_MAIN_MENU="ANA MENÜ"; L_YOUR_CHOICE="Seçiminiz"
 L_BACK_MAIN="Ana Menüye Dön"; L_EXIT="Çıkış"
 L_ARIA2_MGMT="aria2 Yönetimi"; L_ARIA2_MGMT_SUB="(servis, ayarlar, kurulum)"
 L_ADD_DL="İndirme Ekle"; L_ADD_DL_SUB="(URL)"
 L_DOWNLOADS="Mevcut İndirmeler"; L_SCAN_USB="USB Tara / İndirme Dizini Ayarla"
 L_VIEW_LOGS="Logları İzle"; L_CHECK_UPDATE="Güncelleme Kontrol Et"
 L_UNINSTALL_MGR="Manager'ı Kaldır"; L_LANG_MENU="Dil / Language"
 L_ARIA2_MGMT_TITLE="aria2 YÖNETİMİ"
 L_START_SVC="Servisi BAŞLAT"; L_STOP_SVC="Servisi DURDUR"
 L_RESTART_SVC="Servisi YENİDEN BAŞLAT"; L_SETTINGS="Ayarlar"
 L_INSTALL_ARIA2="aria2c KUR (opkg)"; L_AUTO_TOGGLE="Otomatik Başlatma KUR/KALDIR"
 L_AUTO_SHORT="Oto bşl"
 L_SVC_NOT_INSTALLED="aria2 kurulu değil. Menü 5'ten aria2c kurabilirsiniz."
 L_SVC_CONF_MISSING="Config dosyası bulunamadı. Varsayılan config oluşturuluyor..."
 L_SVC_ALREADY_RUNNING="aria2 zaten çalışıyor."
 L_SVC_STARTING="aria2 başlatılıyor..."; L_SVC_STARTED="aria2 başlatıldı."
 L_SVC_START_FAIL="aria2 başlatılamadı!"
 L_SVC_LOG_HINT="Log:"; L_SVC_STOPPING="aria2 durduruluyor..."
 L_SVC_STOPPED_OK="aria2 durduruldu."; L_SVC_STOP_FAIL="Durdurulamadı. Zorla kapatılıyor..."
 L_SVC_FORCE_KILLED="Zorla kapatıldı."; L_SVC_NOT_RUNNING="aria2 zaten çalışmıyor."
 L_SVC_RESTARTING="Yeniden başlatılıyor..."; L_SVC_RESTART_OK="Servis yeniden başlatıldı."
 L_SVC_RESTART_FAIL="Servis otomatik başlatılamadı. Menü 1'den başlatın."
 L_INSTALL_TITLE="ARIA2 KURULUM"
 L_ALREADY_INSTALLED="aria2c zaten kurulu, tekrar kuruluma gerek yok."
 L_PKG_UPDATING="Paket listesi güncelleniyor..."; L_PKG_INSTALLING="aria2 kuruluyor..."
 L_INSTALL_OK="aria2 başarıyla kuruldu!"; L_INSTALL_FAIL="Kurulum başarısız! İnternet ve opkg ayarlarını kontrol edin."
 L_POST_INSTALL_TITLE="KURULUM SONRASI OTO YAPILANDIRMA"
 L_POST_INSTALL_MSG="Kurulum sonrası otomatik yapılandırma başlatılıyor..."
 L_CREATING_CONF="Temel yapılandırma dosyası oluşturuluyor..."
 L_SCANNING_USB="USB cihazları taranıyor..."
 L_USB_DETECTED="USB cihaz(lar) algılandı:"
 L_USB_FREE="Boş"; L_USB_TOTAL="Toplam"
 L_USB_USE_Q="İndirme dizini olarak '%s' kullanılsın mı? [E/H]: "
 L_USB_MANUAL="Manuel dizin girin: "
 L_USB_SELECT="Hangi dizini kullanmak istiyorsunuz? (numara, boşsa 1): "
 L_DL_DIR_SET="İndirme dizini:"; L_SETUP_DONE="Temel yapılandırma hazır!"
 L_HINT_SETTINGS="Detaylı ayarlar: Menü 1 -> Ayarlar"
 L_HINT_START="Servisi başlatmak için: Menü 1 -> Servisi BAŞLAT"
 L_CONF_CREATED="Yapılandırma dosyası oluşturuldu:"
 L_USB_TITLE="USB CİHAZ TARAMA"; L_USB_SEARCHING="Bağlı cihazlar aranıyor..."
 L_USB_NONE="Hiçbir USB cihaz bulunamadı."; L_USB_CHECK="USB sürücünüzün takılı ve bağlandığından emin olun."
 L_USB_DETECTED2="Algılanan cihazlar:"; L_USB_USED="Kullanım"
 L_USB_SELECT_NUM="İndirme dizini olarak ayarlamak istediğiniz numara (0 = iptal): "
 L_USB_DIR_SET="İndirme dizini ayarlandı:"; L_USB_RESTART_Q="Servis yeniden başlatılsın mı? [E/H]: "
 L_USB_RESTARTING="Yeniden başlatılıyor..."; L_USB_RESTARTED="Servis yeniden başlatıldı."
 L_INVALID="Geçersiz seçim."
 L_ADD_DL_TITLE="İNDİRME EKLE"; L_ARIA2_NOT_RUNNING="aria2 çalışmıyor. Menü 1 -> Servisi BAŞLAT."
 L_URL_PROMPT="İndirme URL'si: "; L_DIR_PROMPT="Kayıt dizini (boş = varsayılan '%s'): "
 L_DL_QUEUED="İndirme kuyruğa alındı!"; L_DL_GID="GID"; L_DL_FAIL="İndirme eklenemedi."
 L_SERVER_RESP="Sunucu cevabı:"; L_RPC_HINT="RPC ayarlarını ve port numarasını kontrol edin."
 L_DL_LIST_TITLE="İNDİRME LİSTESİ"; L_ACTIVE_DL="AKTİF İNDİRMELER:"
 L_WAITING_DL="BEKLEYEN İNDİRMELER:"; L_COMPLETED_DL="SON TAMAMLANANLAR:"
 L_NO_ACTIVE="(Aktif indirme yok)"; L_NO_WAITING="(Bekleyen indirme yok)"
 L_NO_COMPLETED="(Tamamlanan indirme yok)"; L_PRESS_ENTER="Devam için Enter'a basın..."
 L_SETTINGS_TITLE="AYARLAR MENÜSÜ"; L_SET_DL_DIR="İndirme dizini"
 L_SET_CONCURRENT="Eş zamanlı ind."; L_SET_MAX_CONN="Maks bağlantı/srv"
 L_SET_SPLIT="Parça sayısı"; L_SET_DL_SPEED="İnd. hız limiti"; L_SET_UL_SPEED="Yük. hız limiti"
 L_SET_UNLIMITED="0=sınırsız"; L_SET_RPC="RPC"; L_SET_RPC_SECRET="RPC şifresi"
 L_RPC_SECRET_LABEL="RPC Secret Key"
 L_SET_ALLOC="Dosya tahsis"; L_SET_LOG_LEVEL="Log seviyesi"
 L_SET_CHANGE_DIR="İndirme dizinini değiştir"; L_SET_CONN="Bağlantı ayarları"
 L_SET_SPEED="Hız limiti ayarları"; L_SET_RPC_MENU="RPC ayarları"
 L_SET_ALLOC_MENU="Dosya tahsis yöntemi"; L_SET_LOG_MENU="Log ayarları"
 L_SET_SHOW_CONF="Tüm config dosyasını göster"; L_SET_RESET_CONF="Config sıfırla (varsayılanlara dön)"
 L_SET_BACK="Ana menüye dön"; L_SET_CONFIGURED="AYARLI"; L_SET_EMPTY="[BOŞ]"
 L_CONN_TITLE="BAĞLANTI AYARLARI"; L_CONN_HINT="Değiştirmek istemediğiniz için boş bırakın (Enter)."
 L_CONN_CONCURRENT="Eş zamanlı maks. indirme sayısı"; L_CONN_MAXCONN="Sunucu başına maks. bağlantı (1-16)"
 L_CONN_SPLIT="Dosya başına parça sayısı"; L_CONN_MINSPLIT="Min. parça boyutu (örn: 20M)"
 L_CONN_CACHE="Disk önbellek boyutu (örn: 64M)"; L_CONN_UPDATED="Bağlantı ayarları güncellendi."
 L_SPEED_TITLE="HIZ LİMİTİ AYARLARI"; L_SPEED_HINT="0 = Sınırsız"
 L_SPEED_EXAMPLE="Örnek: 1M = 1 MB/s | 512K = 512 KB/s"
 L_SPEED_DL="İndirme hız limiti"; L_SPEED_UL="Yükleme hız limiti"
 L_SPEED_UPDATED="Hız limitleri güncellendi."
 L_RPC_TITLE="RPC AYARLARI"; L_RPC_HINT2="RPC; AriaNg, webui-aria2 gibi arayüzlerle bağlantı sağlar."
 L_RPC_ENABLE="RPC aktif mi? (true/false)"; L_RPC_PORT2="RPC port numarası"
 L_RPC_SECRET2="RPC şifresi (boş bırak = şifresiz)"; L_RPC_ALL="Tüm ağ arayüzlerinden erişim (true/false)"
 L_RPC_ORIGIN="Tüm origin'lere izin ver (true/false)"; L_RPC_UPDATED="RPC ayarları güncellendi."
 L_ALLOC_TITLE="DOSYA TAHSİS YÖNTEMİ"
 L_ALLOC_NONE="Tahsis yok (en hızlı başlangıç)"
 L_ALLOC_PREALLOC="Ön tahsis (FAT32 önerilir)"
 L_ALLOC_FALLOC="Hızlı tahsis (ext4/NTFS önerilir)"
 L_ALLOC_TRUNC="Kırpma yöntemi"; L_ALLOC_CURRENT="Mevcut"
 L_ALLOC_PROMPT="Seçiminiz [1-4, boş geç]: "; L_ALLOC_NOCHANGE="Değişiklik yapılmadı."
 L_LOG_TITLE="LOG AYARLARI"; L_LOG_PATH="Log dosyası yolu"; L_LOG_LEVEL2="Log seviyesi"
 L_LOG_LEVELS="1) debug 2) info 3) notice 4) warn 5) error"
 L_LOG_UPDATED="Log ayarları güncellendi."
 L_CONF_FILE="CONFIG DOSYASI"; L_CONF_NOT_FOUND="Config dosyası bulunamadı."
 L_CONF_RESET_Q="Config sıfırlansın mı? Tüm ayarlar kaybolur! [E/H]: "
 L_CURRENT="mevcut"; L_BLANK_SKIP="boş geç"; L_CHOICE_PROMPT="Seçiminiz"
 L_CONF_HEADER="Keenetic Aria2 Manager - Yapılandırma"
 L_UPDATE_TITLE="GÜNCELLEME KONTROLÜ"; L_UPDATE_CONNECTING="GitHub sunucusuna bağlanılıyor..."
 L_UPDATE_FAIL="Güncelleme sunucusuna ulaşılamadı."; L_UPDATE_CHECK_URL="Kontrol edilen adres:"
 L_UPDATE_NO_VER="İndirilen dosyada sürüm bilgisi bulunamadı."
 L_UPDATE_CURR="Mevcut sürüm"; L_UPDATE_REMOTE="GitHub sürümü"
 L_UPDATE_AVAIL="Yeni sürüm mevcut!"; L_UPDATE_Q="Güncellemek ister misiniz? [E/H]: "
 L_UPDATE_IN_PROGRESS="Güncelleniyor..."; L_UPDATE_STOPPING="Servis durduruluyor..."
 L_UPDATE_DONE="Dosya güncellendi:"; L_UPDATE_RESTARTING="Servis yeniden başlatılıyor..."
 L_UPDATE_RESTART_OK="Servis yeniden başlatıldı."
 L_UPDATE_RESTART_FAIL="Servis otomatik başlatılamadı. Menü 1'den başlatın."
 L_UPDATE_LATEST="Zaten en güncel sürümü kullanıyorsunuz"; L_UPDATE_CANCEL="Güncelleme iptal edildi."
 # === HEADER EKSTRA ===
 L_HDR_SYSTEM="Sistem"
 L_HDR_UPTIME="Çalışma Süresi"
 L_HDR_DISK_FREE="Disk Boş"
 L_HDR_ACTIVE_DL="Aktif İndirme"
 L_HDR_ACTIVE_DL_SVC_DOWN="Servis kapalı"
 L_HDR_ACTIVE_DL_NONE="İndirme yok"
 L_HDR_TELEGRAM="Telegram"
 L_HDR_GITHUB="GitHub"
 L_HDR_RAM="RAM Boş"
 L_HDR_WAN_IP="WAN IP"
 L_HDR_OS_VER="KeeneticOS"
 L_HDR_LOAD="CPU Yük"
 L_HDR_DL_SPEED="İnd. Hızı"
 L_HDR_ABOUT="HAKKINDA"
 L_HDR_FEATURES="ÖZELLİKLER"
 # === SAĞLIK MENÜSÜ ===
 L_HEALTH_MENU="Sistem Sağlığı"
 L_HEALTH_TITLE="SİSTEM SAĞLIK KONTROLÜ"
 L_HEALTH_SEC_CPU="CPU & YÜK"
 L_HEALTH_SEC_RAM="BELLEK"
 L_HEALTH_SEC_DISK="DEPOLAMA"
 L_HEALTH_SEC_NET="AĞ"
 L_HEALTH_SEC_PROC="SÜREÇLER"
 L_HEALTH_SEC_ARIA2="ARIA2"
 L_HEALTH_CPU_USAGE="CPU Kullanımı"
 L_HEALTH_LOAD_1="Yük 1dk"
 L_HEALTH_LOAD_5="Yük 5dk"
 L_HEALTH_LOAD_15="Yük 15dk"
 L_HEALTH_TEMP="Sıcaklık"
 L_HEALTH_RAM_USED="RAM Kullanılan"
 L_HEALTH_RAM_FREE="RAM Boş"
 L_HEALTH_RAM_TOTAL="RAM Toplam"
 L_HEALTH_RAM_BUFCACHE="Buf/Önbellek"
 L_HEALTH_SWAP_USED="Swap Kullanılan"
 L_HEALTH_SWAP_TOTAL="Swap Toplam"
 L_HEALTH_WAN_IP="WAN IP"
 L_HEALTH_LAN_IP="LAN IP"
 L_HEALTH_DNS_PING="DNS Ping"
 L_HEALTH_GW_PING="Ağ Geçidi Ping"
 L_HEALTH_RX="Alınan Toplam"
 L_HEALTH_TX="Gönderilen Toplam"
 L_HEALTH_CONN="Aktif Bağlantı"
 L_HEALTH_PROC_COUNT="Süreç Sayısı"
 L_HEALTH_ARIA2_PID="aria2 PID"
 L_HEALTH_ARIA2_RSS="aria2 RAM"
 L_HEALTH_ARIA2_ACTIVE="Aktif İndirme"
 L_HEALTH_ARIA2_WAITING="Bekleyen İndirme"
 L_HEALTH_ARIA2_STOPPED="Son İndirmeler"
 L_HEALTH_ARIA2_SPEED="İndirme Hızı"
 L_HEALTH_ARIA2_UPSPEED="Yükleme Hızı"
 L_HEALTH_ARIA2_SESSIONS="Oturum Dosyası"
 L_HEALTH_REFRESHING="Yenileniyor..."
 L_HEALTH_AUTO_REF="Otomatik yenileme (5sn) — durdurmak için bir tuşa basın"
 L_HEALTH_PRESS_R=" R) Yenile A) Oto-yenile 0) Geri"
 L_HEALTH_OK="TAMAM"
 L_HEALTH_WARN="UYARI"
 L_HEALTH_CRIT="KRİTİK"
 L_HEALTH_NA="Yok"
 L_HEALTH_MS="ms"
 L_HEALTH_TIMEOUT="zaman aşımı"
 L_HDR_DESC1="Keenetic routerlar için aria2 indirme yöneticisi"
 L_HDR_DESC2="RPC ile indirme ekle | AriaNg WebUI | Hız sınırı"
 L_HDR_DESC3="Telegram bildirimleri | Oto başlama | USB disk yönetimi"
 L_HDR_FEAT1="Çok bağlantılı paralel indirme (split/segment desteği)"
 L_HDR_FEAT2="AriaNg WebUI — indirmeleri tarayıcıdan yönet"
 L_HDR_FEAT3="Her indirme olayı için Telegram bildirimleri"
 L_HDR_FEAT4="USB disk otomatik algılama ve indirme dizini kurulumu"
 # === TANI MENÜSÜ ===
 L_DIAG_MENU="Tanı & Test"
 L_HELP_MENU="Yardım & Kullanım Kılavuzu"
 L_DIAG_TITLE="TANI VE GEREKSİNİMLER"
 L_DIAG_SEC_CORE="── TEMEL GEREKSİNİMLER ──"
 L_DIAG_SEC_OPT="── OPSİYONEL BİLEŞENLER ──"
 L_DIAG_SEC_UPDATE="── GÜNCELLEME KONTROLÜ ──"
 L_DIAG_SEC_FUNC="── ÖZELLİK TESTLERİ ──"
 L_DIAG_OK="TAMAM"
 L_DIAG_FAIL="EKSİK"
 L_DIAG_WARN="UYARI"
 L_DIAG_RUNNING="ÇALIŞIYOR"
 L_DIAG_STOPPED="KAPALI"
 L_DIAG_ACTIVE="AKTİF"
 L_DIAG_INACTIVE="PASİF"
 L_DIAG_OPTIONAL="opsiyonel"
 L_DIAG_NOT_INSTALLED="Kurulmadı"
 L_DIAG_INSTALLED="Kurulu"
 L_DIAG_CONF_OK="Config TAMAM"
 L_DIAG_CONF_MISS="Config EKSİK"
 L_DIAG_SESSION_OK="Oturum dosyası TAMAM"
 L_DIAG_SESSION_MISS="Oturum dosyası eksik"
 L_DIAG_LOGDIR_OK="Log dizini TAMAM"
 L_DIAG_LOGDIR_MISS="Log dizini eksik"
 L_DIAG_RPC_OK="RPC yanıt veriyor"
 L_DIAG_RPC_FAIL="RPC yanıt vermiyor"
 L_DIAG_RPC_DISABLED="Config'de RPC devre dışı"
 L_DIAG_DL_DIR_OK="İndirme dizini mevcut"
 L_DIAG_DL_DIR_MISS="İndirme dizini EKSİK"
 L_DIAG_DL_DIR_NOTSET="İndirme dizini ayarlanmamış"
 L_DIAG_AUTOSTART_ON="Oto başlatma etkin"
 L_DIAG_AUTOSTART_OFF="Oto başlatma pasif"
 L_DIAG_TG_ENABLED="Telegram ETKİN"
 L_DIAG_TG_DISABLED="Telegram pasif"
 L_DIAG_TG_NO_TOKEN="Token ayarlanmamış!"
 L_DIAG_TG_NO_CHAT="Chat ID ayarlanmamış!"
 L_DIAG_CURL_OK="curl kurulu"
 L_DIAG_CURL_MISS="curl EKSİK — RPC/Telegram/Güncelleme için gerekli"
 L_DIAG_OPKG_OK="opkg mevcut"
 L_DIAG_OPKG_MISS="opkg bulunamadı"
 L_DIAG_ENTWARE_OK="Entware /opt TAMAM"
 L_DIAG_ENTWARE_MISS="Entware /opt EKSİK"
 L_DIAG_ARIANG_RUNNING="AriaNg çalışıyor"
 L_DIAG_ARIANG_STOPPED="AriaNg durdu"
 L_DIAG_ARIANG_NOT_INST="Kurulmadı"
 L_DIAG_LIGHTTPD_OK="lighttpd kurulu"
 L_DIAG_LIGHTTPD_MISS="lighttpd kurulmadı"
 L_DIAG_UPDATE_MGR="Manager betiği"
 L_DIAG_UPDATE_ARIA2="aria2c binary"
 L_DIAG_UPDATE_CHECKING="Kontrol ediliyor..."
 L_DIAG_UPDATE_LATEST="Güncel"
 L_DIAG_UPDATE_AVAIL="Güncelleme mevcut"
 L_DIAG_UPDATE_FAIL="Kontrol edilemedi"
 L_DIAG_SUMMARY="ÖZET"
 L_DIAG_ALL_OK="Tüm temel gereksinimler karşılandı."
 L_DIAG_ISSUES="Sorun/eksik bulundu:"
 L_DIAG_PRESS_R=" R) Yenile F) Sorunları gider 0) Geri"
 L_DIAG_FIX_TITLE="EKSİKLERİ GİDER / KUR"
 L_DIAG_FIX_ARIA2="aria2c kur"
 L_DIAG_FIX_CONF="Varsayılan config oluştur"
 L_DIAG_FIX_SESSION="Oturum dosyasını oluştur"
 L_DIAG_FIX_LOGDIR="Log dizinini oluştur"
 L_DIAG_FIX_DLDIR="İndirme dizini ayarla"
 L_DIAG_FIX_CURL="curl kur"
 L_DIAG_FIX_AUTOSTART="Oto başlatmayı etkinleştir"
 L_DIAG_FIX_NOTHING="Giderilebilecek sorun yok — her şey TAMAM!"
 L_DIAG_FIX_DONE="Düzeltme tamamlandı."
 # tanı etiket stringleri
 L_DIAG_LBL_LOGDIR="Log dizini"
 L_DIAG_LBL_DLDIR="İndirme dizini"
 L_DIAG_LBL_SERVICE="aria2c servisi"
 L_DIAG_LBL_AUTOSTART="Oto başlatma"
 L_DIAG_LBL_USB="USB disk"
 L_DIAG_LBL_RPC_TEST="RPC fonksiyon testi"
 L_DIAG_LBL_INTERNET="İnternet"
 L_DIAG_LBL_TGHOOKS="Telegram hook'ları"
 L_DIAG_D_OPTBIN="/opt/bin mevcut"
 L_DIAG_D_OPTNO="var ama opkg yok"
 L_DIAG_D_RPCSVCDOWN="etkin (servis kapalı)"
 L_DIAG_D_FREE="Boş"
 L_DIAG_D_DISKS="disk bağlı"
 L_DIAG_D_NODISK="Takılı USB disk bulunamadı"
 L_DIAG_D_ACTIVE="Aktif"
 L_DIAG_D_WAITING="Bekleyen"
 L_DIAG_D_NORPC="getGlobalStat yanıt vermedi"
 L_DIAG_D_SVCRPC="Servis kapalı veya RPC devre dışı"
 L_DIAG_D_GITHUB="github.com erişilebilir"
 L_DIAG_D_CFONE="1.1.1.1 erişilebilir"
 L_DIAG_D_NOINET="Bağlantı yok / GitHub erişilemiyor"
 L_DIAG_D_HOOKSOK="tg_notify.sh + on_complete + on_error"
 L_DIAG_D_HOOKSMISS="Bazı hook dosyaları eksik (servis başlatınca oluşur)"
 L_DIAG_D_GHVER="GitHub'dan sürüm okunamadı"
 L_DIAG_D_LOCAL="Yerel"
 L_DIAG_D_NEW="Yeni"
 L_DIAG_D_NOSERVER="Sunucuya ulaşılamadı"
 L_DIAG_D_INSTALLED="Kurulu"
 L_DIAG_D_AVAILPKG="Mevcut"
 L_DIAG_D_OPKGFAIL="opkg'den bilgi alınamadı"
 L_DIAG_D_MENU1="Menü 1 → Kur"
 L_DIAG_D_FIXDIR="İndirme dizini girin: "
 L_UNINSTALL_1="Çalışan aria2 servisini durdurur"
 L_UNINSTALL_2="init.d otomatik başlatma dosyasını siler"
 L_UNINSTALL_3="Kısayolları (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2) kaldırır"
 L_UNINSTALL_4="Bu manager betiğini siler"
 L_UNINSTALL_KEEP="Config dosyaları ve indirilen dosyalara dokunulmaz!"
 L_UNINSTALL_CONFIRM="Devam etmek için EVET yazın (iptal için boş bırakın): "
 L_UNINSTALL_STOPPING="Servis durduruluyor..."; L_UNINSTALL_DONE="Manager kaldırıldı."
 L_UNINSTALL_CONF_KEPT="Config dosyaları şu konumda:"; L_UNINSTALL_CANCEL="İşlem iptal edildi."
 L_UNINSTALL_CONFIRM_WORD="EVET"
 L_AUTO_INSTALLED="Otomatik başlatma kurulu. Kaldırılsın mı? [E/H]: "
 L_AUTO_REMOVED="Otomatik başlatma kaldırıldı."; L_AUTO_INSTALLED_OK="Otomatik başlatma kuruldu:"
 L_LOCK_MSG="Betik zaten çalışıyor gibi görünüyor (lock dosyası mevcut)."
 L_LOCK_PID="Önceki oturum PID:"; L_LOCK_PID_DEAD="(process çalışmıyor)"
 L_LOCK_Q="Yeni oturum başlatmak ister misiniz? [E/H]: "; L_LOCK_CLEARED="Lock temizlendi, başlatılıyor..."
 L_LOCK_EXIT="Çıkılıyor."
 L_LANG_TITLE="DİL / LANGUAGE"; L_LANG_CURRENT="Mevcut dil:"
 L_LANG_SELECT="Dil seçin:"; L_LANG_TR="Türkçe"; L_LANG_EN="English"; L_LANG_RU="Русский"
 L_LANG_CHANGED="Dil değiştirildi."; L_LANG_BACK="Geri"
 L_CONFIRM_YES="E"; L_CONFIRM_YES2="e"
 # === TELEGRAM ===
 L_TG_MENU="Telegram Bildirimleri"
 L_TG_TITLE="TELEGRAM BİLDİRİMLERİ"
 L_TG_STATUS="Durum"; L_TG_ENABLED_STATUS="AKTİF"; L_TG_DISABLED_STATUS="PASİF"
 L_TG_TOKEN="Bot Token"; L_TG_CHAT="Chat ID"; L_TG_NOT_SET="[AYARLANMAMIŞ]"
 L_TG_NOTIFICATIONS="Aktif Bildirimler"
 L_TG_OPT_TOKEN="Bot Token Ayarla"; L_TG_OPT_CHAT="Chat ID Ayarla"
 L_TG_OPT_TOGGLE="Telegram AKTİF / PASİF"; L_TG_OPT_NOTIFY="Bildirim Ayarları"
        L_TG_ABOUT_TITLE="HAKKINDA"
        L_TG_ABOUT_DESC="Telegram bildirimleri, her indirme olayında otomatik mesaj gönderir."
        L_TG_ABOUT_CURL="Bildirimlerin çalışabilmesi için curl gereklidir."
        L_TG_ABOUT_AUTO="Telegram hizmeti ilk çalıştırmada curl bileşenini otomatik yükler."
        L_TG_ABOUT_MANUAL="Manuel yüklemek isterseniz menü 5'ten yükleyebilirsiniz."
 L_TG_OPT_TEST="Test Mesajı Gönder"; L_TG_OPT_BACK="Ana Menüye Dön"
 L_TG_TOKEN_PROMPT="Bot Token girin (iptal için boş bırakın): "
 L_TG_TOKEN_SAVED="Bot Token kaydedildi."
 L_TG_CHAT_PROMPT="Chat ID girin (iptal için boş bırakın): "
 L_TG_CHAT_SAVED="Chat ID kaydedildi."
 L_TG_TOGGLED_ON="Telegram bildirimleri AKTİF edildi."
 L_TG_TOGGLED_OFF="Telegram bildirimleri PASİF edildi."
 L_TG_NEED_TOKEN="Önce Bot Token ve Chat ID ayarlanmalı!"
 L_TG_TEST_SENDING="Test mesajı gönderiliyor..."
 L_TG_TEST_OK="Test mesajı başarıyla gönderildi!"
 L_TG_TEST_FAIL="Gönderilemedi. Token ve Chat ID'yi kontrol edin."
 L_TG_NOTIFY_TITLE="BİLDİRİM AYARLARI"
 L_TG_N_SVC_START="Servis başladı"; L_TG_N_SVC_STOP="Servis durdu"
 L_TG_N_DL_ADD="İndirme eklendi"; L_TG_N_DL_COMPLETE="İndirme tamamlandı"
 L_TG_N_DL_ERROR="İndirme hatası"; L_TG_N_DL_STOP="İndirme durduruldu/iptal"
 L_TG_N_ON="AÇIK"; L_TG_N_OFF="KAPALI"; L_TG_N_SAVED="Bildirim tercihleri kaydedildi."
 L_TG_MSG_SVC_START="✅ aria2 servisi başlatıldı"
 L_TG_MSG_SVC_STOP="⏹ aria2 servisi durduruldu"
 L_TG_MSG_DL_ADD="➕ İndirme eklendi"
 L_TG_MSG_DL_COMPLETE="✅ İndirme tamamlandı"
 L_TG_MSG_DL_ERROR="❌ İndirme hatası"
 L_TG_MSG_DL_STOP="⏸ İndirme durduruldu"
 L_TG_MSG_TEST="🔔 Keenetic Aria2 Manager - Test bildirimi"
 L_TG_MSG_SECRET_KEY="🔑 RPC Secret Key güncellendi"
 L_TG_N_WEBUI_START="WebUI başladı"; L_TG_N_WEBUI_STOP="WebUI durdu"
 L_TG_N_SECRET_KEY="RPC Secret Key değişti"
 L_TG_N_BACKUP_CREATED="Yedek alındı"
 L_TG_N_BACKUP_DELETED="Yedek silindi"
 L_TG_N_BACKUP_RESTORED="Yedek geri yüklendi"
 L_TG_MSG_BACKUP_CREATED="💾 Yedek alındı"
 L_TG_MSG_BACKUP_DELETED="🗑 Yedek silindi"
 L_TG_MSG_BACKUP_RESTORED="♻️ Yedek geri yüklendi"
 L_TG_MSG_WEBUI_START="🖥️ AriaNg WebUI başlatıldı"
 L_TG_MSG_WEBUI_STOP="⏹ AriaNg WebUI durduruldu"
 L_TG_CURL_LABEL="Gerekli bileşen"
 L_TG_CURL_OK="YÜKLÜ"
 L_TG_CURL_MISSING="EKSİK"
 L_TG_CURL_INSTALL_Q="Telegram bildirimleri için curl gerekli. Şimdi kurulsun mu? [E/H]: "
 L_TG_OPT_CURL="Curl Yükle"
 # === HEADER YENİ ===
 L_SELECTED_DISK="Seçili Disk"; L_DL_LOCATION="İndirme Konumu"
 L_DISK_NOT_SET="[AYARLANMAMIŞ]"
 # === KLASÖR SEÇİMİ ===
 L_FOLDER_DEFAULT_INFO="Varsayılan: Disk üzerinde /aria2/downloads klasörü oluşturulacak."
 L_FOLDER_CHANGE_Q="Klasörü değiştirmek ister misiniz? [E/H]: "
 L_FOLDER_PROMPT="Alt klasör adı girin (örn: downloads, medya): "
 L_FOLDER_CUSTOM_SET="Özel klasör ayarlandı:"
 L_FOLDER_DEFAULT_SET="Varsayılan klasör ayarlandı:"
 # === TAM KALDIRMA ===
 L_FULL_UNINSTALL_TITLE="TAM KALDIRMA"
 L_FULL_UNINSTALL_INFO="Bu işlem tamamen kaldırır:"
 L_FULL_UNINSTALL_1="aria2 servisi (durdurulur + opkg ile kaldırılır)"
 L_FULL_UNINSTALL_2="Tüm config dosyaları ve loglar"
 L_FULL_UNINSTALL_3="Otomatik başlatma dosyası (init.d)"
 L_FULL_UNINSTALL_4="Kısayollar (aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)"
 L_FULL_UNINSTALL_5="Bu manager betiği"
 L_FULL_UNINSTALL_6="AriaNg WebUI (dosyalar + lighttpd config + oto başlatma)"
 L_FULL_UNINSTALL_DL_Q="İndirme klasörünüz:"
 L_FULL_UNINSTALL_DL_DEL="İndirilen dosyalar da silinsin mi? [E/H]: "
 L_FULL_UNINSTALL_DL_KEEP="İndirilen dosyalar korunacak."
 L_FULL_UNINSTALL_DL_DELETING="İndirilenler siliniyor..."
 L_FULL_UNINSTALL_DL_DELETED="İndirilenler silindi."
 L_FULL_UNINSTALL_CONFIRM="Tam kaldırmayı onaylamak için SİL yazın: "
 L_FULL_UNINSTALL_CONFIRM_WORD="SİL"
 L_FULL_UNINSTALL_STOPPING="aria2 servisi durduruluyor..."
 L_FULL_UNINSTALL_REMOVING_PKG="aria2 paketi opkg ile kaldırılıyor..."
 L_FULL_UNINSTALL_PKG_DONE="aria2 paketi kaldırıldı."
 L_FULL_UNINSTALL_PKG_FAIL="opkg remove başarısız (zaten kaldırılmış olabilir)."
 L_FULL_UNINSTALL_CONF="Config dosyaları ve loglar siliniyor..."
 L_FULL_UNINSTALL_DONE="Tam kaldırma tamamlandı. Sistem temiz."
 L_FULL_UNINSTALL_CANCEL="Kaldırma iptal edildi."
 L_FULL_UNINSTALL_ARIANG="AriaNg WebUI kaldırılıyor..."
 L_FULL_UNINSTALL_ARIANG_STOP="AriaNg durduruluyor (lighttpd)..."
 L_FULL_UNINSTALL_ARIANG_HTML="AriaNg HTML dosyaları siliniyor:"
 L_FULL_UNINSTALL_ARIANG_CONF="lighttpd config siliniyor:"
 L_FULL_UNINSTALL_ARIANG_INIT="AriaNg oto başlatma siliniyor:"
 L_FULL_UNINSTALL_ARIANG_PKG="lighttpd paketi opkg ile kaldırılıyor..."
 L_FULL_UNINSTALL_ARIANG_DONE="AriaNg kaldırıldı."
 L_FULL_UNINSTALL_ARIANG_SKIP="AriaNg kurulu değil, atlanıyor."
 L_FULL_UNINSTALL_RESIDUAL="Artık dosya ve dizinler temizleniyor..."
 L_FULL_UNINSTALL_RESIDUAL_DONE="Artık dosyalar temizlendi."
 # === ARIA2 SADECE KALDIR ===
 L_ARIA2_ONLY_TITLE="ARİA2'Yİ KALDIR (MANAGER'DAN BAĞIMSIZ)"
 L_ARIA2_ONLY_INFO="Bu işlem aria2 ve tüm dosyalarını tamamen kaldırır:"
 L_ARIA2_ONLY_1="aria2 servisi (durdurulur + opkg ile kaldırılır)"
 L_ARIA2_ONLY_2="Tüm aria2 config dosyaları, loglar ve session"
 L_ARIA2_ONLY_3="Otomatik başlatma dosyası (init.d)"
 L_ARIA2_ONLY_4="AriaNg WebUI (kuruluysa)"
 L_ARIA2_ONLY_5="Tüm aria2 artık dosyaları ve opkg bilgi dosyaları"
 L_ARIA2_ONLY_KEEP="Manager betiği ve kısayollar SİLİNMEZ."
 L_ARIA2_ONLY_DL_Q="İndirme klasörünüz:"
 L_ARIA2_ONLY_DL_DEL="İndirilen dosyalar da silinsin mi? [E/H]: "
 L_ARIA2_ONLY_DL_KEEP="İndirilen dosyalar korunacak."
 L_ARIA2_ONLY_DL_DELETING="İndirilenler siliniyor..."
 L_ARIA2_ONLY_DL_DELETED="İndirilenler silindi."
 L_ARIA2_ONLY_CONFIRM="aria2 kaldırımını onaylamak için SİL yazın: "
 L_ARIA2_ONLY_CONFIRM_WORD="SİL"
 L_ARIA2_ONLY_CANCEL="Kaldırma iptal edildi."
 L_ARIA2_ONLY_DONE="aria2 ve tüm dosyaları kaldırıldı. Manager hâlâ aktif."
 # === ARIA2 GÜNCELLEME ===
 L_ARIA2_UPDATE="aria2c Güncelle"
 L_ARIANG_MENU="AriaNg Web Arayüzü"
 L_ARIANG_TITLE="ARIANG WEB ARAYÜZÜ"
 L_ARIANG_STATUS="Durum"; L_ARIANG_INSTALL="AriaNg Kur"
 L_ARIANG_UNINSTALL="AriaNg Kaldır"; L_ARIANG_START="Web UI Başlat"
 L_ARIANG_STOP="Web UI Durdur"; L_ARIANG_BACK="Geri"
 L_ARIANG_RUNNING="ÇALIŞIYOR"; L_ARIANG_STOPPED="KAPALI"
 L_ARIANG_INSTALLED="KURULU"; L_ARIANG_NOT_INSTALLED="KURULU DEĞİL"
 L_ARIANG_INSTALL_OK="AriaNg kuruldu! Tarayıcıdan açın:"
 L_ARIANG_INSTALL_FAIL="Kurulum başarısız!"
 L_ARIANG_UNINSTALLING="AriaNg kaldırılıyor..."; L_ARIANG_UNINSTALL_OK="AriaNg kaldırıldı."
 L_ARIANG_STARTING="Web sunucusu başlatılıyor..."; L_ARIANG_START_OK="Web sunucusu başlatıldı."
 L_ARIANG_START_FAIL="Web sunucusu başlatılamadı!"
 L_ARIANG_STOPPING="Web sunucusu durduruluyor..."; L_ARIANG_STOP_OK="Web sunucusu durduruldu."
 L_ARIANG_NOT_INST_ERR="AriaNg kurulu değil. Kurulum seçeneğini kullanın."
 L_ARIANG_URL_LABEL="AriaNg URL"; L_ARIANG_PORT="Web UI portu"
 L_ARIANG_LIGHTTPD_INST="lighttpd kuruluyor..."; L_ARIANG_LIGHTTPD_FAIL="lighttpd kurulamadı!"
 L_ARIANG_WRITING="AriaNg dosyaları yazılıyor..."; L_ARIANG_CONFIRM_UNINST="AriaNg kaldırılsın mı? [E/H]: "
 L_ARIA2_UPDATE_TITLE="ARIA2 GÜNCELLEME"
 L_ARIA2_UPDATE_CHECKING="aria2 güncellemeleri kontrol ediliyor..."
 L_ARIA2_UPDATE_CURR="Kurulu:"
 L_ARIA2_UPDATE_AVAIL="Mevcut:"
 L_ARIA2_UPDATE_LATEST="aria2 zaten güncel."
 L_ARIA2_UPDATE_FOUND="Yeni sürüm mevcut!"
 L_ARIA2_UPDATE_Q="aria2 şimdi güncellensin mi? [E/H]: "
 L_ARIA2_UPDATE_STOPPING="Güncelleme öncesi servis durduruluyor..."
 L_ARIA2_UPDATE_IN_PROGRESS="aria2 güncelleniyor..."
 L_ARIA2_UPDATE_DONE="aria2 başarıyla güncellendi!"
 L_ARIA2_UPDATE_FAIL="Güncelleme başarısız!"
 L_ARIA2_UPDATE_RESTARTING="Servis yeniden başlatılıyor..."
 L_ARIA2_UPDATE_NOT_INSTALLED="aria2 kurulu değil. Kur seçeneğini kullanın."
 L_ARIA2_UPDATE_NO_INFO="opkg'den sürüm bilgisi alınamadı."
 L_ARIA2_UPDATE_CANCEL="Güncelleme iptal edildi."
 # === BAĞIMLILIK ÇAKIŞMA KONTROLÜ ===
 L_DEP_CONFLICT_TITLE="Ortak bağımlılık tespit edildi"
 L_DEP_CONFLICT_INFO="Bu paketi kullanan diğer betik / paketler:"
 L_DEP_CONFLICT_OPT="Ne yapmak istiyorsunuz?"
 L_DEP_SKIP="Paketi koru (silme)"
 L_DEP_FORCE="Yine de zorla kaldır (diğer betikler bozulabilir!)"
 L_DEP_RECOMMENDED="Önerilen"
 L_DEP_SKIPPED="Korundu — silinmedi"
 L_DEP_OPKG_RDEPS="Buna bağımlı yüklü paketler (opkg)"
 L_DEP_SCAN_INFO="Çakışmalar taranıyor..."
 L_DEP_NO_CONFLICT="Çakışma bulunamadı. Kaldırmak güvenli."
 L_FULL_UNINSTALL_CURL="curl paketi (çakışma kontrolü)..."
 L_FULL_UNINSTALL_CURL_SKIP="curl kurulu değil, atlanıyor."
 fi
}

load_lang

# ============================================
# YARDIMCI FONKSİYONLAR / HELPERS
# ============================================
create_shortcuts() {
 # /opt/bin yoksa oluştur
 [ -d "/opt/bin" ] || mkdir -p "/opt/bin" 2>/dev/null
 for cmd in aria2m a2m soulsaria2 k2m kam keeneticaria2 aria2manager; do
 local _link="/opt/bin/$cmd"
 # Symlink yoksa, var ama yanlış hedefe işaret ediyorsa → yeniden oluştur
 if [ ! -L "$_link" ] || [ "$(readlink "$_link" 2>/dev/null)" != "$SCRIPT_PATH" ]; then
 ln -sf "$SCRIPT_PATH" "$_link" 2>/dev/null
 fi
 done
}

gen_rpc_secret() {
 # 24 karakterlik rastgele alfanumerik şifre üretir.
 # Kaynak sırasıyla: /dev/urandom → openssl → date+hash fallback
 local _s=""
 if [ -r /dev/urandom ]; then
 _s=$(cat /dev/urandom 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 24 2>/dev/null)
 fi
 [ -z "$_s" ] && command -v openssl >/dev/null 2>&1 && \
 _s=$(openssl rand -base64 18 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 24)
 [ -z "$_s" ] && _s=$(date +%s%N 2>/dev/null | sha256sum 2>/dev/null | head -c 24)
 [ -z "$_s" ] && _s=$(date +%s | head -c 24)
 echo "$_s"
}


conf_get() {
 KEY="$1"
 [ -f "$ARIA2_CONF" ] && grep -m1 "^${KEY}=" "$ARIA2_CONF" 2>/dev/null | cut -d'=' -f2-
}

conf_set() {
 KEY="$1"; VAL="$2"
 if [ -f "$ARIA2_CONF" ]; then
 if grep -q "^${KEY}=" "$ARIA2_CONF" 2>/dev/null; then
 sed -i "s|^${KEY}=.*|${KEY}=${VAL}|" "$ARIA2_CONF"
 else
 echo "${KEY}=${VAL}" >> "$ARIA2_CONF"
 fi
 else
 echo "${KEY}=${VAL}" >> "$ARIA2_CONF"
 fi
}

status_check() {
 # pidof önce — PID dosyası stale olabilir, gerçek process'i sorgula
 pidof aria2c >/dev/null 2>&1 && return 0
 if [ -f "$PID_FILE" ]; then
 PID=$(cat "$PID_FILE" 2>/dev/null)
 [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null && return 0
 fi
 return 1
}

aria2_installed() {
 # 1. Binary PATH'te ve gerçek dosya mı? ([ -s ] ile 0-byte ghost'u da yakalar)
 local _bin
 _bin=$(command -v aria2c 2>/dev/null) || return 1
 [ -n "$_bin" ] && [ -x "$_bin" ] && [ -s "$_bin" ] || return 1
 # 2. opkg bilgi dosyası da var mı? (opkg remove sonrası temizlenir)
 # Eğer opkg mevcut değilse (ör. Entware kurulmamış), sadece binary kontrolüne güven.
 if command -v opkg >/dev/null 2>&1; then
 opkg status aria2 2>/dev/null | grep -q '^Status:.*installed' || return 1
 fi
 return 0
}

aria2_version() {
 # aria2_installed true ise versiyon string döner, aksi hâlde boş.
 aria2_installed || return
 aria2c --version 2>/dev/null | head -1 | awk '{print $3}'
}

detect_usb() {
 USB_LIST=""
 for mount_point in /tmp/mnt/* /mnt/* /media/*; do
 [ -d "$mount_point" ] || continue
 mount 2>/dev/null | grep -q " $mount_point " && USB_LIST="$USB_LIST $mount_point"
 done
 echo "$USB_LIST"
}

yes_answer() {
 ANS="$1"
 [ "$ANS" = "$L_CONFIRM_YES" ] || [ "$ANS" = "$L_CONFIRM_YES2" ] || [ -z "$ANS" ]
}

# ============================================
# UTF-8 HIZALAMA YARDIMCI FONKSİYONU / UTF-8 ALIGNMENT HELPER
# ============================================
# pad_label STR WIDTH
# printf "%-Ns" byte sayısına göre hizalar; UTF-8 çok-byte karakterler
# (ş,ğ,ü,ç,ö,İ vb.) terminalde 1 sütun yer kaplamasına rağmen 2 byte
# tükettiğinden hizalama bozulur. Bu fonksiyon ekstra byte sayısını
# tespit edip genişliği düzelterek doğru görsel hizalamayı sağlar.
pad_label() {
 local _str="$1"
 local _width="$2"
 # UTF-8 devam byte'ları (0x80-0xBF = oktal \200-\277) görsel genişliğe
 # katkı yapmaz ama byte sayısını artırır. Bu byte'ları silince kalan
 # byte sayısı = terminalde görünen karakter sayısı.
 local _bytes _chars _extra
 _bytes=$(printf '%s' "$_str" | wc -c)
 _chars=$(printf '%s' "$_str" | tr -d '\200-\277' | wc -c)
 _extra=$(( _bytes - _chars ))
 [ "$_extra" -lt 0 ] && _extra=0
 printf "%-$(( _width + _extra ))s" "$_str"
}

# ============================================
# BAĞIMLILIK ÇAKIŞMA KONTROLÜ / DEP CONFLICT CHECK
# ============================================
# _dep_find_users PKG_ADI
# Sistemde bu paketi kullanan diğer betik/paketleri bulur.
# Boş string → çakışma yok; doluysa → çakışan dosya listesi (newline'lı)
_dep_find_users() {
 _PKG="$1"
 _SELF_BASE="$(basename "$SCRIPT_PATH")"
 _FOUND=""

 # /opt/lib/opkg/ altındaki diğer manager betikleri
 for _f in /opt/lib/opkg/*.sh; do
 [ -f "$_f" ] || continue
 [ "$(basename "$_f")" = "$_SELF_BASE" ] && continue
 grep -qi "$_PKG" "$_f" 2>/dev/null && _FOUND="${_FOUND} • $(basename "$_f") [/opt/lib/opkg/]\n"
 done

 # /opt/etc/init.d/ — init scriptleri (aria2'nin kendi init'i hariç)
 for _f in /opt/etc/init.d/S*; do
 [ -f "$_f" ] || continue
 [ "$_f" = "$INIT_FILE" ] && continue
 grep -qi "$_PKG" "$_f" 2>/dev/null && _FOUND="${_FOUND} • $(basename "$_f") [/opt/etc/init.d/]\n"
 done

 # /opt/bin/ — sadece shell betikleri (binary dosyalar atlanır, paket binary'si kendisi çıkmasın)
 for _f in /opt/bin/*; do
 [ -f "$_f" ] && [ ! -L "$_f" ] || continue
 # İkili (binary) dosyaları atla — sadece shebang ile başlayan shell betiklerini tara
 head -c 4 "$_f" 2>/dev/null | grep -q "^#!" || \
 head -1 "$_f" 2>/dev/null | grep -q "^#!" || continue
 grep -qi "$_PKG" "$_f" 2>/dev/null && _FOUND="${_FOUND} • $(basename "$_f") [/opt/bin/]\n"
 done

 # /opt/etc/ altındaki diğer config/betik dosyaları (.sh uzantılı)
 for _f in /opt/etc/*.sh; do
 [ -f "$_f" ] || continue
 grep -qi "$_PKG" "$_f" 2>/dev/null && _FOUND="${_FOUND} • $(basename "$_f") [/opt/etc/]\n"
 done

 # opkg whatdepends: yüklü başka paket buna bağımlı mı?
 if command -v opkg >/dev/null 2>&1; then
 _RDEP_LIST=$(opkg whatdepends "$_PKG" 2>/dev/null | \
 sed 's/^[[:space:]]*//' | \
 grep -v "^Root\|^Packages\|^[[:space:]]*$" | \
 grep -v "^${_PKG}$\|aria2\|keenetic\|soulsturk\|lighttpd\|curl\|^opkg" | \
 grep -v "^[[:space:]]*$" | \
 head -5)
 # Sadece gerçekten içerik varsa ekle
 _RDEP_CLEAN=$(echo "$_RDEP_LIST" | tr -d '[:space:]')
 if [ -n "$_RDEP_CLEAN" ]; then
 _FOUND="${_FOUND} • [${L_DEP_OPKG_RDEPS}: $(echo "$_RDEP_LIST" | tr '\n' ' ')]\n"
 fi
 fi

 # _FOUND içinde gerçek içerik var mı kontrol et (sadece whitespace/newline değil)
 _FOUND_CLEAN=$(printf "%b" "$_FOUND" | tr -d '[:space:]')
 if [ -n "$_FOUND_CLEAN" ]; then
 printf "%b" "$_FOUND"
 fi
}

# safe_remove_pkg PKG_ADI
# Paketi kaldırmadan önce çakışma kontrolü yapar.
# Çakışma varsa kullanıcıya sorar: atla (önerilen) ya da zorla kaldır.
# Çakışma yoksa doğrudan kaldırır.
safe_remove_pkg() {
 _SPK="$1"
 echo -e "${YELLOW} ${L_DEP_SCAN_INFO} [ ${CYAN}${_SPK}${YELLOW} ]${NC}"
 _USERS=$(_dep_find_users "$_SPK")

 if [ -n "$_USERS" ]; then
 echo ""
 echo -e "${RED}${BOLD} ${L_DEP_CONFLICT_TITLE}: ${CYAN}${_SPK}${NC}"
 echo -e "${DIM_CYAN} ────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_DEP_CONFLICT_INFO}${NC}"
 printf "%b" "$_USERS" | while IFS= read -r _ln; do
 [ -n "$_ln" ] && echo -e "${CYAN}$_ln${NC}"
 done
 echo -e "${DIM_CYAN} ────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_DEP_CONFLICT_OPT}${NC}"
 echo -e " ${YELLOW}1)${NC} ${GREEN}${L_DEP_SKIP}${NC} ${DIM_CYAN}← ${L_DEP_RECOMMENDED}${NC}"
 echo -e " ${YELLOW}2)${NC} ${RED}${L_DEP_FORCE}${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [1/2, Enter=1]: ${NC}"; read _sc
 case "${_sc:-1}" in
 2)
 echo -e "${YELLOW} opkg remove ${_SPK}${NC}"
 _SOUT=$(opkg remove "$_SPK" 2>&1)
 _SRET=$?
 echo "$_SOUT" | grep -v 'No such file\|no such file' | tail -4
 if [ "$_SRET" -eq 0 ] || echo "$_SOUT" | grep -q "Removing package"; then
 echo -e "${GREEN} ${L_FULL_UNINSTALL_PKG_DONE}: ${_SPK}${NC}"
 else
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_PKG_FAIL}${NC}"
 fi
 ;;
 *)
 echo -e "${GREEN} ${L_DEP_SKIPPED}: ${_SPK}${NC}"
 ;;
 esac
 else
 echo -e "${CYAN} ${L_DEP_NO_CONFLICT}${NC}"
 echo -e "${YELLOW} opkg remove ${_SPK}${NC}"
 _SOUT=$(opkg remove "$_SPK" 2>&1)
 _SRET=$?
 echo "$_SOUT" | grep -v 'No such file\|no such file' | tail -4
 if [ "$_SRET" -eq 0 ] || echo "$_SOUT" | grep -q "Removing package"; then
 echo -e "${GREEN} ${L_FULL_UNINSTALL_PKG_DONE}: ${_SPK}${NC}"
 else
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_PKG_FAIL}${NC}"
 fi
 fi
}

# _safe_remove_aria2: aria2 paketi için özelleştirilmiş kaldırma
# (aria2 kendine özgü paket, dep-check yerine sadece pipe bug düzeltmesi uygulanır)
_remove_aria2_pkg() {
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_REMOVING_PKG}${NC}"
 _A2OUT=$(opkg remove aria2 2>&1)
 _A2RET=$?
 echo "$_A2OUT" | grep -v 'No such file\|no such file' | tail -4
 if [ "$_A2RET" -eq 0 ] || echo "$_A2OUT" | grep -q "Removing package"; then
 echo -e "${GREEN} ${L_FULL_UNINSTALL_PKG_DONE}${NC}"
 else
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_PKG_FAIL}${NC}"
 fi
}

print_header() {
 clear
 _LW=17

 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} KEENETIC ARIA2 MANAGER  |  ${GREEN}github.com/SoulsTurk${NC}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 # ── SİSTEM ──────────────────────────────────────────
 printf " ${CYAN}${BOLD}── %s ──${NC}\n" "$L_HDR_SYSTEM"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # hostname + uptime
 _HOSTNAME=$(hostname 2>/dev/null || echo "router")
 _UPTIME_RAW=$(awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf "%dd %dh %dm",d,h,m; else if(h>0) printf "%dh %dm",h,m; else printf "%dm",m}' /proc/uptime 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC} ${YELLOW}↑ %s${NC}\n" "$(pad_label "$L_HDR_SYSTEM" $_LW)" "$_HOSTNAME" "${_UPTIME_RAW:-?}"

 # WAN IP
 _WAN_IP=$(ip -4 addr show ppp0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 [ -z "$_WAN_IP" ] && _WAN_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)
 [ -z "$_WAN_IP" ] && _WAN_IP=$(ip -4 addr show br0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 [ -n "$_WAN_IP" ] && printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HDR_WAN_IP" $_LW)" "$_WAN_IP"

 # ── ARIA2 ────────────────────────────────────────────
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf " ${CYAN}${BOLD}── ARIA2 ──${NC}\n"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # aria2c binary
 if aria2_installed; then
 ARIA2_VER=$(aria2_version)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(v%s)${NC}\n" "$(pad_label "$L_ARIA2C" $_LW)" "$L_INSTALLED" "${ARIA2_VER:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}%s${NC}\n" "$(pad_label "$L_ARIA2C" $_LW)" "$L_NOT_INSTALLED" "$L_INSTALL_HINT"
 fi

 # Servis durumu
 if status_check; then
 PID_NOW=$(cat "$PID_FILE" 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(PID: %s)${NC}\n" "$(pad_label "$L_SERVICE" $_LW)" "$L_RUNNING" "${PID_NOW:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_SERVICE" $_LW)" "$L_STOPPED"
 fi

 # Oto başlatma
 printf " ${BOLD}%s${NC} : %b\n" "$(pad_label "$L_AUTO_START" $_LW)" \
 "$([ -f "$INIT_FILE" ] && echo "${GREEN}${L_ACTIVE}${NC}" || echo "${RED}${L_INACTIVE}${NC}")"

 # Aktif indirme + anlık hız (RPC)
 RPC_ENABLED=$(conf_get "enable-rpc"); RPC_PORT_VAL=$(conf_get "rpc-listen-port"); RPC_PORT_VAL="${RPC_PORT_VAL:-6800}"
 _ACTIVE_CNT=""; _DL_SPEED_DISP=""
 if ! status_check; then
 # Servis kapalı
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_HDR_ACTIVE_DL" $_LW)" "$L_HDR_ACTIVE_DL_SVC_DOWN"
 else
 if [ "$RPC_ENABLED" = "true" ]; then
 _RPC_SECRET=$(conf_get "rpc-secret")
 [ -n "$_RPC_SECRET" ] && _RPC_AUTH="\"token:${_RPC_SECRET}\"," || _RPC_AUTH=""
 _RPC_RESP=$(curl -s --connect-timeout 1 \
 "http://localhost:${RPC_PORT_VAL}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellActive\",\"id\":1,\"params\":[${_RPC_AUTH}[\"gid\",\"downloadSpeed\"]]}" 2>/dev/null)
 _ACTIVE_CNT=$(echo "$_RPC_RESP" | grep -o '"gid"' | wc -l | tr -d ' ')
 if [ "${_ACTIVE_CNT:-0}" -gt 0 ] 2>/dev/null; then
 _TOTAL_SPD=$(echo "$_RPC_RESP" | grep -o '"downloadSpeed":"[^"]*"' | \
 awk -F'"' '{sum+=$4} END{printf "%.0f",sum}')
 if [ -n "$_TOTAL_SPD" ] && [ "$_TOTAL_SPD" -gt 0 ] 2>/dev/null; then
 if [ "$_TOTAL_SPD" -ge 1048576 ]; then _DL_SPEED_DISP=$(awk "BEGIN{printf \"%.1f MB/s\",$_TOTAL_SPD/1048576}")
 elif [ "$_TOTAL_SPD" -ge 1024 ]; then _DL_SPEED_DISP=$(awk "BEGIN{printf \"%.0f KB/s\",$_TOTAL_SPD/1024}")
 else _DL_SPEED_DISP="${_TOTAL_SPD} B/s"; fi
 fi
 fi
 fi
 if [ -n "$_DL_SPEED_DISP" ]; then
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC} ${GREEN}⬇ %s${NC}\n" "$(pad_label "$L_HDR_ACTIVE_DL" $_LW)" "${_ACTIVE_CNT}" "$_DL_SPEED_DISP"
 elif [ "${_ACTIVE_CNT:-0}" -gt 0 ] 2>/dev/null; then
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_HDR_ACTIVE_DL" $_LW)" "${_ACTIVE_CNT}"
 else
 # Servis açık ama indirme yok
 printf " ${BOLD}%s${NC} : \033[2m%s\033[0m\n" "$(pad_label "$L_HDR_ACTIVE_DL" $_LW)" "$L_HDR_ACTIVE_DL_NONE"
 fi
 fi

 # RPC — config'de açık + servis çalışıyor + sokete yanıt veriyor olmalı
 if [ "$RPC_ENABLED" = "true" ]; then
 if status_check; then
 # Sokete gerçekten bağlanabiliyor muyuz?
 _RPC_SECRET=$(conf_get "rpc-secret")
 [ -n "$_RPC_SECRET" ] && _RPC_AUTH_H="\"token:${_RPC_SECRET}\"" || _RPC_AUTH_H=""
 _RPC_PING=$(curl -s --connect-timeout 1 \
 "http://localhost:${RPC_PORT_VAL}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getVersion\",\"id\":1,\"params\":[${_RPC_AUTH_H}]}" 2>/dev/null)
 if echo "$_RPC_PING" | grep -q '"result"'; then
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(%s: %s)${NC}\n" "$(pad_label "$L_RPC" $_LW)" "$L_ACTIVE" "$L_PORT" "${RPC_PORT_VAL}"
 else
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC} ${CYAN}(%s: %s)${NC}\n" "$(pad_label "$L_RPC" $_LW)" \
 "$(if [ "$LANG_SEL" = "en" ]; then echo "NO RESPONSE"; elif [ "$LANG_SEL" = "ru" ]; then echo "НЕТ ОТВЕТА"; else echo "YANIT YOK"; fi)" "$L_PORT" "${RPC_PORT_VAL}"
 fi
 else
 # Servis kapalıysa RPC de kapalıdır — config değeri yanıltmasın
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}(config: enabled)${NC}\n" "$(pad_label "$L_RPC" $_LW)" "$L_INACTIVE"
 fi
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_RPC" $_LW)" "$L_INACTIVE"
 fi

 # AriaNg WebUI
 _ang_p=$(cat "$ARIANG_PORT_FILE" 2>/dev/null || echo "6880")
 if ariang_is_installed; then
 if ariang_is_running; then
 _ang_ip=$(ariang_get_ip 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}http://%s:%s/${NC}\n" "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_RUNNING" "${_ang_ip}" "${_ang_p}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}(%s)${NC}\n" "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_STOPPED" "$L_ARIANG_INSTALLED"
 fi
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_NOT_INSTALLED"
 fi

 # Telegram
 _TG_EN=$(tg_get TG_ENABLED 2>/dev/null)
 if [ "$_TG_EN" = "true" ]; then
 _TG_DISPLAY="${GREEN}${L_ACTIVE}${NC}"
 else
 _TG_DISPLAY="${RED}${L_INACTIVE}${NC}"
 fi
 printf " ${BOLD}%s${NC} : %b\n" "$(pad_label "$L_HDR_TELEGRAM" $_LW)" "$_TG_DISPLAY"

 # İndirme dizini (Telegram'ın altında)
 DL_DIR=$(conf_get "dir")
 SELECTED_DISK=""
 if [ -n "$DL_DIR" ]; then
 for _mp in /tmp/mnt/* /mnt/* /media/*; do
 [ -d "$_mp" ] || continue
 case "$DL_DIR" in "$_mp"*) SELECTED_DISK="$_mp"; break ;; esac
 done
 [ -z "$SELECTED_DISK" ] && SELECTED_DISK="$DL_DIR"
 fi
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_SELECTED_DISK" $_LW)" "${SELECTED_DISK:-${L_DISK_NOT_SET}}"
 if [ -n "$DL_DIR" ] && [ -d "$DL_DIR" ]; then
 _DISK_FREE=$(df -h "$DL_DIR" 2>/dev/null | awk 'NR==2{print $4}')
 _DISK_TOTAL=$(df -h "$DL_DIR" 2>/dev/null | awk 'NR==2{print $2}')
 _DISK_PCT=$(df "$DL_DIR" 2>/dev/null | awk 'NR==2{print $5}')
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC} / %s ${YELLOW}%s${NC}\n" "$(pad_label "$L_HDR_DISK_FREE" $_LW)" "${_DISK_FREE:-?}" "${_DISK_TOTAL:-?}" "${_DISK_PCT:-?}"
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_DL_LOCATION" $_LW)" "$DL_DIR"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_DL_LOCATION" $_LW)" "${L_DISK_NOT_SET}"
 fi

 # ── HAKKINDA / ABOUT ─────────────────────────────────
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf " ${CYAN}${BOLD}── %s ──${NC}\n" "$L_HDR_ABOUT"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "Version" $_LW)" "$SCRIPT_VERSION"
 printf " ${BOLD}%s${NC} : \033[2m%s\033[0m\n" "$(pad_label "$L_HDR_GITHUB" $_LW)" "github.com/SoulsTurk/keenetic-aria2-manager"
 echo ""
 printf " ${CYAN}%s${NC}\n" "$L_HDR_DESC1"
 echo ""
 if [ "$LANG_SEL" = "en" ]; then
 printf " ${CYAN}Run with:${NC} ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC}\n" \
 "aria2m" "a2m" "k2m" "kam" "aria2manager"
 elif [ "$LANG_SEL" = "ru" ]; then
 printf " ${CYAN}Запуск:${NC} ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC}\n" \
 "aria2m" "a2m" "k2m" "kam" "aria2manager"
 else
 printf " ${CYAN}Çalıştır:${NC} ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC} \033[2m|\033[0m ${GREEN}%s${NC}\n" \
 "aria2m" "a2m" "k2m" "kam" "aria2manager"
 fi
 echo ""
 printf " ${YELLOW}%s${NC}\n" "$L_HDR_FEAT1"
 printf " ${YELLOW}%s${NC}\n" "$L_HDR_FEAT2"
 printf " ${YELLOW}%s${NC}\n" "$L_HDR_FEAT3"
 printf " ${YELLOW}%s${NC}\n" "$L_HDR_FEAT4"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
}

# ============================================
# KURULUM / INSTALL
# ============================================
install_aria2() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_INSTALL_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if aria2_installed; then
 echo -e " ${YELLOW}${NC} ${L_ALREADY_INSTALLED}"; sleep 2; return
 fi
 echo -e "${YELLOW} ${L_PKG_UPDATING}${NC}"; opkg update 2>&1 | tail -3
 echo -e "${YELLOW} ${L_PKG_INSTALLING}${NC}"
 if opkg install aria2 2>&1; then
 echo -e "${GREEN} ${L_INSTALL_OK}${NC}"; sleep 1
 echo -e "${YELLOW} ${L_POST_INSTALL_MSG}${NC}"; sleep 1
 auto_setup_after_install
 else
 echo -e "${RED} ${L_INSTALL_FAIL}${NC}"; sleep 3
 fi
}

auto_setup_after_install() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_POST_INSTALL_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${YELLOW} ${L_CREATING_CONF}${NC}"
 if [ -f "$ARIA2_CONF" ]; then
  echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Config already exists, keeping your settings."; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл конфигурации уже существует, ваши настройки сохранены."; else echo "Config dosyası zaten var, mevcut ayarlarınız korunuyor."; fi)${NC}"
  sleep 1
 else
  create_default_config; sleep 1
 fi
 echo -e "${YELLOW} ${L_SCANNING_USB}${NC}"; USB_MOUNTS=$(detect_usb)
 if [ -n "$USB_MOUNTS" ]; then
 echo -e "${GREEN} ${L_USB_DETECTED}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 i=1
 for mp in $USB_MOUNTS; do
 FREE=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $4}')
 TOTAL=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $2}')
 echo -e " ${YELLOW}$i)${NC} $mp ${CYAN}[${L_USB_FREE}: ${FREE:-?} / ${L_USB_TOTAL}: ${TOTAL:-?}]${NC}"
 i=$((i + 1))
 done
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 USB_COUNT=$((i - 1))
 if [ "$USB_COUNT" -eq 1 ]; then
 SELECTED=$(echo "$USB_MOUNTS" | tr ' ' '\n' | grep -v '^$' | head -1)
 DEFAULT_DL_PATH="${SELECTED}/aria2/downloads"
 echo ""
 echo -e "${YELLOW} ${L_FOLDER_DEFAULT_INFO}${NC}"
 echo -e " ${CYAN}→ ${DEFAULT_DL_PATH}${NC}"
 printf "${YELLOW}${L_FOLDER_CHANGE_Q}${NC}"
 read ans
 if [ "$ans" = "$L_CONFIRM_YES" ] || [ "$ans" = "$L_CONFIRM_YES2" ]; then
 printf "${YELLOW}${L_FOLDER_PROMPT}${NC}"
 read custom_folder
 if [ -n "$custom_folder" ]; then
 custom_folder=$(echo "$custom_folder" | sed 's|^/||')
 FINAL_PATH="${SELECTED}/${custom_folder}"
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 mkdir -p "$FINAL_PATH" 2>/dev/null
 conf_set "dir" "$FINAL_PATH"
 echo -e "${GREEN} ${L_DL_DIR_SET} $FINAL_PATH${NC}"
 else
 printf "${YELLOW}${L_USB_SELECT}${NC}"; read sel_num
 [ -z "$sel_num" ] && sel_num=1
 SELECTED=$(echo "$USB_MOUNTS" | tr ' ' '\n' | grep -v '^$' | sed -n "${sel_num}p")
 if [ -n "$SELECTED" ]; then
 DEFAULT_DL_PATH="${SELECTED}/aria2/downloads"
 echo ""
 echo -e "${YELLOW} ${L_FOLDER_DEFAULT_INFO}${NC}"
 echo -e " ${CYAN}→ ${DEFAULT_DL_PATH}${NC}"
 printf "${YELLOW}${L_FOLDER_CHANGE_Q}${NC}"
 read ans
 if [ "$ans" = "$L_CONFIRM_YES" ] || [ "$ans" = "$L_CONFIRM_YES2" ]; then
 printf "${YELLOW}${L_FOLDER_PROMPT}${NC}"
 read custom_folder
 if [ -n "$custom_folder" ]; then
 custom_folder=$(echo "$custom_folder" | sed 's|^/||')
 FINAL_PATH="${SELECTED}/${custom_folder}"
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 mkdir -p "$FINAL_PATH" 2>/dev/null
 conf_set "dir" "$FINAL_PATH"
 echo -e "${GREEN} ${L_DL_DIR_SET} $FINAL_PATH${NC}"
 fi
 fi
 else
 echo -e "${YELLOW} ${L_USB_NONE}${NC}"
 echo -e "${YELLOW} ${L_USB_CHECK}${NC}"
 conf_set "dir" "/tmp"
 fi
 echo ""; echo -e "${GREEN} ${L_SETUP_DONE}${NC}"
 echo -e "${CYAN} ${L_HINT_SETTINGS}${NC}"
 echo -e "${CYAN} ${L_HINT_START}${NC}"
 sleep 4
}

create_default_config() {
 [ -d "$CONF_DIR" ] || mkdir -p "$CONF_DIR"
 # Config zaten varsa mevcut secret'i koru, yoksa yeni üret
 local _existing_secret=""
 [ -f "$ARIA2_CONF" ] && _existing_secret=$(grep -m1 '^rpc-secret=' "$ARIA2_CONF" 2>/dev/null | cut -d'=' -f2-)
 if [ -z "$_existing_secret" ]; then
 _existing_secret=$(gen_rpc_secret)
 fi
 cat > "$ARIA2_CONF" <<CONFEOF
# ============================================
# ${L_CONF_HEADER}
# $(date)
# ============================================

# === DOWNLOAD SETTINGS ===
dir=${DEFAULT_DIR}
continue=true
max-concurrent-downloads=${DEFAULT_MAX_CONCURRENT}
max-connection-per-server=${DEFAULT_MAX_CONNECTION}
split=${DEFAULT_SPLIT}
min-split-size=${DEFAULT_MIN_SPLIT}
file-allocation=${DEFAULT_FILE_ALLOC}
disk-cache=${DEFAULT_DISK_CACHE}

# === SPEED LIMITS (0 = unlimited) ===
max-overall-download-limit=${DEFAULT_DL_LIMIT}
max-overall-upload-limit=${DEFAULT_UL_LIMIT}

# === RPC SETTINGS ===
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=${DEFAULT_RPC_PORT}
rpc-secret=${_existing_secret}

# === SESSION ===
input-file=${ARIA2_SESSION}
save-session=${ARIA2_SESSION}
save-session-interval=60

# === LOG ===
log=${ARIA2_LOG}
log-level=${DEFAULT_LOG_LEVEL}
CONFEOF
 echo -e "${GREEN} ${L_CONF_CREATED} $ARIA2_CONF${NC}"
 echo -e "${CYAN} RPC Secret: ${YELLOW}${_existing_secret}${NC}"
 # İlk kurulumda oluşturulan key için Telegram bildirimi
 tg_notify "secret_key" "${_existing_secret}"
}

# ============================================
# USB TARAMA / USB SCAN
# ============================================
scan_usb_menu() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_USB_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${YELLOW} ${L_USB_SEARCHING}${NC}"; sleep 1
 USB_MOUNTS=$(detect_usb)
 if [ -z "$USB_MOUNTS" ]; then
 echo -e "${RED} ${L_USB_NONE}${NC}"; echo -e "${YELLOW} ${L_USB_CHECK}${NC}"; sleep 3; return
 fi
 echo -e "${GREEN}${L_USB_DETECTED2}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 i=1
 for mp in $USB_MOUNTS; do
 FREE=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $4}')
 TOTAL=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $2}')
 USED=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $5}')
 echo -e " ${YELLOW}$i)${NC} $mp"
 echo -e " ${CYAN}${L_USB_FREE}: ${FREE:-?} | ${L_USB_TOTAL}: ${TOTAL:-?} | ${L_USB_USED}: ${USED:-?}${NC}"
 i=$((i + 1))
 done
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf "${YELLOW}${L_USB_SELECT_NUM}${NC}"; read sel
 [ "$sel" = "0" ] || [ -z "$sel" ] && return
 SELECTED=$(echo "$USB_MOUNTS" | tr ' ' '\n' | grep -v '^$' | sed -n "${sel}p")
 if [ -n "$SELECTED" ]; then
 DEFAULT_DL_PATH="${SELECTED}/aria2/downloads"
 echo ""
 echo -e "${YELLOW} ${L_FOLDER_DEFAULT_INFO}${NC}"
 echo -e " ${CYAN}→ ${DEFAULT_DL_PATH}${NC}"
 printf "${YELLOW}${L_FOLDER_CHANGE_Q}${NC}"; read fld_ans
 if [ "$fld_ans" = "$L_CONFIRM_YES" ] || [ "$fld_ans" = "$L_CONFIRM_YES2" ]; then
 printf "${YELLOW}${L_FOLDER_PROMPT}${NC}"; read custom_folder
 if [ -n "$custom_folder" ]; then
 custom_folder=$(echo "$custom_folder" | sed 's|^/||')
 FINAL_PATH="${SELECTED}/${custom_folder}"
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 else
 FINAL_PATH="${DEFAULT_DL_PATH}"
 fi
 mkdir -p "$FINAL_PATH" 2>/dev/null
 conf_set "dir" "$FINAL_PATH"
 echo -e "${GREEN} ${L_USB_DIR_SET} '${FINAL_PATH}'${NC}"
 if status_check; then
 printf "${YELLOW}${L_USB_RESTART_Q}${NC}"; read rst_ans
 if yes_answer "$rst_ans"; then
 echo -e "${YELLOW}${L_USB_RESTARTING}${NC}"
 stop_service_silent; sleep 1; start_service_silent
 echo -e "${GREEN} ${L_USB_RESTARTED}${NC}"
 fi
 fi
 else
 echo -e "${RED} ${L_INVALID}${NC}"
 fi
 sleep 2
}

# ============================================
# SERVİS / SERVICE
# ============================================
start_service_silent() {
 # Zaten çalışıyorsa bir daha başlatma
 pidof aria2c >/dev/null 2>&1 && return 0
 # Gerekli dizin ve dosyaları garantiye al
 mkdir -p "$CONF_DIR" "/opt/var/log" "/opt/var/run" 2>/dev/null
 [ -f "$ARIA2_SESSION" ] || touch "$ARIA2_SESSION" 2>/dev/null
 # Config'de daemon=true varsa kaldır
 [ -f "$ARIA2_CONF" ] && sed -i '/^daemon=true/d' "$ARIA2_CONF" 2>/dev/null
 aria2c --conf-path="$ARIA2_CONF" >>"$ARIA2_LOG" 2>&1 &
 ARIA2_PID=$!
 echo "$ARIA2_PID" > "$PID_FILE"
 sleep 2
}

stop_service_silent() {
 PID_NOW=$(cat "$PID_FILE" 2>/dev/null)
 [ -n "$PID_NOW" ] && kill "$PID_NOW" 2>/dev/null
 pkill aria2c 2>/dev/null; rm -f "$PID_FILE"
}

start_service() {
 if ! aria2_installed; then
  echo -e "${RED} ${L_SVC_NOT_INSTALLED}${NC}"
  if [ "$LANG_SEL" = "en" ]; then
   printf " Install aria2c now? [${GREEN}Y${NC}/${RED}N${NC}]: "
  elif [ "$LANG_SEL" = "ru" ]; then
   printf " Установить aria2c сейчас? [${GREEN}Д${NC}/${RED}Н${NC}]: "
  else
   printf " aria2c şimdi kurulsun mu? [${GREEN}E${NC}/${RED}H${NC}]: "
  fi
  read _inst_now
  case "$_inst_now" in
   [EeYy]) install_aria2; return ;;
   *) return ;;
  esac
 fi
 if [ ! -f "$ARIA2_CONF" ]; then
 echo -e "${YELLOW} ${L_SVC_CONF_MISSING}${NC}"; create_default_config; sleep 1
 fi
 if status_check; then
 echo -e "${YELLOW} ${L_SVC_ALREADY_RUNNING}${NC}"; sleep 2; return
 fi
 echo -e "${YELLOW}${L_SVC_STARTING}${NC}"

 # Önce hâlâ çalışıyor mu kontrol et
 if pidof aria2c >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_SVC_ALREADY_RUNNING}${NC}"; sleep 2; return
 fi

 # Config'de daemon=true varsa kaldır
 if [ -f "$ARIA2_CONF" ]; then
 sed -i '/^daemon=true/d' "$ARIA2_CONF" 2>/dev/null
 fi

 # Gerekli dizin ve dosyaları garantiye al (session eksikse aria2c başlamaz)
 mkdir -p "$CONF_DIR" "/opt/var/log" "/opt/var/run" 2>/dev/null
 if [ ! -f "$ARIA2_SESSION" ]; then
 touch "$ARIA2_SESSION" 2>/dev/null
 echo -e "${CYAN} ℹ $(if [ "$LANG_SEL" = "en" ]; then echo "Session file created:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл сессии создан:"; else echo "Session dosyası oluşturuldu:"; fi) $ARIA2_SESSION${NC}"
 fi

 echo -e "${CYAN} [1/4] aria2c binary: $(command -v aria2c 2>/dev/null || echo '${L_SVC_BINARY_NOT_FOUND}')${NC}"
 echo -e "${CYAN} [2/4] Config: $ARIA2_CONF${NC}"
 if [ ! -f "$ARIA2_CONF" ]; then
 echo -e "${RED} ${L_SVC_CONF_MISSING_TXT}${NC}"
 else
 echo -e "${GREEN} Config OK${NC}"
 fi

 # Arka planda başlat, stderr'i log dosyasına yönlendir
 echo -e "${CYAN} [3/4] ${L_SVC_STARTING_PROC}${NC}"
 aria2c --conf-path="$ARIA2_CONF" >>"$ARIA2_LOG" 2>&1 &
 ARIA2_PID=$!
 echo "$ARIA2_PID" > "$PID_FILE"
 echo -e "${CYAN} [4/4] PID: $ARIA2_PID — 3 ${L_SVC_WAITING}${NC}"

 # Başlaması için 3 saniye bekle
 sleep 3
 if status_check; then
 PID_NOW=$(cat "$PID_FILE" 2>/dev/null)
 echo -e "${GREEN} ${L_SVC_STARTED} PID: ${PID_NOW:-?}${NC}"
 tg_notify "svc_start"
 else
 echo -e "${RED} ${L_SVC_START_FAIL}${NC}"
 echo -e "${YELLOW} pidof aria2c: $(pidof aria2c 2>/dev/null || echo 'none')${NC}"
 echo -e "${YELLOW} PID file: $(cat "$PID_FILE" 2>/dev/null || echo 'none')${NC}"
 echo -e "${YELLOW}${L_SVC_LOG_HINT} $ARIA2_LOG${NC}"
 if [ -f "$ARIA2_LOG" ]; then
 echo -e "${CYAN}${L_SVC_LOG_TAIL}${NC}"
 tail -10 "$ARIA2_LOG"
 echo -e "${CYAN}------------------------${NC}"
 else
 echo -e "${RED} ${L_SVC_LOG_NOT_FOUND} $ARIA2_LOG${NC}"
 fi
 fi
 sleep 4
}

stop_service() {
 if status_check; then
 echo -e "${YELLOW}${L_SVC_STOPPING}${NC}"; stop_service_silent; sleep 1
 if ! status_check; then
 echo -e "${GREEN} ${L_SVC_STOPPED_OK}${NC}"
 tg_notify "svc_stop"
 else
 echo -e "${RED} ${L_SVC_STOP_FAIL}${NC}"
 pkill -9 aria2c 2>/dev/null; rm -f "$PID_FILE"
 echo -e "${GREEN} ${L_SVC_FORCE_KILLED}${NC}"
 tg_notify "svc_stop"
 fi
 else
 rm -f "$PID_FILE"; echo -e "${RED} ${L_SVC_NOT_RUNNING}${NC}"
 fi
 sleep 2
}

restart_service() {
 echo -e "${YELLOW} ${L_SVC_RESTARTING}${NC}"
 if status_check; then stop_service_silent; sleep 1; fi
 start_service
}

# ============================================
# İNDİRME / DOWNLOAD
# ============================================
add_download() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_ADD_DL_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if ! status_check; then
 echo -e "${RED} ${L_ARIA2_NOT_RUNNING}${NC}"; sleep 2; return
 fi
 RPC_PORT=$(conf_get "rpc-listen-port"); RPC_SECRET=$(conf_get "rpc-secret")
 RPC_PORT="${RPC_PORT:-6800}"
 printf "${YELLOW}${L_URL_PROMPT}${NC}"; read DL_URL
 [ -z "$DL_URL" ] && return
 printf "${YELLOW}$(printf "$L_DIR_PROMPT" "$(conf_get "dir")")${NC}"; read DEST_DIR
 [ -n "$RPC_SECRET" ] && AUTH="\"token:${RPC_SECRET}\"," || AUTH=""
 if [ -n "$DEST_DIR" ]; then
 PARAMS="[\"${DL_URL}\",[],{\"dir\":\"${DEST_DIR}\"}]"
 else
 PARAMS="[\"${DL_URL}\"]"
 fi
 RESULT=$(curl -s --connect-timeout 5 \
 "http://localhost:${RPC_PORT}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.addUri\",\"id\":1,\"params\":[${AUTH}${PARAMS}]}" 2>/dev/null)
 if echo "$RESULT" | grep -q '"result"'; then
 GID=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
 echo -e "${GREEN} ${L_DL_QUEUED}${NC}"; echo -e " ${CYAN}${L_DL_GID}: $GID${NC}"
 FNAME=$(basename "$DL_URL" 2>/dev/null)
 tg_notify "dl_add" "$FNAME"
 else
 echo -e "${RED} ${L_DL_FAIL}${NC}"
 echo -e "${YELLOW}${L_SERVER_RESP} ${RESULT}${NC}"
 echo -e "${YELLOW} ${L_RPC_HINT}${NC}"
 fi
 sleep 3
}

list_downloads() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_DL_LIST_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if ! status_check; then
 echo -e "${RED} ${L_SVC_NOT_RUNNING}${NC}"; sleep 2; return
 fi
 RPC_PORT=$(conf_get "rpc-listen-port"); RPC_PORT="${RPC_PORT:-6800}"
 RPC_SECRET=$(conf_get "rpc-secret")
 [ -n "$RPC_SECRET" ] && AUTH="\"token:${RPC_SECRET}\"," || AUTH=""

 echo -e "${GREEN}${BOLD}${L_ACTIVE_DL}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 ACTIVE=$(curl -s --connect-timeout 5 "http://localhost:${RPC_PORT}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellActive\",\"id\":1,\"params\":[${AUTH}[\"gid\",\"status\",\"totalLength\",\"completedLength\",\"downloadSpeed\",\"files\"]]}" 2>/dev/null)
 if echo "$ACTIVE" | grep -q '"result":\[\]'; then
 echo -e " ${CYAN}(${L_NO_ACTIVE})${NC}"
 else
 echo "$ACTIVE" | grep -o '"gid":"[^"]*","status":"[^"]*","totalLength":"[^"]*","completedLength":"[^"]*","downloadSpeed":"[^"]*"' | \
 while IFS= read -r line; do
 GID=$(echo "$line" | grep -o '"gid":"[^"]*"' | cut -d'"' -f4)
 SPEED=$(echo "$line" | grep -o '"downloadSpeed":"[^"]*"' | cut -d'"' -f4)
 TOTAL=$(echo "$line" | grep -o '"totalLength":"[^"]*"' | cut -d'"' -f4)
 DONE=$(echo "$line" | grep -o '"completedLength":"[^"]*"' | cut -d'"' -f4)
 SPEED_K=$((SPEED / 1024)); TOTAL_M=$((TOTAL / 1024 / 1024)); DONE_M=$((DONE / 1024 / 1024))
 [ "$TOTAL" -gt 0 ] 2>/dev/null && PCT=$((DONE * 100 / TOTAL)) || PCT=0
 echo -e " ${YELLOW}GID:${NC} $GID ${CYAN}%${PCT}${NC} ${GREEN}${SPEED_K} KB/s${NC} ${DONE_M}/${TOTAL_M} MB"
 done
 fi

 echo ""; echo -e "${YELLOW}${BOLD}${L_WAITING_DL}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 WAITING=$(curl -s --connect-timeout 5 "http://localhost:${RPC_PORT}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellWaiting\",\"id\":1,\"params\":[${AUTH}0,10,[\"gid\",\"status\"]]}" 2>/dev/null)
 if echo "$WAITING" | grep -q '"result":\[\]'; then
 echo -e " ${CYAN}(${L_NO_WAITING})${NC}"
 else
 echo "$WAITING" | grep -o '"gid":"[^"]*"' | cut -d'"' -f4 | \
 while read -r gid; do echo -e " ${YELLOW}GID: $gid${NC}"; done
 fi

 echo ""; echo -e "${GREEN}${BOLD} ${L_COMPLETED_DL}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 STOPPED=$(curl -s --connect-timeout 5 "http://localhost:${RPC_PORT}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.tellStopped\",\"id\":1,\"params\":[${AUTH}0,5,[\"gid\",\"status\",\"files\"]]}" 2>/dev/null)
 if echo "$STOPPED" | grep -q '"result":\[\]'; then
 echo -e " ${CYAN}(${L_NO_COMPLETED})${NC}"
 else
 echo "$STOPPED" | grep -o '"gid":"[^"]*","status":"[^"]*"' | \
 while IFS= read -r line; do
 GID=$(echo "$line" | grep -o '"gid":"[^"]*"' | cut -d'"' -f4)
 STATUS=$(echo "$line" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
 [ "$STATUS" = "complete" ] && COLOR="$GREEN" || COLOR="$RED"
 echo -e " ${YELLOW}GID:${NC} $GID ${COLOR}${STATUS}${NC}"
 done
 fi
 echo ""; printf "${YELLOW}${L_PRESS_ENTER}${NC}"; read _
}

# ============================================
# AYARLAR / SETTINGS
# ============================================
full_config_wizard() {
 _WIZ_VAL=""

 _wiz_cat() {
  clear
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}${BOLD} $1${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  echo -e " ${YELLOW}$2${NC}"
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Press Enter to start this section..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Нажмите Enter для начала раздела..."; else echo "Bu bölüme başlamak için Enter'a basın..."; fi)"; read _dummy
 }

 _ask() {
  clear
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}${BOLD} [$1] ${2}${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  echo -e " $3"
  [ -n "$6" ] && echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Valid"; elif [ "$LANG_SEL" = "ru" ]; then echo "Допустимо"; else echo "Geçerli"; fi): ${CYAN}$6${NC}"
  [ -n "$5" ] && echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Example"; elif [ "$LANG_SEL" = "ru" ]; then echo "Пример"; else echo "Örnek"; fi): ${YELLOW}$5${NC}"
  echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Current"; elif [ "$LANG_SEL" = "ru" ]; then echo "Текущее"; else echo "Mevcut"; fi): ${GREEN}${4:-$(if [ "$LANG_SEL" = "en" ]; then echo "(empty)"; elif [ "$LANG_SEL" = "ru" ]; then echo "(пусто)"; else echo "(boş)"; fi)}${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  echo -e " ${RED}Q${NC}=$(if [ "$LANG_SEL" = "en" ]; then echo "quit  "; elif [ "$LANG_SEL" = "ru" ]; then echo "выход  "; else echo "çık   "; fi)  ${GREEN}K${NC}=$(if [ "$LANG_SEL" = "en" ]; then echo "save & quit"; elif [ "$LANG_SEL" = "ru" ]; then echo "сохр. и выход"; else echo "kaydet ve çık"; fi)  ${YELLOW}Enter${NC}=$(if [ "$LANG_SEL" = "en" ]; then echo "keep current"; elif [ "$LANG_SEL" = "ru" ]; then echo "сохранить текущее"; else echo "mevcut koru"; fi)"
  printf " ${YELLOW}> ${NC}"
  read _WIZ_VAL
 }

 _wizard_save() {
  conf_set "dir"                        "$_w_dir"
  conf_set "file-allocation"            "$_w_alloc"
  [ -n "$_w_noalloclimit" ]  && conf_set "no-file-allocation-limit"    "$_w_noalloclimit"
  conf_set "disk-cache"                 "$_w_cache"
  conf_set "input-file"                 "$_w_session"
  conf_set "save-session"               "$_w_savesession"
  conf_set "save-session-interval"      "$_w_saveinterval"
  conf_set "force-save"                 "$_w_forcesave"
  conf_set "auto-file-renaming"         "$_w_autoremove"
  conf_set "allow-overwrite"            "$_w_overwrite"
  conf_set "max-concurrent-downloads"   "$_w_concurrent"
  conf_set "max-connection-per-server"  "$_w_maxconn"
  conf_set "split"                      "$_w_split"
  conf_set "min-split-size"             "$_w_minsplit"
  conf_set "max-overall-download-limit" "$_w_dlimit"
  conf_set "max-overall-upload-limit"   "$_w_ulimit"
  [ -n "$_w_lowestspeed" ]   && conf_set "lowest-speed-limit"          "$_w_lowestspeed"
  conf_set "continue"                   "$_w_continue"
  conf_set "always-resume"              "$_w_alwaysresume"
  conf_set "timeout"                    "$_w_timeout"
  conf_set "connect-timeout"            "$_w_conntimeout"
  conf_set "max-tries"                  "$_w_retry"
  conf_set "retry-wait"                 "$_w_retrydelay"
  [ -n "$_w_maxnotfound" ]   && conf_set "max-file-not-found"          "$_w_maxnotfound"
  [ -n "$_w_useragent" ]     && conf_set "user-agent"                  "$_w_useragent"
  [ -n "$_w_referer" ]       && conf_set "referer"                     "$_w_referer"
  conf_set "enable-http-keep-alive"     "$_w_keepalive"
  conf_set "http-no-cache"              "$_w_nocache"
  conf_set "ftp-type"                   "$_w_ftptype"
  conf_set "ftp-pasv"                   "$_w_ftppasv"
  conf_set "reuse-socket"               "$_w_reuse"
  conf_set "enable-rpc"                 "$_w_rpc"
  conf_set "rpc-listen-port"            "$_w_rpcport"
  conf_set "rpc-listen-all"             "$_w_rpcall"
  conf_set "rpc-allow-origin-all"       "$_w_rpcorigin"
  conf_set "rpc-secret"                 "$_w_rpcsecret"
  conf_set "rpc-save-upload-metadata"   "$_w_rpcsaveup"
  [ -n "$_w_rpcmaxreq" ]     && conf_set "rpc-max-request-size"        "$_w_rpcmaxreq"
  conf_set "enable-dht"                 "$_w_dht"
  conf_set "enable-dht6"                "$_w_dht6"
  conf_set "bt-enable-lpd"              "$_w_lpd"
  conf_set "bt-max-peers"               "$_w_btmaxpeers"
  conf_set "seed-ratio"                 "$_w_seedratio"
  conf_set "seed-time"                  "$_w_seedtime"
  [ -n "$_w_btstoptimeout" ] && conf_set "bt-stop-timeout"             "$_w_btstoptimeout"
  conf_set "bt-require-crypto"          "$_w_btrequirecrypto"
  conf_set "bt-hash-check-seed"         "$_w_bthashseed"
  conf_set "check-integrity"            "$_w_check"
  conf_set "check-certificate"          "$_w_checkcert"
  conf_set "log-level"                  "$_w_loglevel"
  conf_set "disable-ipv6"               "$_w_disableipv6"
  clear
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "All settings saved!"; elif [ "$LANG_SEL" = "ru" ]; then echo "Все настройки сохранены!"; else echo "Tüm ayarlar kaydedildi!"; fi)${NC}"
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  sleep 2
 }

 # GİRİŞ EKRANI
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "FULL CONFIG WIZARD"; elif [ "$LANG_SEL" = "ru" ]; then echo "МАСТЕР НАСТРОЙКИ (ВСЕ ПАРАМЕТРЫ)"; else echo "TAM CONFIG SİHİRBAZI"; fi)${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 # aria2c kurulu mu kontrol et
 if ! aria2_installed; then
  if [ "$LANG_SEL" = "en" ]; then
   echo -e " ${RED}aria2c must be installed before configuring.${NC}"
   printf " ${CYAN}Install ${GREEN}aria2c${NC}${CYAN} now?${NC} [${GREEN}Y${NC}/${RED}N${NC}]: "
  elif [ "$LANG_SEL" = "ru" ]; then
   echo -e " ${RED}Перед настройкой необходимо установить aria2c.${NC}"
   printf " ${CYAN}Установить ${GREEN}aria2c${NC}${CYAN} сейчас?${NC} [${GREEN}Д${NC}/${RED}Н${NC}]: "
  else
   echo -e " ${RED}Tüm config yapılandırması yapmadan önce aria2c kurulu olmalıdır.${NC}"
   printf " ${GREEN}aria2c${NC} ${CYAN}kurulsun mu?${NC} [${GREEN}E${NC}/${RED}H${NC}]: "
  fi
  read _inst_ans
  case "$_inst_ans" in
   [EeYy])
    install_aria2
    if ! aria2_installed; then
     echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "Installation failed. Cannot proceed."; elif [ "$LANG_SEL" = "ru" ]; then echo "Установка не удалась. Невозможно продолжить."; else echo "Kurulum başarısız. Devam edilemiyor."; fi)${NC}"
     sleep 3; return
    fi
    clear
    echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "aria2c installed! Redirecting to Full Config Wizard..."; elif [ "$LANG_SEL" = "ru" ]; then echo "aria2c установлен! Перенаправляю в мастер полной настройки..."; else echo "aria2c kuruldu! Tüm config ayarları menüsüne yönlendiriliyorsunuz..."; fi)${NC}"
    echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
    sleep 2
    ;;
   *)
    echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Installation declined. Returning to menu."; elif [ "$LANG_SEL" = "ru" ]; then echo "Установка отклонена. Возврат в меню."; else echo "Kurulum kabul edilmedi. Menüye geri dönülüyor."; fi)${NC}"
    sleep 2; return ;;
  esac
 fi

 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " Walks through all 51 aria2 settings in 8 categories."
  echo -e " ${RED}Q${NC} = quit without saving  |  ${GREEN}K${NC} = save & quit anytime"
  echo -e " ${YELLOW}Enter${NC} = keep current value"
 elif [ "$LANG_SEL" = "ru" ]; then
  echo -e " Проходит через все 51 настройку aria2 в 8 категориях."
  echo -e " ${RED}Q${NC} = выход без сохранения  |  ${GREEN}K${NC} = сохранить и выйти в любой момент"
  echo -e " ${YELLOW}Enter${NC} = сохранить текущее значение"
 else
  echo -e " 8 kategoride 51 aria2 ayarını tek tek yapılandırır."
  echo -e " ${RED}Q${NC} = kaydetmeden çık  |  ${GREEN}K${NC} = istediğiniz zaman kaydet ve çık"
  echo -e " ${YELLOW}Enter${NC} = mevcut değeri koru"
 fi
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Press Enter to begin or Q to cancel: "; elif [ "$LANG_SEL" = "ru" ]; then echo "Нажмите Enter для начала или Q для отмены: "; else echo "Başlamak için Enter, iptal için Q: "; fi)"
 read _s
 case "$_s" in [Qq]) return ;; esac

 # Mevcut değerleri oku
 _w_dir=$(conf_get "dir")
 _w_alloc=$(conf_get "file-allocation")
 _w_noalloclimit=$(conf_get "no-file-allocation-limit")
 _w_cache=$(conf_get "disk-cache")
 _w_session=$(conf_get "input-file")
 _w_savesession=$(conf_get "save-session")
 _w_saveinterval=$(conf_get "save-session-interval")
 _w_forcesave=$(conf_get "force-save")
 _w_autoremove=$(conf_get "auto-file-renaming")
 _w_overwrite=$(conf_get "allow-overwrite")
 _w_concurrent=$(conf_get "max-concurrent-downloads")
 _w_maxconn=$(conf_get "max-connection-per-server")
 _w_split=$(conf_get "split")
 _w_minsplit=$(conf_get "min-split-size")
 _w_dlimit=$(conf_get "max-overall-download-limit")
 _w_ulimit=$(conf_get "max-overall-upload-limit")
 _w_lowestspeed=$(conf_get "lowest-speed-limit")
 _w_continue=$(conf_get "continue")
 _w_alwaysresume=$(conf_get "always-resume")
 _w_timeout=$(conf_get "timeout")
 _w_conntimeout=$(conf_get "connect-timeout")
 _w_retry=$(conf_get "max-tries")
 _w_retrydelay=$(conf_get "retry-wait")
 _w_maxnotfound=$(conf_get "max-file-not-found")
 _w_useragent=$(conf_get "user-agent")
 _w_referer=$(conf_get "referer")
 _w_keepalive=$(conf_get "enable-http-keep-alive")
 _w_nocache=$(conf_get "http-no-cache")
 _w_ftptype=$(conf_get "ftp-type")
 _w_ftppasv=$(conf_get "ftp-pasv")
 _w_reuse=$(conf_get "reuse-socket")
 _w_rpc=$(conf_get "enable-rpc")
 _w_rpcport=$(conf_get "rpc-listen-port")
 _w_rpcall=$(conf_get "rpc-listen-all")
 _w_rpcorigin=$(conf_get "rpc-allow-origin-all")
 _w_rpcsecret=$(conf_get "rpc-secret")
 _w_rpcsaveup=$(conf_get "rpc-save-upload-metadata")
 _w_rpcmaxreq=$(conf_get "rpc-max-request-size")
 _w_dht=$(conf_get "enable-dht")
 _w_dht6=$(conf_get "enable-dht6")
 _w_lpd=$(conf_get "bt-enable-lpd")
 _w_btmaxpeers=$(conf_get "bt-max-peers")
 _w_seedratio=$(conf_get "seed-ratio")
 _w_seedtime=$(conf_get "seed-time")
 _w_btstoptimeout=$(conf_get "bt-stop-timeout")
 _w_btrequirecrypto=$(conf_get "bt-require-crypto")
 _w_bthashseed=$(conf_get "bt-hash-check-seed")
 _w_check=$(conf_get "check-integrity")
 _w_checkcert=$(conf_get "check-certificate")
 _w_loglevel=$(conf_get "log-level")
 _w_disableipv6=$(conf_get "disable-ipv6")

 # ══ KAT 1: DOSYA VE DİZİN ═══════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 1/8 — FILE & DIRECTORY"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 1/8 — ФАЙЛЫ И КАТАЛОГИ"; else echo "Kategori 1/8 — DOSYA VE DİZİN AYARLARI"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Controls where and how files are stored on disk."; elif [ "$LANG_SEL" = "ru" ]; then echo "Определяет где и как файлы хранятся на диске."; else echo "Dosyaların diskte nerede ve nasıl saklanacağını belirler."; fi)"

 _ask "1/51" "dir" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Default download directory."; elif [ "$LANG_SEL" = "ru" ]; then echo "Стандартная директория загрузок."; else echo "Varsayılan indirme dizini."; fi)" \
  "$_w_dir" "/tmp/mnt/usb/aria2/downloads" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_dir="$_WIZ_VAL"

 _ask "2/51" "file-allocation" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Disk space allocation method.\nnone=fastest, prealloc=FAT32, falloc=ext4/NTFS, trunc=truncate."; elif [ "$LANG_SEL" = "ru" ]; then echo "Disk space allocation method.\nnone=fastest, prealloc=FAT32, falloc=ext4/NTFS, trunc=truncate."; else echo "Disk alanı tahsis yöntemi.\nnone=en hızlı, prealloc=FAT32, falloc=ext4/NTFS, trunc=kesme."; fi)" \
  "$_w_alloc" "none" "none | prealloc | falloc | trunc"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_alloc="$_WIZ_VAL"

 _ask "3/51" "no-file-allocation-limit" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Files smaller than this skip allocation entirely."; elif [ "$LANG_SEL" = "ru" ]; then echo "Файлы меньше этого пропускают выделение места."; else echo "Bu boyuttan küçük dosyalar tahsis adımını atlar."; fi)" \
  "$_w_noalloclimit" "5M" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_noalloclimit="$_WIZ_VAL"

 _ask "4/51" "disk-cache" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "RAM buffer before writing to disk. Reduces flash wear. 0=disabled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Буфер RAM перед записью на диск. Уменьшает износ флеш. 0=отключён."; else echo "Diske yazmadan önce RAM tamponu. Flash ömrünü uzatır. 0=devre dışı."; fi)" \
  "$_w_cache" "64M" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_cache="$_WIZ_VAL"

 _ask "5/51" "input-file" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Session file. Loads incomplete downloads on startup."; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл сессии. Загружает незавершённые загрузки при старте."; else echo "Oturum dosyası. Başlangıçta yarım indirmeleri yükler."; fi)" \
  "$_w_session" "/opt/etc/aria2/aria2.session" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_session="$_WIZ_VAL"

 _ask "6/51" "save-session" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Path to save current session on exit."; elif [ "$LANG_SEL" = "ru" ]; then echo "Путь для сохранения текущей сессии при выходе."; else echo "Çıkışta mevcut oturumun kaydedileceği yol."; fi)" \
  "$_w_savesession" "/opt/etc/aria2/aria2.session" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_savesession="$_WIZ_VAL"

 _ask "7/51" "save-session-interval" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Auto-save session interval in seconds. 0=only on exit."; elif [ "$LANG_SEL" = "ru" ]; then echo "Интервал автосохранения сессии (сек). 0=только при выходе."; else echo "Oturumu otomatik kaydetme aralığı (saniye). 0=yalnızca kapanışta."; fi)" \
  "$_w_saveinterval" "60" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_saveinterval="$_WIZ_VAL"

 _ask "8/51" "force-save" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Save completed downloads to session file too. true/false."; elif [ "$LANG_SEL" = "ru" ]; then echo "Сохранять завершённые загрузки в файл сессии. true/false."; else echo "Tamamlanan indirmeleri de oturum dosyasına kaydet. true/false."; fi)" \
  "$_w_forcesave" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_forcesave="$_WIZ_VAL"

 _ask "9/51" "auto-file-renaming" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Auto-rename if file exists (.1 .2 etc). true/false."; elif [ "$LANG_SEL" = "ru" ]; then echo "Автопереименование если файл существует (.1 .2 и т.д.). true/false."; else echo "Dosya zaten varsa otomatik yeniden adlandır (.1 .2 vb.). true/false."; fi)" \
  "$_w_autoremove" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_autoremove="$_WIZ_VAL"

 _ask "10/51" "allow-overwrite" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Overwrite existing file if download already completed. true/false."; elif [ "$LANG_SEL" = "ru" ]; then echo "Перезаписать существующий файл если загрузка уже завершена. true/false."; else echo "İndirme tamamlanmışsa mevcut dosyanın üzerine yaz. true/false."; fi)" \
  "$_w_overwrite" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_overwrite="$_WIZ_VAL"

 # ══ KAT 2: BAĞLANTI VE HIZ ══════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 2/8 — CONNECTION & SPEED"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 2/8 — СОЕДИНЕНИЕ И СКОРОСТЬ"; else echo "Kategori 2/8 — BAĞLANTI VE HIZ AYARLARI"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Controls how fast and how many connections aria2 uses."; elif [ "$LANG_SEL" = "ru" ]; then echo "Управляет скоростью и количеством соединений aria2."; else echo "Bağlantı sayısı ve hız limitleri."; fi)"

 _ask "11/51" "max-concurrent-downloads" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Max simultaneous downloads."; elif [ "$LANG_SEL" = "ru" ]; then echo "Макс. одновременных загрузок."; else echo "Aynı anda çalışabilecek maksimum indirme sayısı."; fi)" \
  "$_w_concurrent" "3" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_concurrent="$_WIZ_VAL"

 _ask "12/51" "max-connection-per-server" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Connections per server simultaneously. Max 16."; elif [ "$LANG_SEL" = "ru" ]; then echo "Соединений на сервер одновременно. Макс. 16."; else echo "Her sunucuya aynı anda açılan bağlantı sayısı. Maks 16."; fi)" \
  "$_w_maxconn" "4" "1-16"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_maxconn="$_WIZ_VAL"

 _ask "13/51" "split" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Parallel segments per file."; elif [ "$LANG_SEL" = "ru" ]; then echo "Параллельных сегментов на файл."; else echo "Dosya başına paralel segment sayısı."; fi)" \
  "$_w_split" "4" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_split="$_WIZ_VAL"

 _ask "14/51" "min-split-size" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Min file size to trigger splitting."; elif [ "$LANG_SEL" = "ru" ]; then echo "Мин. размер файла для разделения на сегменты."; else echo "Bölme uygulanacak minimum dosya boyutu."; fi)" \
  "$_w_minsplit" "20M" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_minsplit="$_WIZ_VAL"

 _ask "15/51" "max-overall-download-limit" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Total download speed cap. 0=unlimited."; elif [ "$LANG_SEL" = "ru" ]; then echo "Общее ограничение скорости загрузки. 0=без ограничений."; else echo "Toplam indirme hız sınırı. 0=sınırsız."; fi)" \
  "$_w_dlimit" "0" "0 / 5M / 512K"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_dlimit="$_WIZ_VAL"

 _ask "16/51" "max-overall-upload-limit" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Total upload speed cap. 0=unlimited."; elif [ "$LANG_SEL" = "ru" ]; then echo "Общее ограничение скорости отдачи. 0=без ограничений."; else echo "Toplam yükleme hız sınırı. 0=sınırsız."; fi)" \
  "$_w_ulimit" "0" "0 / 1M / 256K"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_ulimit="$_WIZ_VAL"

 _ask "17/51" "lowest-speed-limit" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Abort if speed stays below this. 0=disabled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Прервать если скорость остаётся ниже этого. 0=отключено."; else echo "Hız çok uzun süre bunun altında kalırsa iptal et. 0=devre dışı."; fi)" \
  "$_w_lowestspeed" "0" "0 / 100K"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_lowestspeed="$_WIZ_VAL"

 _ask "18/51" "continue" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Resume partially downloaded files."; elif [ "$LANG_SEL" = "ru" ]; then echo "Продолжить частично загруженные файлы."; else echo "Kısmen indirilmiş dosyalara devam et."; fi)" \
  "$_w_continue" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_continue="$_WIZ_VAL"

 _ask "19/51" "always-resume" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Always try to resume. false=restart from scratch if resume fails."; elif [ "$LANG_SEL" = "ru" ]; then echo "Всегда пытаться продолжить. false=заново если не удалось продолжить."; else echo "Her zaman devam etmeyi dene. false=başarısız olursa baştan başla."; fi)" \
  "$_w_alwaysresume" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_alwaysresume="$_WIZ_VAL"

 # ══ KAT 3: ZAMAN AŞIMI VE YENİDEN DENEME ════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 3/8 — TIMEOUT & RETRY"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 3/8 — ТАЙМ-АУТ И ПОВТОР"; else echo "Kategori 3/8 — ZAMAN AŞIMI VE YENİDEN DENEME"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "How aria2 handles slow or failed connections."; elif [ "$LANG_SEL" = "ru" ]; then echo "Как aria2 обрабатывает медленные или неудачные соединения."; else echo "Yavaş veya başarısız bağlantılar nasıl ele alınır."; fi)"

 _ask "20/51" "timeout" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Seconds before giving up on a stalled connection."; elif [ "$LANG_SEL" = "ru" ]; then echo "Секунд до прекращения попытки зависшего соединения."; else echo "Takılı bağlantıyı bırakmadan önce bekleme süresi (sn)."; fi)" \
  "$_w_timeout" "60" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_timeout="$_WIZ_VAL"

 _ask "21/51" "connect-timeout" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Timeout for establishing a new TCP connection."; elif [ "$LANG_SEL" = "ru" ]; then echo "Тайм-аут на установление нового TCP-соединения."; else echo "Yeni TCP bağlantısı kurma zaman aşımı (sn)."; fi)" \
  "$_w_conntimeout" "60" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_conntimeout="$_WIZ_VAL"

 _ask "22/51" "max-tries" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Max retry attempts. 0=unlimited."; elif [ "$LANG_SEL" = "ru" ]; then echo "Макс. попыток. 0=без ограничений."; else echo "Maksimum yeniden deneme sayısı. 0=sınırsız."; fi)" \
  "$_w_retry" "5" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_retry="$_WIZ_VAL"

 _ask "23/51" "retry-wait" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Seconds to wait between retries."; elif [ "$LANG_SEL" = "ru" ]; then echo "Секунд ожидания между попытками."; else echo "Yeniden denemeler arası bekleme süresi (sn)."; fi)" \
  "$_w_retrydelay" "0" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_retrydelay="$_WIZ_VAL"

 _ask "24/51" "max-file-not-found" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Abort after this many 404 responses. 0=disabled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Прервать после такого количества ответов 404. 0=отключено."; else echo "Bu kadar 404 yanıtından sonra iptal et. 0=devre dışı."; fi)" \
  "$_w_maxnotfound" "2" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_maxnotfound="$_WIZ_VAL"

 # ══ KAT 4: HTTP / FTP ═══════════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 4/8 — HTTP / FTP"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 4/8 — HTTP / FTP"; else echo "Kategori 4/8 — HTTP / FTP AYARLARI"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Protocol-level tweaks for HTTP and FTP."; elif [ "$LANG_SEL" = "ru" ]; then echo "Настройки протоколов HTTP и FTP."; else echo "HTTP ve FTP protokol davranışı için ince ayarlar."; fi)"

 _ask "25/51" "user-agent" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "HTTP User-Agent. Some sites require a browser-like value."; elif [ "$LANG_SEL" = "ru" ]; then echo "HTTP User-Agent. Некоторым сайтам нужен браузерный User-Agent."; else echo "HTTP User-Agent. Bazı siteler tarayıcı benzeri değer ister."; fi)" \
  "$_w_useragent" "Mozilla/5.0" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_useragent="$_WIZ_VAL"

 _ask "26/51" "referer" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "HTTP Referer header. Leave blank for none."; elif [ "$LANG_SEL" = "ru" ]; then echo "HTTP Referer. Оставьте пустым для отправки пустого."; else echo "HTTP Referer başlığı. Boş bırakırsanız gönderilmez."; fi)" \
  "$_w_referer" "" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_referer="$_WIZ_VAL"

 _ask "27/51" "enable-http-keep-alive" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Keep HTTP connections open between requests. Improves speed."; elif [ "$LANG_SEL" = "ru" ]; then echo "Держать HTTP-соединения открытыми между запросами. Ускоряет."; else echo "İstekler arasında HTTP bağlantılarını açık tut. Hızı artırır."; fi)" \
  "$_w_keepalive" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_keepalive="$_WIZ_VAL"

 _ask "28/51" "http-no-cache" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Send Cache-Control: no-cache to bypass server caches."; elif [ "$LANG_SEL" = "ru" ]; then echo "Отправлять Cache-Control: no-cache для обхода кеша сервера."; else echo "Sunucu önbelleğini atlatmak için Cache-Control: no-cache gönder."; fi)" \
  "$_w_nocache" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_nocache="$_WIZ_VAL"

 _ask "29/51" "ftp-type" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "FTP transfer type. binary=all files, ascii=text only."; elif [ "$LANG_SEL" = "ru" ]; then echo "Тип FTP-передачи. binary=все файлы, ascii=только текст."; else echo "FTP transfer tipi. binary=tüm dosyalar, ascii=yalnızca metin."; fi)" \
  "$_w_ftptype" "binary" "binary | ascii"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_ftptype="$_WIZ_VAL"

 _ask "30/51" "ftp-pasv" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "FTP passive mode. Required behind most firewalls/NAT."; elif [ "$LANG_SEL" = "ru" ]; then echo "Пассивный режим FTP. Нужен за большинством файрволов/NAT."; else echo "FTP pasif mod. Çoğu güvenlik duvarı/NAT arkasında gereklidir."; fi)" \
  "$_w_ftppasv" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_ftppasv="$_WIZ_VAL"

 _ask "31/51" "reuse-socket" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Reuse open sockets for new requests. Reduces overhead."; elif [ "$LANG_SEL" = "ru" ]; then echo "Переиспользовать открытые сокеты для новых запросов. Снижает нагрузку."; else echo "Yeni istekler için açık soketleri yeniden kullan. Yükü azaltır."; fi)" \
  "$_w_reuse" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_reuse="$_WIZ_VAL"

 # ══ KAT 5: RPC ══════════════════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 5/8 — RPC SETTINGS"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 5/8 — НАСТРОЙКИ RPC"; else echo "Kategori 5/8 — RPC AYARLARI"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "JSON-RPC interface used by AriaNg and other WebUI clients."; elif [ "$LANG_SEL" = "ru" ]; then echo "Интерфейс JSON-RPC для AriaNg и других WebUI-клиентов."; else echo "AriaNg ve diğer WebUI istemcilerinin kullandığı JSON-RPC arayüzü."; fi)"

 _ask "32/51" "enable-rpc" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Enable JSON-RPC server. Required for AriaNg."; elif [ "$LANG_SEL" = "ru" ]; then echo "Включить JSON-RPC сервер. Обязательно для AriaNg."; else echo "JSON-RPC sunucusunu etkinleştir. AriaNg için gereklidir."; fi)" \
  "$_w_rpc" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpc="$_WIZ_VAL"

 _ask "33/51" "rpc-listen-port" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Port for the RPC server. Default 6800."; elif [ "$LANG_SEL" = "ru" ]; then echo "Порт RPC сервера. По умолчанию 6800."; else echo "RPC sunucusunun dinleyeceği port. Varsayılan 6800."; fi)" \
  "$_w_rpcport" "6800" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcport="$_WIZ_VAL"

 _ask "34/51" "rpc-listen-all" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Accept RPC from all interfaces. true=all, false=localhost only."; elif [ "$LANG_SEL" = "ru" ]; then echo "Принимать RPC со всех интерфейсов. true=все, false=localhost."; else echo "Tüm ağ arayüzlerinden RPC kabul et. true=hepsi, false=yalnızca localhost."; fi)" \
  "$_w_rpcall" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcall="$_WIZ_VAL"

 _ask "35/51" "rpc-allow-origin-all" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Allow CORS from all origins. Required for browser-based WebUIs."; elif [ "$LANG_SEL" = "ru" ]; then echo "Разрешить CORS от всех источников. Нужно для браузерных WebUI."; else echo "Tüm kaynaklardan CORS'a izin ver. Tarayıcı tabanlı WebUI için gerekli."; fi)" \
  "$_w_rpcorigin" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcorigin="$_WIZ_VAL"

 _ask "36/51" "rpc-secret" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "RPC auth token. Clients send as Bearer token. Blank=no auth."; elif [ "$LANG_SEL" = "ru" ]; then echo "Токен авторизации RPC. Клиенты отправляют как Bearer. Пусто=без авторизации."; else echo "RPC kimlik doğrulama anahtarı. Boş=doğrulama yok."; fi)" \
  "$_w_rpcsecret" "MySecret123" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcsecret="$_WIZ_VAL"

 _ask "37/51" "rpc-save-upload-metadata" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Save metadata of torrent/metalink files added via RPC."; elif [ "$LANG_SEL" = "ru" ]; then echo "Сохранять метаданные torrent/metalink файлов добавленных через RPC."; else echo "RPC üzerinden eklenen torrent/metalink meta verilerini kaydet."; fi)" \
  "$_w_rpcsaveup" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcsaveup="$_WIZ_VAL"

 _ask "38/51" "rpc-max-request-size" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Max RPC request body size. Increase if adding many URLs at once."; elif [ "$LANG_SEL" = "ru" ]; then echo "Макс. размер тела RPC-запроса. Увеличьте при добавлении множества URL."; else echo "Maksimum RPC istek boyutu. Çok URL ekleyecekseniz artırın."; fi)" \
  "$_w_rpcmaxreq" "2M" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_rpcmaxreq="$_WIZ_VAL"

 # ══ KAT 6: BİTTORRENT ═══════════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 6/8 — BITTORRENT"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 6/8 — BITTORRENT"; else echo "Kategori 6/8 — BİTTORRENT AYARLARI"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Settings for .torrent and magnet link downloads."; elif [ "$LANG_SEL" = "ru" ]; then echo "Настройки загрузок .torrent и magnet-ссылок."; else echo ".torrent ve magnet link indirmeleri için ayarlar."; fi)"

 _ask "39/51" "enable-dht" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "DHT for trackerless torrents."; elif [ "$LANG_SEL" = "ru" ]; then echo "DHT для торрентов без трекера."; else echo "İzleyicisiz torrentler için DHT."; fi)" \
  "$_w_dht" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_dht="$_WIZ_VAL"

 _ask "40/51" "enable-dht6" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "IPv6 DHT. Only useful if router has a public IPv6 address."; elif [ "$LANG_SEL" = "ru" ]; then echo "IPv6 DHT. Полезно только если у роутера есть публичный IPv6."; else echo "IPv6 DHT. Yalnızca yönlendiricinizin genel IPv6 adresi varsa kullanışlıdır."; fi)" \
  "$_w_dht6" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_dht6="$_WIZ_VAL"

 _ask "41/51" "bt-enable-lpd" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Local Peer Discovery — find peers on LAN without a tracker."; elif [ "$LANG_SEL" = "ru" ]; then echo "Локальный поиск пиров — поиск пиров в LAN без трекера."; else echo "Yerel Eş Keşfi — izleyici olmadan LAN'daki eşleri bul."; fi)" \
  "$_w_lpd" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_lpd="$_WIZ_VAL"

 _ask "42/51" "bt-max-peers" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Max peers per torrent. 0=unlimited. Lower on routers to save RAM."; elif [ "$LANG_SEL" = "ru" ]; then echo "Макс. пиров на торрент. 0=без ограничений. Снижайте на роутерах для экономии RAM."; else echo "Torrent başına maks peer. 0=sınırsız. Yönlendiricide RAM için düşürün."; fi)" \
  "$_w_btmaxpeers" "55" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_btmaxpeers="$_WIZ_VAL"

 _ask "43/51" "seed-ratio" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Stop seeding at this upload/download ratio. 0.0=forever."; elif [ "$LANG_SEL" = "ru" ]; then echo "Остановить раздачу при этом соотношении отдачи/загрузки. 0.0=навсегда."; else echo "Bu orana ulaşınca seed dur. 0.0=süresiz."; fi)" \
  "$_w_seedratio" "1.0" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_seedratio="$_WIZ_VAL"

 _ask "44/51" "seed-time" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Stop seeding after this many minutes. 0=no limit."; elif [ "$LANG_SEL" = "ru" ]; then echo "Остановить раздачу через столько минут. 0=без ограничений."; else echo "Bu kadar dakika sonra seed dur. 0=süre sınırı yok."; fi)" \
  "$_w_seedtime" "0" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_seedtime="$_WIZ_VAL"

 _ask "45/51" "bt-stop-timeout" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Stop torrent if no progress for this many seconds. 0=disabled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Остановить торрент если нет прогресса столько секунд. 0=отключено."; else echo "Bu kadar saniye ilerleme olmazsa torrent dur. 0=devre dışı."; fi)" \
  "$_w_btstoptimeout" "0" ""
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_btstoptimeout="$_WIZ_VAL"

 _ask "46/51" "bt-require-crypto" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Only connect to encrypted peers. Hides traffic from ISP."; elif [ "$LANG_SEL" = "ru" ]; then echo "Подключаться только к зашифрованным пирам. Скрывает трафик от провайдера."; else echo "Yalnızca şifreli eşlere bağlan. Trafiği ISP'den gizler."; fi)" \
  "$_w_btrequirecrypto" "false" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_btrequirecrypto="$_WIZ_VAL"

 _ask "47/51" "bt-hash-check-seed" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Verify piece hashes before seeding. Catches corrupted files."; elif [ "$LANG_SEL" = "ru" ]; then echo "Проверять хеши частей перед раздачей. Обнаруживает повреждённые файлы."; else echo "Seed yapmadan önce parça hash'lerini doğrula. Bozuk dosyaları yakalar."; fi)" \
  "$_w_bthashseed" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_bthashseed="$_WIZ_VAL"

 # ══ KAT 7: GÜVENLİK ═════════════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 7/8 — SECURITY & INTEGRITY"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 7/8 — БЕЗОПАСНОСТЬ И ЦЕЛОСТНОСТЬ"; else echo "Kategori 7/8 — GÜVENLİK VE DOĞRULAMA"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Verifying downloads and securing connections."; elif [ "$LANG_SEL" = "ru" ]; then echo "Проверка загрузок и защита соединений."; else echo "İndirmeleri doğrulama ve bağlantıları güvenli hale getirme."; fi)"

 _ask "48/51" "check-integrity" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Verify checksum after download if available."; elif [ "$LANG_SEL" = "ru" ]; then echo "Проверять контрольную сумму после загрузки если доступна."; else echo "Varsa indirme sonrası sağlama toplamını doğrula."; fi)" \
  "$_w_check" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_check="$_WIZ_VAL"

 _ask "49/51" "check-certificate" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Verify HTTPS SSL/TLS certificate. false=skip (common on routers)."; elif [ "$LANG_SEL" = "ru" ]; then echo "Проверять HTTPS SSL/TLS сертификат. false=пропустить (обычно на роутерах)."; else echo "HTTPS SSL/TLS sertifikasını doğrula. false=atla (yönlendiricide yaygın)."; fi)" \
  "$_w_checkcert" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_checkcert="$_WIZ_VAL"

 # ══ KAT 8: LOG VE GELİŞMİŞ ══════════════════════════
 _wiz_cat \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Category 8/8 — LOG & ADVANCED"; elif [ "$LANG_SEL" = "ru" ]; then echo "Категория 8/8 — ЛОГ И ДОП. НАСТРОЙКИ"; else echo "Kategori 8/8 — LOG VE GELİŞMİŞ AYARLAR"; fi)" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Logging verbosity and network stack settings."; elif [ "$LANG_SEL" = "ru" ]; then echo "Детализация лога и настройки сетевого стека."; else echo "Log ayrıntı düzeyi ve ağ yığını ayarları."; fi)"

 _ask "50/51" "log-level" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Log verbosity. debug=most, error=least."; elif [ "$LANG_SEL" = "ru" ]; then echo "Детализация лога. debug=максимум, error=минимум."; else echo "Log ayrıntı düzeyi. debug=en fazla, error=en az."; fi)" \
  "$_w_loglevel" "warn" "debug | info | notice | warn | error"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_loglevel="$_WIZ_VAL"

 _ask "51/51" "disable-ipv6" \
  "$(if [ "$LANG_SEL" = "en" ]; then echo "Disable IPv6 DNS resolution. Recommended on most Keenetic setups."; elif [ "$LANG_SEL" = "ru" ]; then echo "Отключить IPv6 DNS. Рекомендуется на большинстве Keenetic."; else echo "IPv6 DNS çözümlemesini devre dışı bırak. Çoğu Keenetic kurulumunda önerilir."; fi)" \
  "$_w_disableipv6" "true" "true | false"
 case "$_WIZ_VAL" in [Qq]) return ;; [Kk]) _wizard_save; return ;; esac
 [ -n "$_WIZ_VAL" ] && _w_disableipv6="$_WIZ_VAL"

 _wizard_save
}

settings_menu() {
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_SETTINGS_TITLE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 [ "$LANG_SEL" = "en" ] && local _SW=22 || local _SW=18
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_DL_DIR" $_SW)" "$(conf_get "dir")"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_CONCURRENT" $_SW)" "$(conf_get "max-concurrent-downloads")"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_MAX_CONN" $_SW)" "$(conf_get "max-connection-per-server")"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_SPLIT" $_SW)" "$(conf_get "split")"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_DL_SPEED" $_SW)" "$(conf_get "max-overall-download-limit") (${L_SET_UNLIMITED})"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_UL_SPEED" $_SW)" "$(conf_get "max-overall-upload-limit") (${L_SET_UNLIMITED})"
 _s_rpc_en=$(conf_get "enable-rpc"); _s_rpc_port=$(conf_get "rpc-listen-port"); _s_rpc_port="${_s_rpc_port:-6800}"
 if [ "$_s_rpc_en" = "true" ]; then
 _s_rpc_lbl="$(if [ "$LANG_SEL" = "en" ]; then echo "ON"; elif [ "$LANG_SEL" = "ru" ]; then echo "ВКЛ"; else echo "AÇIK"; fi)"
 printf " %s : ${GREEN}%s${NC} ${CYAN}(port: %s)${NC}\n" "$(pad_label "$L_SET_RPC" $_SW)" "$_s_rpc_lbl" "$_s_rpc_port"
 else
 _s_rpc_lbl="$(if [ "$LANG_SEL" = "en" ]; then echo "OFF"; elif [ "$LANG_SEL" = "ru" ]; then echo "ВЫКЛ"; else echo "KAPALI"; fi)"
 printf " %s : ${RED}%s${NC} ${CYAN}(port: %s)${NC}\n" "$(pad_label "$L_SET_RPC" $_SW)" "$_s_rpc_lbl" "$_s_rpc_port"
 fi
 RPC_SEC=$(conf_get "rpc-secret")
 [ -n "$RPC_SEC" ] && SEC_DISP="${GREEN}${L_SET_CONFIGURED}${NC}" || SEC_DISP="${RED}${L_SET_EMPTY}${NC}"
 printf " %s : %b\n" "$(pad_label "$L_SET_RPC_SECRET" $_SW)" "$SEC_DISP"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_ALLOC" $_SW)" "$(conf_get "file-allocation")"
 printf " %s : ${CYAN}%s${NC}\n" "$(pad_label "$L_SET_LOG_LEVEL" $_SW)" "$(conf_get "log-level")"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${DIM_CYAN}── ${L_HDR_ABOUT} ──────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " Configure all aria2 settings without needing any external tool."
  echo -e " ${GREEN}(C) Menu — for users who prefer not to use AriaNg WebUI — all settings${NC}"
  echo -e " ${GREEN}can be configured right here through this manager.${NC}"
  echo -e " For ${YELLOW}8${NC} categories and ${YELLOW}51${NC} settings open ${CYAN}C) Full Config Wizard${NC}."
 elif [ "$LANG_SEL" = "ru" ]; then
  echo -e " Настройте все параметры aria2 без необходимости в сторонних инструментах."
  echo -e " ${GREEN}Меню (C) — для тех, кто предпочитает не использовать AriaNg WebUI — все параметры${NC}"
  echo -e " ${GREEN}можно настроить прямо здесь через этот менеджер.${NC}"
  echo -e " Для ${YELLOW}8${NC} категорий и ${YELLOW}51${NC} параметров откройте ${CYAN}C) Мастер полной настройки${NC}."
 else
  echo -e " aria2'nin tüm ayarlarını başka bir araca gerek duymadan yapılandırabilirsiniz."
  echo -e " ${GREEN}(C) Menüsü AriaNg Web arayüzü kullanmak istemeyenler için) tüm ayarları${NC}"
  echo -e " ${GREEN}bu manager üzerinden yapabilmeniz için tasarlanmıştır.${NC}"
  echo -e " ${YELLOW}8${NC} kategoride ${YELLOW}51${NC} ayar için ${CYAN}C) Tüm config ayarları${NC} menüsünü açınız."
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${L_SET_CHANGE_DIR}"
 echo -e " ${YELLOW}2)${NC} ${L_SET_CONN}"
 echo -e " ${YELLOW}3)${NC} ${L_SET_SPEED}"
 echo -e " ${YELLOW}4)${NC} ${L_SET_RPC_MENU}"
 echo -e " ${YELLOW}5)${NC} ${L_SET_ALLOC_MENU}"
 echo -e " ${YELLOW}6)${NC} ${L_SET_LOG_MENU}"
 echo -e " ${YELLOW}7)${NC} ${L_SET_SHOW_CONF}"
 echo -e " ${YELLOW}8)${NC} ${RED}${L_SET_RESET_CONF}${NC}"
 if [ "$_s_rpc_en" = "true" ]; then
 echo -e " ${YELLOW}R)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_s_rpc_port}) ${GREEN}ON${NC}"; elif [ "$LANG_SEL" = "ru" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_s_rpc_port}) ${GREEN}ON${NC}"; else echo "RPC ${GREEN}Aç${NC}/${RED}Kapat${NC} (port: ${_s_rpc_port}) ${GREEN}AÇIK${NC}"; fi)"
 else
 echo -e " ${YELLOW}R)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_s_rpc_port}) ${RED}OFF${NC}"; elif [ "$LANG_SEL" = "ru" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_s_rpc_port}) ${RED}OFF${NC}"; else echo "RPC ${GREEN}Aç${NC}/${RED}Kapat${NC} (port: ${_s_rpc_port}) ${RED}KAPALI${NC}"; fi)"
 fi
 echo -e " ${YELLOW}C)${NC} ${CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Full Config Wizard (all settings)"; elif [ "$LANG_SEL" = "ru" ]; then echo "Full Config Wizard (all settings)"; else echo "Tüm config ayarlarını yap"; fi)${NC}"
 echo -e " ${YELLOW}0)${NC} ${L_SET_BACK}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-8, R, C]: ${NC}"; read schoice
 case "$schoice" in
 1) set_download_dir ;;
 2) set_connection_settings ;;
 3) set_speed_limits ;;
 4) set_rpc_settings ;;
 r|R) toggle_rpc_enabled ;;
 c|C) full_config_wizard ;;
 5) set_file_allocation ;;
 6) set_log_settings ;;
 7)
 clear
 echo -e "${CYAN}${BOLD}[ ${L_CONF_FILE}: $ARIA2_CONF ]${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ -f "$ARIA2_CONF" ]; then cat "$ARIA2_CONF"
 else echo -e "${RED}${L_CONF_NOT_FOUND}${NC}"; fi
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${YELLOW}${L_PRESS_ENTER}${NC}"; read _
 ;;
 8)
 printf "${RED}${L_CONF_RESET_Q}${NC}"; read rst_conf
 if [ "$rst_conf" = "$L_CONFIRM_YES" ] || [ "$rst_conf" = "$L_CONFIRM_YES2" ]; then
 create_default_config; sleep 2
 fi
 ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
 done
}

set_download_dir() {
 clear
 echo -e "${CYAN}${BOLD}[ ${L_SET_CHANGE_DIR} ]${NC}"
 echo -e " ${L_CURRENT}: ${CYAN}$(conf_get "dir")${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_SCANNING_USB}${NC}"; USB_MOUNTS=$(detect_usb)
 if [ -n "$USB_MOUNTS" ]; then
 echo -e "${GREEN}${L_USB_DETECTED2}${NC}"; i=1
 for mp in $USB_MOUNTS; do
 FREE=$(df -h "$mp" 2>/dev/null | awk 'NR==2{print $4}')
 echo -e " ${YELLOW}$i)${NC} $mp ${CYAN}[${L_USB_FREE}: ${FREE:-?}]${NC}"; i=$((i + 1))
 done
 echo ""; printf "${YELLOW}${L_CHOICE_PROMPT} (1-$((i-1))): ${NC}"; read dir_sel
 DISK_SELECTED=$(echo "$USB_MOUNTS" | tr ' ' '\n' | grep -v '^$' | sed -n "${dir_sel}p")
 if [ -n "$DISK_SELECTED" ]; then
 DEFAULT_DL_PATH="${DISK_SELECTED}/aria2/downloads"
 echo ""
 echo -e "${YELLOW} ${L_FOLDER_DEFAULT_INFO}${NC}"
 echo -e " ${CYAN}→ ${DEFAULT_DL_PATH}${NC}"
 printf "${YELLOW}${L_FOLDER_CHANGE_Q}${NC}"; read fld_ans
 if [ "$fld_ans" = "$L_CONFIRM_YES" ] || [ "$fld_ans" = "$L_CONFIRM_YES2" ]; then
 printf "${YELLOW}${L_FOLDER_PROMPT}${NC}"; read custom_folder
 if [ -n "$custom_folder" ]; then
 custom_folder=$(echo "$custom_folder" | sed 's|^/||')
 new_dir="${DISK_SELECTED}/${custom_folder}"
 else
 new_dir="${DEFAULT_DL_PATH}"
 fi
 else
 new_dir="${DEFAULT_DL_PATH}"
 fi
 else
 echo -e "${YELLOW}${L_USB_NONE}${NC}"
 printf "${YELLOW}$(if [ "$LANG_SEL" = "en" ]; then echo "Download directory (full path): "; elif [ "$LANG_SEL" = "ru" ]; then echo "Директория загрузок (полный путь): "; else echo "İndirme dizini (tam yol): "; fi)${NC}"; read new_dir
 fi
 else
 echo -e "${YELLOW}${L_USB_NONE}${NC}"
 printf "${YELLOW}$(if [ "$LANG_SEL" = "en" ]; then echo "Download directory (full path): "; elif [ "$LANG_SEL" = "ru" ]; then echo "Директория загрузок (полный путь): "; else echo "İndirme dizini (tam yol): "; fi)${NC}"; read new_dir
 fi
 if [ -n "$new_dir" ]; then
 [ ! -d "$new_dir" ] && mkdir -p "$new_dir" 2>/dev/null
 conf_set "dir" "$new_dir"; echo -e "${GREEN} ${L_DL_DIR_SET} $new_dir${NC}"
 fi
 sleep 2
}

set_connection_settings() {
 clear; echo -e "${CYAN}${BOLD}[ ${L_CONN_TITLE} ]${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_CONN_HINT}${NC}"; echo ""
 printf "${YELLOW}${L_CONN_CONCURRENT}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "max-concurrent-downloads")]${NC}: "; read val; [ -n "$val" ] && conf_set "max-concurrent-downloads" "$val"
 printf "${YELLOW}${L_CONN_MAXCONN}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "max-connection-per-server")]${NC}: "; read val; [ -n "$val" ] && conf_set "max-connection-per-server" "$val"
 printf "${YELLOW}${L_CONN_SPLIT}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "split")]${NC}: "; read val; [ -n "$val" ] && conf_set "split" "$val"
 printf "${YELLOW}${L_CONN_MINSPLIT}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "min-split-size")]${NC}: "; read val; [ -n "$val" ] && conf_set "min-split-size" "$val"
 printf "${YELLOW}${L_CONN_CACHE}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "disk-cache")]${NC}: "; read val; [ -n "$val" ] && conf_set "disk-cache" "$val"
 echo -e "${GREEN} ${L_CONN_UPDATED}${NC}"; sleep 2
}

set_speed_limits() {
 clear; echo -e "${CYAN}${BOLD}[ ${L_SPEED_TITLE} ]${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_SPEED_HINT}${NC}"; echo -e "${YELLOW} ${L_SPEED_EXAMPLE}${NC}"; echo ""
 printf "${YELLOW}${L_SPEED_DL}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "max-overall-download-limit")]${NC}: "; read val; [ -n "$val" ] && conf_set "max-overall-download-limit" "$val"
 printf "${YELLOW}${L_SPEED_UL}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "max-overall-upload-limit")]${NC}: "; read val; [ -n "$val" ] && conf_set "max-overall-upload-limit" "$val"
 echo -e "${GREEN} ${L_SPEED_UPDATED}${NC}"; sleep 2
}

set_rpc_settings() {
 clear; echo -e "${CYAN}${BOLD}[ ${L_RPC_TITLE} ]${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${YELLOW} ${L_RPC_HINT2}${NC}"; echo ""
 printf "${YELLOW}${L_RPC_ENABLE}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "enable-rpc")]${NC}: "; read val; [ -n "$val" ] && conf_set "enable-rpc" "$val"
 printf "${YELLOW}${L_RPC_PORT2}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "rpc-listen-port")]${NC}: "; read val; [ -n "$val" ] && conf_set "rpc-listen-port" "$val"
 _cur_sec=$(conf_get "rpc-secret" 2>/dev/null)
 echo -e "${YELLOW} ${L_RPC_SECRET_LABEL}: ${CYAN}${_cur_sec:-[${L_NOT_SET}]}${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 printf "${YELLOW}${L_RPC_SECRET2} (blank = auto-generate, 'clear' = remove): ${NC}"
 elif [ "$LANG_SEL" = "ru" ]; then
 printf "${YELLOW}${L_RPC_SECRET2} (пусто = автогенерация, 'clear' = удалить): ${NC}"
 else
 printf "${YELLOW}${L_RPC_SECRET2} (boş = otomatik üret, 'sil' = kaldır): ${NC}"
 fi
 read val
 if [ "$val" = "clear" ] || [ "$val" = "sil" ]; then
 sed -i '/^rpc-secret=/d' "$ARIA2_CONF" 2>/dev/null
 echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "RPC secret removed — authentication disabled!"; elif [ "$LANG_SEL" = "ru" ]; then echo "Секрет RPC удалён — авторизация отключена!"; else echo "RPC secret kaldırıldı — güvenlik riski oluşabilir!"; fi)${NC}"
 elif [ -z "$val" ]; then
 # Boş bırakılırsa otomatik üret
 _new_sec=$(gen_rpc_secret)
 conf_set "rpc-secret" "$_new_sec"
 echo -e "${GREEN} ${L_RPC_SECRET_LABEL}: ${YELLOW}${_new_sec}${NC}"
 tg_notify "secret_key" "$_new_sec"
 else
 conf_set "rpc-secret" "$val"
 echo -e "${GREEN} ${L_RPC_SECRET_LABEL}: ${YELLOW}${val}${NC}"
 tg_notify "secret_key" "$val"
 fi
 printf "${YELLOW}${L_RPC_ALL}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "rpc-listen-all")]${NC}: "; read val; [ -n "$val" ] && conf_set "rpc-listen-all" "$val"
 printf "${YELLOW}${L_RPC_ORIGIN}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "rpc-allow-origin-all")]${NC}: "; read val; [ -n "$val" ] && conf_set "rpc-allow-origin-all" "$val"
 echo -e "${GREEN} ${L_RPC_UPDATED}${NC}"; sleep 2
}

set_file_allocation() {
 clear; echo -e "${CYAN}${BOLD}[ ${L_ALLOC_TITLE} ]${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${CYAN}none${NC} - ${L_ALLOC_NONE}"
 echo -e " ${YELLOW}2)${NC} ${CYAN}prealloc${NC} - ${L_ALLOC_PREALLOC} ${MAGENTA}(FAT32)${NC}"
 echo -e " ${YELLOW}3)${NC} ${CYAN}falloc${NC} - ${L_ALLOC_FALLOC} ${MAGENTA}(ext4/NTFS)${NC}"
 echo -e " ${YELLOW}4)${NC} ${CYAN}trunc${NC} - ${L_ALLOC_TRUNC}"
 echo ""; echo -e " ${L_ALLOC_CURRENT}: ${CYAN}$(conf_get "file-allocation")${NC}"; echo ""
 printf "${YELLOW}${L_ALLOC_PROMPT}${NC}"; read fa_sel
 case "$fa_sel" in
 1) conf_set "file-allocation" "none"; echo -e "${GREEN} none${NC}" ;;
 2) conf_set "file-allocation" "prealloc"; echo -e "${GREEN} prealloc${NC}" ;;
 3) conf_set "file-allocation" "falloc"; echo -e "${GREEN} falloc${NC}" ;;
 4) conf_set "file-allocation" "trunc"; echo -e "${GREEN} trunc${NC}" ;;
 "") echo -e "${YELLOW}${L_ALLOC_NOCHANGE}${NC}" ;;
 *) echo -e "${RED} ${L_INVALID}${NC}" ;;
 esac
 sleep 2
}

set_log_settings() {
 clear; echo -e "${CYAN}${BOLD}[ ${L_LOG_TITLE} ]${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf "${YELLOW}${L_LOG_PATH}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "log")]${NC}: "; read val; [ -n "$val" ] && conf_set "log" "$val"
 echo ""; echo -e "${YELLOW}${L_LOG_LEVEL2}:${NC}"
 echo -e " ${YELLOW}${L_LOG_LEVELS}${NC}"
 printf "${YELLOW}${L_CHOICE_PROMPT}${NC} ${CYAN}[${L_CURRENT}: $(conf_get "log-level"), ${L_BLANK_SKIP}]${NC}: "; read log_sel
 case "$log_sel" in
 1) conf_set "log-level" "debug" ;; 2) conf_set "log-level" "info" ;;
 3) conf_set "log-level" "notice" ;; 4) conf_set "log-level" "warn" ;;
 5) conf_set "log-level" "error" ;;
 esac
 echo -e "${GREEN} ${L_LOG_UPDATED}${NC}"; sleep 2
}

# ============================================
# GÜNCELLEME / UPDATE
# ============================================
check_update() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_UPDATE_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${YELLOW} ${L_UPDATE_CONNECTING}${NC}"
 TMP_FILE="/tmp/keenetic-aria2-manager_update.sh"
 curl -fsSL --connect-timeout 15 "$UPDATE_URL" -o "$TMP_FILE" 2>/dev/null
 if [ ! -f "$TMP_FILE" ] || [ ! -s "$TMP_FILE" ]; then
 echo -e "${RED} ${L_UPDATE_FAIL}${NC}"
 echo -e "${YELLOW}${L_UPDATE_CHECK_URL} $UPDATE_URL${NC}"
 rm -f "$TMP_FILE" 2>/dev/null; sleep 3; return
 fi
 REMOTE_VERSION=$(grep -m1 '^SCRIPT_VERSION=' "$TMP_FILE" 2>/dev/null | cut -d'"' -f2)
 if [ -z "$REMOTE_VERSION" ]; then
 echo -e "${RED} ${L_UPDATE_NO_VER}${NC}"; rm -f "$TMP_FILE"; sleep 3; return
 fi
 echo -e " ${L_UPDATE_CURR} : ${YELLOW}$SCRIPT_VERSION${NC}"
 echo -e " ${L_UPDATE_REMOTE}: ${GREEN}$REMOTE_VERSION${NC}"; echo ""
 if [ "$SCRIPT_VERSION" != "$REMOTE_VERSION" ]; then
 echo -e "${GREEN} ${L_UPDATE_AVAIL}${NC}"
 printf "${YELLOW}${L_UPDATE_Q}${NC}"; read ans
 if yes_answer "$ans"; then
 echo -e "${YELLOW}⏳ ${L_UPDATE_IN_PROGRESS}${NC}"
 was_running=false
 if status_check; then
 was_running=true; echo -e "${YELLOW}${L_UPDATE_STOPPING}${NC}"; stop_service_silent
 fi
 rm -f "$LOCK_FILE"; mv -f "$TMP_FILE" "$SCRIPT_PATH"
 # Windows CRLF (\r) satır sonlarını temizle / Strip Windows CRLF line endings
 sed -i 's/\r//' "$SCRIPT_PATH" 2>/dev/null
 chmod +x "$SCRIPT_PATH"; create_shortcuts
 echo -e "${GREEN} ${L_UPDATE_DONE} $REMOTE_VERSION${NC}"
 if [ "$was_running" = "true" ]; then
 echo -e "${YELLOW}${L_UPDATE_RESTARTING}${NC}"
 sh "$SCRIPT_PATH" --start-daemon >/dev/null 2>&1 &
 sleep 2
 if status_check; then echo -e "${GREEN} ${L_UPDATE_RESTART_OK}${NC}"
 else echo -e "${RED} ${L_UPDATE_RESTART_FAIL}${NC}"; fi
 fi
 sleep 2; exec sh "$SCRIPT_PATH"
 else
 echo -e "${YELLOW}${L_UPDATE_CANCEL}${NC}"; rm -f "$TMP_FILE"; sleep 2
 fi
 else
 echo -e "${GREEN} ${L_UPDATE_LATEST} ($SCRIPT_VERSION).${NC}"; rm -f "$TMP_FILE"; sleep 3
 fi
}

# ============================================
# TAM KALDIRMA / FULL UNINSTALL
# ============================================

_check_and_delete_backups() {
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e "${CYAN} Checking backups...${NC}"
 else
  echo -e "${CYAN} Yedekler denetleniyor...${NC}"
 fi
 sleep 1
 _bfiles=$(ls "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null)
 if [ -z "$_bfiles" ]; then
  if [ "$LANG_SEL" = "en" ]; then
   echo -e " ${GREEN}You have no backups. No backups will be deleted.${NC}"
  else
   echo -e " ${GREEN}Almış olduğunuz herhangi bir yedeğiniz yok. Herhangi bir yedek silinmeyecek.${NC}"
  fi
  sleep 2
  return
 fi
 _bcount=$(echo "$_bfiles" | wc -l)
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${YELLOW}${_bcount} backup(s) found:${NC}"
 else
  echo -e " ${YELLOW}${_bcount} adet yedek bulundu:${NC}"
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 _i=1
 for _f in $_bfiles; do
  _fname=$(basename "$_f")
  _fsize=$(du -sh "$_f" 2>/dev/null | cut -f1)
  _fdate=$(echo "$_fname" | sed 's/aria2manager_backup_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)_.*/\3.\2.\1 \4:\5/')
  if echo "$_fname" | grep -q "_basic"; then
   _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi)"
   _fcolor="${CYAN}"
  else
   _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi)"
   _fcolor="${GREEN}"
  fi
  echo -e " ${YELLOW}${_i})${NC} ${_fname}"
  echo -e "    ${_fcolor}${_ftype}${NC}  │  ${_fdate}  │  ${_fsize}"
  _i=$((_i+1))
 done
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${RED}Delete your backups? They will be permanently lost!${NC}"
  printf " ${YELLOW}E${NC}=Delete  ${GREEN}H${NC}=Keep (default): "
 else
  echo -e " ${RED}Yedekleriniz silinsin mi? Kalıcı olarak kaybolacak!${NC}"
  printf " ${YELLOW}E${NC}=Siler  ${GREEN}H${NC}=Saklar (varsayılan boş bırak=saklar): "
 fi
 read _bkans
 case "$_bkans" in
  [Ee])
   rm -f "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null
   rmdir "$BACKUP_DIR" 2>/dev/null
   if [ "$LANG_SEL" = "en" ]; then
    echo -e "${RED} All backups deleted.${NC}"
   else
    echo -e "${RED} Tüm yedekler silindi.${NC}"
   fi
   sleep 2
   ;;
  *)
   if [ "$LANG_SEL" = "en" ]; then
    echo -e "${GREEN} Backups kept. They are safe at: ${BACKUP_DIR}${NC}"
   else
    echo -e "${GREEN} Yedekler saklandı. Konum: ${BACKUP_DIR}${NC}"
   fi
   sleep 2
   ;;
 esac
}

uninstall_manager() {
 clear
 echo -e "${RED}${BOLD}════════════════════════════════════════════════════${NC}"
 echo -e "${RED}${BOLD} ${L_FULL_UNINSTALL_TITLE}${NC}"
 echo -e "${RED}${BOLD}════════════════════════════════════════════════════${NC}"
 echo -e " ${YELLOW}${L_FULL_UNINSTALL_INFO}${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${RED}•${NC} ${CYAN}aria2 service${NC} ${RED}(stopped + removed via opkg)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}All config files and logs${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Autostart file${NC} ${RED}(init.d)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Shortcuts${NC} ${RED}(aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}This manager script${NC}"
  echo -e " ${RED}•${NC} ${CYAN}AriaNg WebUI${NC} ${RED}(files + lighttpd config + autostart)${NC}"
 else
  echo -e " ${RED}•${NC} ${CYAN}aria2 servisi${NC} ${RED}(durdurulur + opkg ile kaldırılır)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Tüm config dosyaları ve loglar${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Otomatik başlatma dosyası${NC} ${RED}(init.d)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Kısayollar${NC} ${RED}(aria2m, a2m, k2m, kam, keeneticaria2, aria2manager, soulsaria2)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Bu manager betiği${NC}"
  echo -e " ${RED}•${NC} ${CYAN}AriaNg WebUI${NC} ${RED}(dosyalar + lighttpd config + oto başlatma)${NC}"
 fi
 echo ""
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${CYAN}This removal will also check:${NC}"
  echo -e " ${RED}•${NC} Your backups — will be ${RED}deleted${NC} or ${GREEN}kept${NC} based on your choice"
  echo -e " ${RED}•${NC} Installed add-ons (lighttpd, curl, etc.) used by other scripts"
  echo -e "   will be scanned — ${RED}removed${NC} or ${GREEN}kept${NC} based on your choice"
 else
  echo -e " ${CYAN}Bu silme işlemi ayrıca şunları denetler:${NC}"
  echo -e " ${RED}•${NC} Almış olduğunuz yedekler — onayınızla ${RED}silinir${NC} veya ${GREEN}saklanır${NC}"
  echo -e " ${RED}•${NC} Yüklü eklentiler (lighttpd, curl vb.) diğer betikler tarafından"
  echo -e "   kullanılıp kullanılmadığı taranır — seçiminize bağlı ${RED}kaldırılır${NC} veya ${GREEN}saklanır${NC}"
 fi
 echo ""
 if [ "$LANG_SEL" = "en" ]; then
  printf "${CYAN}Type ${RED}REMOVE${NC}${CYAN} to confirm full uninstall: ${NC}"; read confirm
 else
  printf "${CYAN}Tam kaldırmayı onaylamak için ${RED}SİL${NC}${CYAN} yazın: ${NC}"; read confirm
 fi
 if [ "$confirm" != "$L_FULL_UNINSTALL_CONFIRM_WORD" ]; then
 echo -e "${YELLOW}${L_FULL_UNINSTALL_CANCEL}${NC}"; sleep 2; return
 fi

 # Yedek kontrolü
 _check_and_delete_backups

 # İndirilen dosyalar hakkında sor
 DL_DIR=$(conf_get "dir")
 if [ -n "$DL_DIR" ] && [ -d "$DL_DIR" ]; then
 echo ""
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_DL_Q} ${CYAN}${DL_DIR}${NC}"
 printf "${YELLOW}${L_FULL_UNINSTALL_DL_DEL}${NC}"; read del_ans
 DELETE_DL=false
 if [ "$del_ans" = "$L_CONFIRM_YES" ] || [ "$del_ans" = "$L_CONFIRM_YES2" ]; then
 DELETE_DL=true
 else
 echo -e "${GREEN} ${L_FULL_UNINSTALL_DL_KEEP}${NC}"
 fi
 fi

 echo ""
 # 1. Servisi durdur
 if status_check; then
 echo -e "${YELLOW}${L_FULL_UNINSTALL_STOPPING}${NC}"; stop_service_silent; sleep 1
 fi

 # 2. aria2 paketini kaldır
 if aria2_installed; then
 _remove_aria2_pkg
 fi

 # 3. İndirmeleri sil (istenirse)
 if [ "$DELETE_DL" = "true" ] && [ -n "$DL_DIR" ] && [ -d "$DL_DIR" ]; then
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_DL_DELETING}${NC}"
 rm -rf "$DL_DIR" 2>/dev/null
 echo -e "${GREEN} ${L_FULL_UNINSTALL_DL_DELETED}${NC}"
 fi

 # 4. Config, log, session sil
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_CONF}${NC}"
 rm -f "$ARIA2_CONF" "$ARIA2_SESSION" "$ARIA2_LOG" "$LANG_FILE" "$TG_CONF" 2>/dev/null
 rm -f "$TG_HOOK_MAIN" "$CONF_DIR/tg_on_complete.sh" "$CONF_DIR/tg_on_error.sh" 2>/dev/null
 rm -f "$CONF_DIR/tg_on_start.sh" "$CONF_DIR/tg_on_stop.sh" 2>/dev/null
 rm -f "$CONF_DIR/ariang_port" 2>/dev/null
 rm -f "$PID_FILE" 2>/dev/null
 rm -f "$INIT_FILE" 2>/dev/null
 rmdir "$CONF_DIR" 2>/dev/null

 # 5. AriaNg WebUI kaldır
 if ariang_is_installed || [ -d "$ARIANG_DIR" ] || command -v lighttpd >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_ARIANG}${NC}"
 if ariang_is_running; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_STOP}${NC}"
 kill $(cat /opt/var/run/lighttpd-ariang.pid 2>/dev/null) 2>/dev/null
 pkill lighttpd 2>/dev/null; sleep 1
 fi
 if [ -d "$ARIANG_DIR" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_HTML} ${ARIANG_DIR}${NC}"
 rm -rf "$ARIANG_DIR" 2>/dev/null
 fi
 if [ -f "$ARIANG_LIGHTTPD_CONF" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_CONF} ${ARIANG_LIGHTTPD_CONF}${NC}"
 rm -f "$ARIANG_LIGHTTPD_CONF" 2>/dev/null
 fi
 if [ -f "$ARIANG_LIGHTTPD_INIT" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_INIT} ${ARIANG_LIGHTTPD_INIT}${NC}"
 rm -f "$ARIANG_LIGHTTPD_INIT" 2>/dev/null
 fi
 rm -f /opt/var/run/lighttpd-ariang.pid /opt/var/log/lighttpd-ariang.log 2>/dev/null
 # lighttpd paketi: başka betik kullanıyor mu kontrol et
 if command -v lighttpd >/dev/null 2>&1; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_PKG}${NC}"
 safe_remove_pkg lighttpd
 fi
 echo -e "${GREEN} ${L_FULL_UNINSTALL_ARIANG_DONE}${NC}"
 else
 echo -e "${CYAN}ℹ ${L_FULL_UNINSTALL_ARIANG_SKIP}${NC}"
 fi

 # 7a. curl paketi — çakışma kontrolü ile kaldır
 if command -v curl >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_CURL}${NC}"
 safe_remove_pkg curl
 else
 echo -e "${CYAN}ℹ ${L_FULL_UNINSTALL_CURL_SKIP}${NC}"
 fi

 # 7. Artık dosyaları temizle
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_RESIDUAL}${NC}"
 # opkg bilgi dosyaları (wildcard ile aria2 + aria2-openssl hepsini yakalar)
 rm -f /opt/lib/opkg/info/aria2*.control \
 /opt/lib/opkg/info/aria2*.postinst \
 /opt/lib/opkg/info/aria2*.list \
 /opt/lib/opkg/info/aria2*.prerm 2>/dev/null
 rm -f /opt/var/log/lighttpd-aria2*.log 2>/dev/null
 # /opt/etc altındaki aria2* (özel/invisible karakter eklenmiş dizinleri de yakalar)
 find /opt/etc -maxdepth 1 -name 'aria2*' 2>/dev/null | while IFS= read -r d; do rm -rf "$d"; done
 # /opt/etc/lighttpd dizinini de temizle
 rm -rf /opt/etc/lighttpd 2>/dev/null
 # /opt/var ve /opt/lib altındaki aria2 kalıntıları
 find /opt/var -maxdepth 2 -name 'aria2*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 find /opt/lib -maxdepth 3 -name 'aria2*' 2>/dev/null | grep -v 'opkg/info' | while IFS= read -r f; do rm -rf "$f"; done
 # /tmp/mnt altındaki USB kopyaları (tüm UUID'ler için)
 find /tmp/mnt -maxdepth 5 -name 'aria2*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 find /tmp/mnt -maxdepth 5 -name 'lighttpd*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 echo -e "${GREEN} ${L_FULL_UNINSTALL_RESIDUAL_DONE}${NC}"

 # 8. Kısayolları sil
 rm -f /opt/bin/aria2m /opt/bin/a2m /opt/bin/soulsaria2 \
 /opt/bin/k2m /opt/bin/kam /opt/bin/keeneticaria2 /opt/bin/aria2manager 2>/dev/null

 # 9. Manager betiğini sil (son adım)
 rm -f "$LOCK_FILE"
 echo ""
 echo -e "${GREEN}${BOLD} ${L_FULL_UNINSTALL_DONE}${NC}"
 sleep 2
 rm -f "$SCRIPT_PATH"
 exit 0
}

# ============================================
# ARIA2 SADECE KALDIR (MANAGER'DAN BAĞIMSIZ)
# ============================================
uninstall_aria2_only() {
 clear
 echo -e "${RED}${BOLD}════════════════════════════════════════════════════${NC}"
 echo -e "${RED}${BOLD} ${L_ARIA2_ONLY_TITLE}${NC}"
 echo -e "${RED}${BOLD}════════════════════════════════════════════════════${NC}"
 echo -e " ${YELLOW}${L_ARIA2_ONLY_INFO}${NC}"
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${RED}•${NC} ${CYAN}aria2 service${NC} ${RED}(stopped + removed via opkg)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}All aria2 config files, logs and session${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Autostart file${NC} ${RED}(init.d)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}AriaNg WebUI${NC} ${RED}(if installed)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}All residual aria2 files and opkg info${NC}"
 else
  echo -e " ${RED}•${NC} ${CYAN}aria2 servisi${NC} ${RED}(durdurulur + opkg ile kaldırılır)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Tüm aria2 config dosyaları, loglar ve session${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Otomatik başlatma dosyası${NC} ${RED}(init.d)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}AriaNg WebUI${NC} ${RED}(kuruluysa)${NC}"
  echo -e " ${RED}•${NC} ${CYAN}Tüm aria2 artık dosyaları ve opkg bilgi dosyaları${NC}"
 fi
 echo ""
 echo -e " ${GREEN}${L_ARIA2_ONLY_KEEP}${NC}"
 echo ""
 if [ "$LANG_SEL" = "en" ]; then
  echo -e " ${CYAN}This removal will also check:${NC}"
  echo -e " ${RED}•${NC} Your backups — will be ${RED}deleted${NC} or ${GREEN}kept${NC} based on your choice"
  echo -e " ${RED}•${NC} Installed add-ons (lighttpd, curl, etc.) used by other scripts"
  echo -e "   will be scanned — ${RED}removed${NC} or ${GREEN}kept${NC} based on your choice"
 else
  echo -e " ${CYAN}Bu silme işlemi ayrıca şunları denetler:${NC}"
  echo -e " ${RED}•${NC} Almış olduğunuz yedekler — onayınızla ${RED}silinir${NC} veya ${GREEN}saklanır${NC}"
  echo -e " ${RED}•${NC} Yüklü eklentiler (lighttpd, curl vb.) diğer betikler tarafından"
  echo -e "   kullanılıp kullanılmadığı taranır — seçiminize bağlı ${RED}kaldırılır${NC} veya ${GREEN}saklanır${NC}"
 fi
 echo ""
 if [ "$LANG_SEL" = "en" ]; then
  printf "${CYAN}Type ${RED}REMOVE${NC}${CYAN} to confirm aria2 removal: ${NC}"; read confirm
 else
  printf "${CYAN}aria2 kaldırımını onaylamak için ${RED}SİL${NC}${CYAN} yazın: ${NC}"; read confirm
 fi
 if [ "$confirm" != "$L_ARIA2_ONLY_CONFIRM_WORD" ]; then
 echo -e "${YELLOW}${L_ARIA2_ONLY_CANCEL}${NC}"; sleep 2; return
 fi

 # Yedek kontrolü
 _check_and_delete_backups

 # İndirilen dosyalar hakkında sor
 DL_DIR=$(conf_get "dir")
 if [ -n "$DL_DIR" ] && [ -d "$DL_DIR" ]; then
 echo ""
 echo -e "${YELLOW} ${L_ARIA2_ONLY_DL_Q} ${CYAN}${DL_DIR}${NC}"
 printf "${YELLOW}${L_ARIA2_ONLY_DL_DEL}${NC}"; read del_ans
 DELETE_DL=false
 if [ "$del_ans" = "$L_CONFIRM_YES" ] || [ "$del_ans" = "$L_CONFIRM_YES2" ]; then
 DELETE_DL=true
 else
 echo -e "${GREEN} ${L_ARIA2_ONLY_DL_KEEP}${NC}"
 fi
 fi

 echo ""
 # 1. Servisi durdur
 if status_check; then
 echo -e "${YELLOW}${L_FULL_UNINSTALL_STOPPING}${NC}"; stop_service_silent; sleep 1
 fi

 # 2. aria2 paketini kaldır
 if aria2_installed; then
 _remove_aria2_pkg
 fi

 # 3. İndirmeleri sil (istenirse)
 if [ "$DELETE_DL" = "true" ] && [ -n "$DL_DIR" ] && [ -d "$DL_DIR" ]; then
 echo -e "${YELLOW} ${L_ARIA2_ONLY_DL_DELETING}${NC}"
 rm -rf "$DL_DIR" 2>/dev/null
 echo -e "${GREEN} ${L_ARIA2_ONLY_DL_DELETED}${NC}"
 fi

 # 4. Config, log, session sil
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_CONF}${NC}"
 rm -f "$ARIA2_CONF" "$ARIA2_SESSION" "$ARIA2_LOG" "$LANG_FILE" "$TG_CONF" 2>/dev/null
 rm -f "$TG_HOOK_MAIN" "$CONF_DIR/tg_on_complete.sh" "$CONF_DIR/tg_on_error.sh" 2>/dev/null
 rm -f "$CONF_DIR/tg_on_start.sh" "$CONF_DIR/tg_on_stop.sh" 2>/dev/null
 rm -f "$CONF_DIR/ariang_port" 2>/dev/null
 rm -f "$PID_FILE" 2>/dev/null
 rm -f "$INIT_FILE" 2>/dev/null
 rmdir "$CONF_DIR" 2>/dev/null

 # 5. AriaNg WebUI kaldır
 if ariang_is_installed || [ -d "$ARIANG_DIR" ] || command -v lighttpd >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_ARIANG}${NC}"
 if ariang_is_running; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_STOP}${NC}"
 kill $(cat /opt/var/run/lighttpd-ariang.pid 2>/dev/null) 2>/dev/null
 pkill lighttpd 2>/dev/null; sleep 1
 fi
 if [ -d "$ARIANG_DIR" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_HTML} ${ARIANG_DIR}${NC}"
 rm -rf "$ARIANG_DIR" 2>/dev/null
 fi
 if [ -f "$ARIANG_LIGHTTPD_CONF" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_CONF} ${ARIANG_LIGHTTPD_CONF}${NC}"
 rm -f "$ARIANG_LIGHTTPD_CONF" 2>/dev/null
 fi
 if [ -f "$ARIANG_LIGHTTPD_INIT" ]; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_INIT} ${ARIANG_LIGHTTPD_INIT}${NC}"
 rm -f "$ARIANG_LIGHTTPD_INIT" 2>/dev/null
 fi
 rm -f /opt/var/run/lighttpd-ariang.pid /opt/var/log/lighttpd-ariang.log 2>/dev/null
 # lighttpd paketi: başka betik kullanıyor mu kontrol et
 if command -v lighttpd >/dev/null 2>&1; then
 echo -e " ${CYAN}→ ${L_FULL_UNINSTALL_ARIANG_PKG}${NC}"
 safe_remove_pkg lighttpd
 fi
 echo -e "${GREEN} ${L_FULL_UNINSTALL_ARIANG_DONE}${NC}"
 else
 echo -e "${CYAN}ℹ ${L_FULL_UNINSTALL_ARIANG_SKIP}${NC}"
 fi

 # 6. Artık dosyaları temizle
 echo -e "${YELLOW} ${L_FULL_UNINSTALL_RESIDUAL}${NC}"
 # opkg bilgi dosyaları (wildcard ile aria2 + aria2-openssl hepsini yakalar)
 rm -f /opt/lib/opkg/info/aria2*.control \
 /opt/lib/opkg/info/aria2*.postinst \
 /opt/lib/opkg/info/aria2*.list \
 /opt/lib/opkg/info/aria2*.prerm 2>/dev/null
 rm -f /opt/var/log/lighttpd-aria2*.log 2>/dev/null
 # /opt/etc altındaki aria2* (özel/invisible karakter eklenmiş dizinleri de yakalar)
 find /opt/etc -maxdepth 1 -name 'aria2*' 2>/dev/null | while IFS= read -r d; do rm -rf "$d"; done
 # /opt/etc/lighttpd dizinini de temizle
 rm -rf /opt/etc/lighttpd 2>/dev/null
 # /opt/var ve /opt/lib altındaki aria2 kalıntıları
 find /opt/var -maxdepth 2 -name 'aria2*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 find /opt/lib -maxdepth 3 -name 'aria2*' 2>/dev/null | grep -v 'opkg/info' | while IFS= read -r f; do rm -rf "$f"; done
 # /tmp/mnt altındaki USB kopyaları (tüm UUID'ler için)
 find /tmp/mnt -maxdepth 5 -name 'aria2*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 find /tmp/mnt -maxdepth 5 -name 'lighttpd*' 2>/dev/null | while IFS= read -r f; do rm -rf "$f"; done
 echo -e "${GREEN} ${L_FULL_UNINSTALL_RESIDUAL_DONE}${NC}"

 echo ""
 echo -e "${GREEN}${BOLD} ${L_ARIA2_ONLY_DONE}${NC}"
 sleep 3
}

# ============================================
# ARIA2 GÜNCELLEME / ARIA2 UPDATE
# ============================================
update_aria2() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_ARIA2_UPDATE_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 if ! aria2_installed; then
 echo -e "${RED} ${L_ARIA2_UPDATE_NOT_INSTALLED}${NC}"; sleep 3; return
 fi

 echo -e "${YELLOW} ${L_ARIA2_UPDATE_CHECKING}${NC}"
 opkg update >/dev/null 2>&1

 CURR_VER=$(aria2_version)

 # opkg'den tam sürüm dizisi (örn: 1.37.0-3)
 AVAIL_VER_FULL=$(opkg info aria2 2>/dev/null | grep -m1 '^Version:' | awk '{print $2}')
 if [ -z "$AVAIL_VER_FULL" ]; then
 AVAIL_VER_FULL=$(opkg list aria2 2>/dev/null | grep -m1 'aria2 ' | awk '{print $3}')
 fi

 # Revizyon kısmını sil (1.37.0-3 → 1.37.0)
 AVAIL_VER=$(echo "$AVAIL_VER_FULL" | cut -d'-' -f1)

 echo -e " ${L_ARIA2_UPDATE_CURR} ${YELLOW}${CURR_VER:-?}${NC}"
 echo -e " ${L_ARIA2_UPDATE_AVAIL} ${GREEN}${AVAIL_VER_FULL:-?}${NC} ${CYAN}(base: ${AVAIL_VER:-?})${NC}"
 echo ""

 if [ -z "$AVAIL_VER" ]; then
 echo -e "${YELLOW} ${L_ARIA2_UPDATE_NO_INFO}${NC}"; sleep 3; return
 fi

 if [ "$CURR_VER" = "$AVAIL_VER" ]; then
 echo -e "${GREEN} ${L_ARIA2_UPDATE_LATEST}${NC}"; sleep 3; return
 fi

 echo -e "${GREEN} ${L_ARIA2_UPDATE_FOUND}${NC}"
 printf "${YELLOW}${L_ARIA2_UPDATE_Q}${NC}"; read ans
 if ! yes_answer "$ans"; then
 echo -e "${YELLOW}${L_ARIA2_UPDATE_CANCEL}${NC}"; sleep 2; return
 fi

 was_running=false
 if status_check; then
 was_running=true
 echo -e "${YELLOW}${L_ARIA2_UPDATE_STOPPING}${NC}"
 stop_service_silent; sleep 1
 fi

 echo -e "${YELLOW} ${L_ARIA2_UPDATE_IN_PROGRESS}${NC}"
 if opkg upgrade aria2 2>&1 | tail -5; then
 echo -e "${GREEN} ${L_ARIA2_UPDATE_DONE}${NC}"
 NEW_VER=$(aria2_version)
 echo -e " ${CYAN}→ v${NEW_VER:-?}${NC}"
 if [ "$was_running" = "true" ]; then
 echo -e "${YELLOW}${L_ARIA2_UPDATE_RESTARTING}${NC}"
 start_service_silent; sleep 1
 if status_check; then echo -e "${GREEN} ${L_SVC_RESTART_OK}${NC}"
 else echo -e "${RED} ${L_SVC_RESTART_FAIL}${NC}"; fi
 fi
 else
 echo -e "${RED} ${L_ARIA2_UPDATE_FAIL}${NC}"
 if [ "$was_running" = "true" ]; then
 start_service_silent
 fi
 fi
 sleep 3
}



# ============================================
# TELEGRAM BİLDİRİM SİSTEMİ / TELEGRAM NOTIFICATIONS
# ============================================

tg_get() { KEY="$1"; [ -f "$TG_CONF" ] && grep -m1 "^${KEY}=" "$TG_CONF" 2>/dev/null | cut -d'=' -f2-; }

tg_set() {
 KEY="$1"; VAL="$2"
 if [ -f "$TG_CONF" ]; then
 if grep -q "^${KEY}=" "$TG_CONF" 2>/dev/null; then
 sed -i "s|^${KEY}=.*|${KEY}=${VAL}|" "$TG_CONF"
 else
 echo "${KEY}=${VAL}" >> "$TG_CONF"
 fi
 else
 echo "${KEY}=${VAL}" > "$TG_CONF"
 fi
}

tg_init_conf() {
 if [ ! -f "$TG_CONF" ]; then
 cat > "$TG_CONF" <<TGEOF
TG_ENABLED=false
TG_BOT_TOKEN=
TG_CHAT_ID=
TG_ON_SVC_START=true
TG_ON_SVC_STOP=true
TG_ON_DL_ADD=false
TG_ON_DL_COMPLETE=false
TG_ON_DL_ERROR=false
TG_ON_DL_STOP=false
TG_ON_WEBUI_START=true
TG_ON_WEBUI_STOP=true
TG_ON_SECRET_KEY=true
TG_ON_BACKUP=true
TGEOF
 else
 # Eski conf dosyasında TG_ON_SECRET_KEY yoksa ekle
 grep -q "^TG_ON_SECRET_KEY=" "$TG_CONF" 2>/dev/null || echo "TG_ON_SECRET_KEY=true" >> "$TG_CONF"
 grep -q "^TG_ON_BACKUP=" "$TG_CONF" 2>/dev/null || echo "TG_ON_BACKUP=true" >> "$TG_CONF"
 fi
}

tg_notify() {
 EVENT="$1"; EXTRA="$2"
 [ "$(tg_get TG_ENABLED)" = "true" ] || return
 TOKEN=$(tg_get TG_BOT_TOKEN); CHAT=$(tg_get TG_CHAT_ID)
 [ -z "$TOKEN" ] || [ -z "$CHAT" ] && return

 # Event kontrolü
 case "$EVENT" in
 svc_start) [ "$(tg_get TG_ON_SVC_START)" = "true" ] || return; MSG="$L_TG_MSG_SVC_START" ;;
 svc_stop) [ "$(tg_get TG_ON_SVC_STOP)" = "true" ] || return; MSG="$L_TG_MSG_SVC_STOP" ;;
 dl_add) [ "$(tg_get TG_ON_DL_ADD)" = "true" ] || return; MSG="$L_TG_MSG_DL_ADD" ;;
 dl_complete)[ "$(tg_get TG_ON_DL_COMPLETE)" = "true" ]|| return; MSG="$L_TG_MSG_DL_COMPLETE" ;;
 dl_error) [ "$(tg_get TG_ON_DL_ERROR)" = "true" ] || return; MSG="$L_TG_MSG_DL_ERROR" ;;
 dl_stop) [ "$(tg_get TG_ON_DL_STOP)" = "true" ] || return; MSG="$L_TG_MSG_DL_STOP" ;;
 webui_start)[ "$(tg_get TG_ON_WEBUI_START)" = "true" ]|| return; MSG="$L_TG_MSG_WEBUI_START" ;;
 webui_stop) [ "$(tg_get TG_ON_WEBUI_STOP)" = "true" ] || return; MSG="$L_TG_MSG_WEBUI_STOP" ;;
 secret_key) [ "$(tg_get TG_ON_SECRET_KEY)" = "true" ] || return; MSG="$L_TG_MSG_SECRET_KEY" ;;
 backup_created)  [ "$(tg_get TG_ON_BACKUP)" = "true" ] || return; MSG="$L_TG_MSG_BACKUP_CREATED" ;;
 backup_deleted)  [ "$(tg_get TG_ON_BACKUP)" = "true" ] || return; MSG="$L_TG_MSG_BACKUP_DELETED" ;;
 backup_restored) [ "$(tg_get TG_ON_BACKUP)" = "true" ] || return; MSG="$L_TG_MSG_BACKUP_RESTORED" ;;
 test) MSG="$L_TG_MSG_TEST" ;;
 *) return ;;
 esac

 case "$EVENT" in
  dl_add)    [ -n "$EXTRA" ] && EXTRA="📎 $(if [ "$LANG_SEL" = "en" ]; then echo "File:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл:"; else echo "Dosya:"; fi) $EXTRA" ;;
  secret_key)[ -n "$EXTRA" ] && EXTRA="🔐 $(if [ "$LANG_SEL" = "en" ]; then echo "New key:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Новый ключ:"; else echo "Yeni anahtar:"; fi) $EXTRA" ;;
 esac

 [ -n "$EXTRA" ] && MSG="${MSG}
$(printf '%b' "$EXTRA")"

 # Cihaz adını ekle
 HOSTNAME=$(hostname 2>/dev/null || echo "router")
 FULL_MSG="[${HOSTNAME}] ${MSG}"

 curl -s --max-time 8 \
 "https://api.telegram.org/bot${TOKEN}/sendMessage" \
 -d "chat_id=${CHAT}" \
 --data-urlencode "text=${FULL_MSG}" \
 >/dev/null 2>&1 &
}

tg_create_hook_scripts() {
 # Dizinin var olduğundan emin ol
 mkdir -p "$CONF_DIR"
 # Ana hook script
 cat > "$TG_HOOK_MAIN" <<'HOOKEOF'
#!/bin/sh
# Keenetic Aria2 Manager - Telegram Hook
EVENT="$1"; GID="$2"; NUM_FILES="$3"; FILEPATH="$4"
TG_CONF="/opt/etc/aria2/telegram.conf"
[ -f "$TG_CONF" ] || exit 0
[ "$(grep -m1 '^TG_ENABLED=' "$TG_CONF" | cut -d'=' -f2)" = "true" ] || exit 0
TOKEN=$(grep -m1 '^TG_BOT_TOKEN=' "$TG_CONF" | cut -d'=' -f2)
CHAT=$(grep -m1 '^TG_CHAT_ID=' "$TG_CONF" | cut -d'=' -f2)
[ -z "$TOKEN" ] || [ -z "$CHAT" ] && exit 0

check_event() {
 KEY="$1"
 grep -m1 "^${KEY}=" "$TG_CONF" | grep -q "=true"
}

case "$EVENT" in
 complete) check_event TG_ON_DL_COMPLETE || exit 0
 FNAME=$(basename "${FILEPATH:-unknown}"); ICON="" ;;
 error) check_event TG_ON_DL_ERROR || exit 0
 FNAME=$(basename "${FILEPATH:-unknown}"); ICON="" ;;
 start) check_event TG_ON_DL_ADD || exit 0
 FNAME="GID:${GID}"; ICON="" ;;
 stop) check_event TG_ON_DL_STOP || exit 0
 FNAME=$(basename "${FILEPATH:-unknown}"); ICON="" ;;
 *) exit 0 ;;
esac

HOSTNAME=$(hostname 2>/dev/null || echo "router")
MSG="[${HOSTNAME}] ${ICON} ${EVENT}: ${FNAME}"
curl -s --max-time 8 \
 "https://api.telegram.org/bot${TOKEN}/sendMessage" \
 -d "chat_id=${CHAT}" \
 --data-urlencode "text=${MSG}" \
 >/dev/null 2>&1 &
HOOKEOF
 chmod +x "$TG_HOOK_MAIN"

 # Wrapper scriptler (aria2 her hook script'i GID num_files filepath ile çağırır)
 for EVT in complete error start stop; do
 HOOK_FILE="$CONF_DIR/tg_on_${EVT}.sh"
 printf '#!/bin/sh\n%s %s "$@"\n' "$TG_HOOK_MAIN" "$EVT" > "$HOOK_FILE"
 chmod +x "$HOOK_FILE"
 done
}

tg_update_aria2_hooks() {
 [ -f "$ARIA2_CONF" ] || return
 ENABLED="$1" # "add" veya "remove"

 # Önce mevcut hook satırlarını temizle
 sed -i '/^on-download-complete=/d' "$ARIA2_CONF"
 sed -i '/^on-download-error=/d' "$ARIA2_CONF"
 sed -i '/^on-download-start=/d' "$ARIA2_CONF"
 sed -i '/^on-download-stop=/d' "$ARIA2_CONF"

 if [ "$ENABLED" = "add" ]; then
 echo "on-download-complete=${CONF_DIR}/tg_on_complete.sh" >> "$ARIA2_CONF"
 echo "on-download-error=${CONF_DIR}/tg_on_error.sh" >> "$ARIA2_CONF"
 echo "on-download-start=${CONF_DIR}/tg_on_start.sh" >> "$ARIA2_CONF"
 echo "on-download-stop=${CONF_DIR}/tg_on_stop.sh" >> "$ARIA2_CONF"
 fi
}

tg_notifications_submenu() {
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_TG_NOTIFY_TITLE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 _tg_badge() {
 [ "$(tg_get "$1")" = "true" ] && echo "${GREEN}${L_TG_N_ON}${NC}" || echo "${RED}${L_TG_N_OFF}${NC}"
 }

 echo -e " ${YELLOW}1)${NC} ${L_TG_N_SVC_START} [$(_tg_badge TG_ON_SVC_START)]"
 echo -e " ${YELLOW}2)${NC} ${L_TG_N_SVC_STOP} [$(_tg_badge TG_ON_SVC_STOP)]"
 echo -e " ${YELLOW}3)${NC} ${L_TG_N_DL_ADD} [$(_tg_badge TG_ON_DL_ADD)]"
 echo -e " ${YELLOW}4)${NC} ${L_TG_N_DL_COMPLETE} [$(_tg_badge TG_ON_DL_COMPLETE)]"
 echo -e " ${YELLOW}5)${NC} ${L_TG_N_DL_ERROR} [$(_tg_badge TG_ON_DL_ERROR)]"
 echo -e " ${YELLOW}6)${NC} ${L_TG_N_DL_STOP} [$(_tg_badge TG_ON_DL_STOP)]"
 echo -e " ${YELLOW}7)${NC} ${L_TG_N_WEBUI_START} [$(_tg_badge TG_ON_WEBUI_START)]"
 echo -e " ${YELLOW}8)${NC} ${L_TG_N_WEBUI_STOP} [$(_tg_badge TG_ON_WEBUI_STOP)]"
 echo -e " ${YELLOW}9)${NC} ${L_TG_N_SECRET_KEY} [$(_tg_badge TG_ON_SECRET_KEY)]"
 echo -e " ${YELLOW}A)${NC} ${L_TG_N_BACKUP_CREATED} / ${L_TG_N_BACKUP_DELETED} / ${L_TG_N_BACKUP_RESTORED} [$(_tg_badge TG_ON_BACKUP)]"
 echo -e " ${YELLOW}0)${NC} ${L_TG_OPT_BACK}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-9, A]: ${NC}"; read nc

 _toggle_key() {
 KEY="$1"
 if [ "$(tg_get "$KEY")" = "true" ]; then tg_set "$KEY" "false"
 else tg_set "$KEY" "true"; fi
 echo -e "${GREEN} ${L_TG_N_SAVED}${NC}"; sleep 1
 }

 case "$nc" in
 1) _toggle_key TG_ON_SVC_START ;;
 2) _toggle_key TG_ON_SVC_STOP ;;
 3) _toggle_key TG_ON_DL_ADD ;;
 4) _toggle_key TG_ON_DL_COMPLETE
 # DL bildirimler için hook'ları güncelle
 if [ "$(tg_get TG_ENABLED)" = "true" ]; then tg_update_aria2_hooks "add"; fi ;;
 5) _toggle_key TG_ON_DL_ERROR
 if [ "$(tg_get TG_ENABLED)" = "true" ]; then tg_update_aria2_hooks "add"; fi ;;
 6) _toggle_key TG_ON_DL_STOP
 if [ "$(tg_get TG_ENABLED)" = "true" ]; then tg_update_aria2_hooks "add"; fi ;;
 7) _toggle_key TG_ON_WEBUI_START ;;
 8) _toggle_key TG_ON_WEBUI_STOP ;;
 9) _toggle_key TG_ON_SECRET_KEY ;;
 a|A) _toggle_key TG_ON_BACKUP ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
 done
}

telegram_menu() {
 tg_init_conf
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_TG_TITLE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 TG_EN=$(tg_get TG_ENABLED)
 TG_TOK=$(tg_get TG_BOT_TOKEN)
 TG_CID=$(tg_get TG_CHAT_ID)

 # Durum gösterimini güncelle
 if [ "$TG_EN" = "true" ]; then
 STATUS_LABEL=""
 else
 STATUS_LABEL=""
 fi

 # Token ve Chat ID gösterimini güncelle
 [ -n "$TG_TOK" ] && TOK_D="${GREEN} AYARLI${NC}" || TOK_D="${RED} AYARLI DEĞİL${NC}"
 [ -n "$TG_CID" ] && CID_D="${GREEN} AYARLI${NC}" || CID_D="${RED} AYARLI DEĞİL${NC}"

 # Aktif bildirimler özeti
 NOTIF_LIST=""
 [ "$(tg_get TG_ON_SVC_START)" = "true" ] && NOTIF_LIST="$NOTIF_LIST svc_start"
 [ "$(tg_get TG_ON_SVC_STOP)" = "true" ] && NOTIF_LIST="$NOTIF_LIST svc_stop"
 [ "$(tg_get TG_ON_DL_ADD)" = "true" ] && NOTIF_LIST="$NOTIF_LIST dl_add"
 [ "$(tg_get TG_ON_DL_COMPLETE)" = "true" ] && NOTIF_LIST="$NOTIF_LIST dl_complete"
 [ "$(tg_get TG_ON_DL_ERROR)" = "true" ] && NOTIF_LIST="$NOTIF_LIST dl_error"
 [ "$(tg_get TG_ON_DL_STOP)" = "true" ] && NOTIF_LIST="$NOTIF_LIST dl_stop"
 [ "$(tg_get TG_ON_WEBUI_START)" = "true" ] && NOTIF_LIST="$NOTIF_LIST webui_start"
 [ "$(tg_get TG_ON_WEBUI_STOP)" = "true" ] && NOTIF_LIST="$NOTIF_LIST webui_stop"
 [ "$(tg_get TG_ON_SECRET_KEY)" = "true" ] && NOTIF_LIST="$NOTIF_LIST secret_key"
 [ "$(tg_get TG_ON_BACKUP)" = "true" ] && NOTIF_LIST="$NOTIF_LIST backup"
 [ -z "$NOTIF_LIST" ] && NOTIF_LIST=" -"

 # curl kontrol
 if command -v curl >/dev/null 2>&1; then
 _CURL_D="${GREEN}${L_TG_CURL_OK}${NC}"
 _CURL_MISSING=0
 else
 _CURL_D="${RED}${L_TG_CURL_MISSING}${NC}"
 _CURL_MISSING=1
 fi

 local _TW=20
 if [ "$TG_EN" = "true" ]; then
 _TG_STATUS_D="${GREEN} ${L_TG_ENABLED_STATUS}${NC}"
 else
 _TG_STATUS_D="${RED} ${L_TG_DISABLED_STATUS}${NC}"
 fi
 printf " %s : %b\n" "$(pad_label "$L_TG_STATUS" $_TW)" "$_TG_STATUS_D"
 printf " %s : %b\n" "$(pad_label "Bot Token" $_TW)" "$TOK_D"
 printf " %s : %b\n" "$(pad_label "Chat ID" $_TW)" "$CID_D"
 printf " %s : %b\n" "$(pad_label "${L_TG_NOTIFICATIONS}" $_TW)" "${CYAN}${NOTIF_LIST}${NC}"
 printf " %s : [ %b ]\n" "$(pad_label "curl" $_TW)" "$_CURL_D"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${DIM_CYAN}── ${L_TG_ABOUT_TITLE} ──────────────────────────────────${NC}"
 echo -e " ${L_TG_ABOUT_DESC}"
 echo -e " ${YELLOW}* ${L_TG_ABOUT_CURL}${NC}"
 echo -e " ${L_TG_ABOUT_AUTO}"
 echo -e " ${L_TG_ABOUT_MANUAL}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} Telegram ${GREEN}${L_TG_ENABLED_STATUS}${NC}/${RED}${L_TG_DISABLED_STATUS}${NC}"
 echo -e " ${YELLOW}2)${NC} ${CYAN}${L_TG_OPT_TOKEN} & ${L_TG_OPT_CHAT}${NC}"
 echo -e " ${YELLOW}3)${NC} ${L_TG_OPT_NOTIFY}"
 echo -e " ${YELLOW}4)${NC} ${CYAN}${L_TG_OPT_TEST}${NC}"
 if command -v curl >/dev/null 2>&1; then
 echo -e " ${YELLOW}5)${NC} ${L_TG_OPT_CURL} [ ${GREEN}${L_TG_CURL_OK}${NC} ]"
 else
 echo -e " ${YELLOW}5)${NC} ${L_TG_OPT_CURL} [ ${RED}${L_TG_CURL_MISSING}${NC} ]"
 fi
 echo -e " ${YELLOW}0)${NC} ${L_TG_OPT_BACK}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-5]: ${NC}"; read tgc

 case "$tgc" in
 1)
 CURR_EN=$(tg_get TG_ENABLED)
 if [ "$CURR_EN" = "true" ]; then
 tg_set TG_ENABLED "false"
 tg_update_aria2_hooks "remove"
 echo -e "${YELLOW}${L_TG_TOGGLED_OFF}${NC}"
 else
 # curl kontrolü — yoksa kurulmasını öner
 if ! command -v curl >/dev/null 2>&1; then
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${RED} curl ${L_TG_CURL_MISSING}${NC}"
 printf "${YELLOW}${L_TG_CURL_INSTALL_Q}${NC}"
 read _curl_ans
 case "$_curl_ans" in
 [Ee][Vv][Ee][Tt]|[Ee]|[Yy][Ee][Ss]|[Yy])
 echo -e "${YELLOW} opkg update && opkg install curl...${NC}"
 opkg update 2>&1 | tail -3
 opkg install curl 2>&1 | tail -5
 if ! command -v curl >/dev/null 2>&1; then
 echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "curl installation failed. Telegram disabled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Установка curl не удалась. Telegram отключён."; else echo "curl kurulamadı. Telegram devre dışı bırakıldı."; fi)${NC}"
 sleep 3; continue
 fi
 echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "curl installed."; elif [ "$LANG_SEL" = "ru" ]; then echo "curl установлен."; else echo "curl kuruldu."; fi)${NC}"; sleep 1
 ;;
 *)
 echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "Telegram notifications require curl."; elif [ "$LANG_SEL" = "ru" ]; then echo "Для Telegram уведомлений нужен curl."; else echo "curl olmadan Telegram bildirimleri çalışmaz."; fi)${NC}"; sleep 2; continue ;;
 esac
 fi
 # Token ve Chat ID kontrolü
 if [ -z "$(tg_get TG_BOT_TOKEN)" ] || [ -z "$(tg_get TG_CHAT_ID)" ]; then
 echo -e "${RED} ${L_TG_NEED_TOKEN}${NC}"; sleep 2; continue
 fi
 tg_set TG_ENABLED "true"
 tg_create_hook_scripts
 tg_update_aria2_hooks "add"
 echo -e "${GREEN} ${L_TG_TOGGLED_ON}${NC}"
 # Servis çalışıyorsa yeniden başlat ki hooklar aktif olsun
 if status_check; then
 stop_service_silent; sleep 1; start_service_silent
 fi
 fi
 sleep 2
 ;;
 2)
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "Bot Token & Chat ID Setup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Настройка Bot Token и Chat ID"; else echo "Bot Token & Chat ID Ayarı"; fi)${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo ""
 
 printf "${YELLOW}$(if [ "$LANG_SEL" = "en" ]; then echo "Enter Bot Token (blank = cancel): "; elif [ "$LANG_SEL" = "ru" ]; then echo "Введите Bot Token (пусто = отмена): "; else echo "Bot Token Girin (boş = iptal): "; fi)${NC}"
 read tok
 if [ -n "$tok" ]; then
 tg_set TG_BOT_TOKEN "$tok"
 echo -e "${GREEN} ${L_TG_TOKEN_SAVED}${NC}"
 sleep 1
 fi
 
 printf "${YELLOW}$(if [ "$LANG_SEL" = "en" ]; then echo "Enter Chat ID (blank = cancel): "; elif [ "$LANG_SEL" = "ru" ]; then echo "Введите Chat ID (пусто = отмена): "; else echo "Chat ID Girin (boş = iptal): "; fi)${NC}"
 read cid
 if [ -n "$cid" ]; then
 tg_set TG_CHAT_ID "$cid"
 echo -e "${GREEN} ${L_TG_CHAT_SAVED}${NC}"
 sleep 1
 fi

 # Token ve Chat ID'nin her ikisi de girilirse otomatik başlat
 if [ -n "$(tg_get TG_BOT_TOKEN)" ] && [ -n "$(tg_get TG_CHAT_ID)" ]; then
 CURR_EN=$(tg_get TG_ENABLED)
 if [ "$CURR_EN" != "true" ]; then
 echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Starting Telegram service automatically..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Автоматический запуск сервиса Telegram..."; else echo "Telegram hizmeti otomatik başlatılıyor..."; fi)${NC}"
 sleep 2
 if ! command -v curl >/dev/null 2>&1; then
 echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Installing curl..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Установка curl..."; else echo "curl kuruluyor..."; fi)${NC}"
 opkg update 2>&1 | tail -2
 opkg install curl 2>&1 | tail -3
 fi
 tg_set TG_ENABLED "true"
 tg_create_hook_scripts
 tg_update_aria2_hooks "add"
 echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Telegram service started."; elif [ "$LANG_SEL" = "ru" ]; then echo "Сервис Telegram запущен."; else echo "Telegram hizmeti başlatıldı."; fi)${NC}"
 if status_check; then
 stop_service_silent; sleep 1; start_service_silent
 fi
 fi
 fi
 sleep 2
 ;;
 3) tg_notifications_submenu ;;
 4)
 if [ -z "$(tg_get TG_BOT_TOKEN)" ] || [ -z "$(tg_get TG_CHAT_ID)" ]; then
 echo -e "${RED} ${L_TG_NEED_TOKEN}${NC}"; sleep 2; continue
 fi
 echo -e "${YELLOW} ${L_TG_TEST_SENDING}${NC}"
 # Test için geçici olarak enable et
 ORIG_EN=$(tg_get TG_ENABLED)
 tg_set TG_ENABLED "true"
 tg_notify "test"
 sleep 3
 # Sonucu kontrol et (basit yaklaşım - curl bg'de çalıştığı için 3sn bekliyoruz)
 echo -e "${GREEN} ${L_TG_TEST_OK}${NC}"
 echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Check your Telegram."; elif [ "$LANG_SEL" = "ru" ]; then echo "Проверьте Telegram."; else echo "Telegram'ı kontrol edin."; fi)${NC}"
 tg_set TG_ENABLED "$ORIG_EN"
 sleep 3
 ;;
 5)
 if command -v curl >/dev/null 2>&1; then
 echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "curl is already installed."; elif [ "$LANG_SEL" = "ru" ]; then echo "curl уже установлен."; else echo "curl zaten yüklü."; fi)${NC}"; sleep 2
 else
 echo -e "${YELLOW} opkg update && opkg install curl...${NC}"
 opkg update 2>&1 | tail -3
 opkg install curl 2>&1 | tail -5
 if command -v curl >/dev/null 2>&1; then
 echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "curl installed successfully."; elif [ "$LANG_SEL" = "ru" ]; then echo "curl успешно установлен."; else echo "curl başarıyla yüklendi."; fi)${NC}"
 else
 echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "curl installation failed. Check internet connection."; elif [ "$LANG_SEL" = "ru" ]; then echo "Установка curl не удалась. Проверьте интернет."; else echo "curl yüklenemedi. İnternet bağlantısını kontrol edin."; fi)${NC}"
 fi
 sleep 3
 fi
 ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
 done
}


health_menu() {
 _health_draw() {
 clear
 local _LW=16
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_HEALTH_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 # ─── SİSTEM BİLGİSİ ──────────────────────────────────

 # ─── CPU & YÜK ───────────────────────────────────────
 echo -e "${CYAN}${BOLD} ── ${L_HEALTH_SEC_CPU} ──${NC}"

 # CPU % : /proc/stat iki ölçüm arası delta
 local _c1 _c2 _cpu_pct _idle1 _total1 _idle2 _total2
 _c1=$(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat 2>/dev/null)
 sleep 0.3 2>/dev/null || true
 _c2=$(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat 2>/dev/null)
 _cpu_pct=$(echo "$_c1 $_c2" | awk '{
 u1=$1+$2+$3; i1=$4; s1=$5+$6+$7; t1=u1+i1+s1
 u2=$8+$9+$10; i2=$11; s2=$12+$13+$14; t2=u2+i2+s2
 dt=t2-t1; di=i2-i1
 if(dt>0) printf "%.1f", (dt-di)*100/dt; else print "0.0"
 }')
 local _cpu_clr="${GREEN}"
 [ "$(echo "$_cpu_pct" | awk '{print ($1>=70)}')" = "1" ] && _cpu_clr="${YELLOW}"
 [ "$(echo "$_cpu_pct" | awk '{print ($1>=90)}')" = "1" ] && _cpu_clr="${RED}"
 printf " ${BOLD}%s${NC} : %b%s%%%b\n" "$(pad_label "$L_HEALTH_CPU_USAGE" $_LW)" "$_cpu_clr" "${_cpu_pct:-?}" "${NC}"

 # Sıcaklık
 local _temp=""
 for _tf in /sys/class/thermal/thermal_zone*/temp; do
 [ -f "$_tf" ] || continue
 _tv=$(cat "$_tf" 2>/dev/null)
 [ -n "$_tv" ] && _temp=$(awk "BEGIN{printf \"%.0f°C\", $_tv/1000}") && break
 done
 [ -n "$_temp" ] && printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_HEALTH_TEMP" $_LW)" "$_temp"

 # Load average
 local _load1 _load5 _load15 _nproc
 read -r _load1 _load5 _load15 _ < /proc/loadavg 2>/dev/null
 _nproc=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null); _nproc=${_nproc:-1}
 local _l1clr="${GREEN}" _l5clr="${GREEN}" _l15clr="${GREEN}"
 [ "$(awk "BEGIN{print ($_load1>=$_nproc*0.7)}")" = "1" ] && _l1clr="${YELLOW}"
 [ "$(awk "BEGIN{print ($_load1>=$_nproc)}")" = "1" ] && _l1clr="${RED}"
 [ "$(awk "BEGIN{print ($_load5>=$_nproc*0.7)}")" = "1" ] && _l5clr="${YELLOW}"
 [ "$(awk "BEGIN{print ($_load5>=$_nproc)}")" = "1" ] && _l5clr="${RED}"
 printf " ${BOLD}%s${NC} : %b%s${NC} ${BOLD}%s${NC}: %b%s${NC} ${BOLD}%s${NC}: %b%s${NC}\n" \
 "$(pad_label "$L_HEALTH_LOAD_1" $_LW)" "$_l1clr" "${_load1:-?}" \
 "$L_HEALTH_LOAD_5" "$_l5clr" "${_load5:-?}" \
 "$L_HEALTH_LOAD_15" "${GREEN}" "${_load15:-?}"
 if [ "$LANG_SEL" = "en" ]; then
 printf " %s \033[2mLoad threshold = CPU count (%s cores) — yellow>=70%% red>=100%%\033[0m\n" "$(pad_label "" $_LW)" "$_nproc"
 else
 printf " %s \033[2mYük eşiği = CPU sayısı (%s çekirdek) — sarı>=%%70 kırmızı>=%%100\033[0m\n" "$(pad_label "" $_LW)" "$_nproc"
 fi

 # Süreç sayısı
 local _pcount
 _pcount=$(ls /proc 2>/dev/null | grep -c '^[0-9]')
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HEALTH_PROC_COUNT" $_LW)" "${_pcount:-?}"

 # ─── BELLEK ──────────────────────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ── ${L_HEALTH_SEC_RAM} ──${NC}"
 local _mem_total _mem_free _mem_avail _mem_buf _mem_cache _mem_used _mem_pct
 local _swap_total _swap_free _swap_used _swap_pct
 eval $(awk '
 /^MemTotal:/ {mt=$2}
 /^MemFree:/ {mf=$2}
 /^MemAvailable:/ {ma=$2}
 /^Buffers:/ {mb=$2}
 /^Cached:/ {mc=$2}
 /^SwapTotal:/ {st=$2}
 /^SwapFree:/ {sf=$2}
 END {
 printf "mt=%d mf=%d ma=%d mb=%d mc=%d st=%d sf=%d\n",mt,mf,ma,mb,mc,st,sf
 }
 ' /proc/meminfo 2>/dev/null)
 _mem_used=$(( mt - mf - mb - mc )); [ "$_mem_used" -lt 0 ] 2>/dev/null && _mem_used=0
 _mem_pct=$(awk "BEGIN{printf \"%.0f\", ($_mem_used/$mt)*100}" 2>/dev/null)
 local _mclr="${GREEN}"
 [ "${_mem_pct:-0}" -ge 70 ] 2>/dev/null && _mclr="${YELLOW}"
 [ "${_mem_pct:-0}" -ge 90 ] 2>/dev/null && _mclr="${RED}"
 printf " ${BOLD}%s${NC} : %b%s MB (%s%%)${NC}\n" "$(pad_label "$L_HEALTH_RAM_USED" $_LW)" "$_mclr" \
 "$(( _mem_used / 1024 ))" "${_mem_pct:-?}"
 printf " ${BOLD}%s${NC} : ${GREEN}%s MB${NC}\n" "$(pad_label "$L_HEALTH_RAM_FREE" $_LW)" "$(( ma / 1024 ))"
 printf " ${BOLD}%s${NC} : ${CYAN}%s MB${NC}\n" "$(pad_label "$L_HEALTH_RAM_TOTAL" $_LW)" "$(( mt / 1024 ))"
 printf " ${BOLD}%s${NC} : \033[2m%s MB\033[0m\n" "$(pad_label "$L_HEALTH_RAM_BUFCACHE" $_LW)" "$(( (mb+mc) / 1024 ))"
 if [ "${st:-0}" -gt 0 ] 2>/dev/null; then
 _swap_used=$(( st - sf ))
 _swap_pct=$(awk "BEGIN{printf \"%.0f\", ($_swap_used/$st)*100}" 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${YELLOW}%s MB (%s%%)${NC}\n" "$(pad_label "$L_HEALTH_SWAP_USED" $_LW)" \
 "$(( _swap_used / 1024 ))" "${_swap_pct:-?}"
 printf " ${BOLD}%s${NC} : ${CYAN}%s MB${NC}\n" "$(pad_label "$L_HEALTH_SWAP_TOTAL" $_LW)" "$(( st / 1024 ))"
 fi

 # ─── DEPOLAMA ────────────────────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ── ${L_HEALTH_SEC_DISK} ──${NC}"
 df -h 2>/dev/null | awk 'NR>1 && $6!~/^\/proc|^\/sys|^\/dev\/pts|^\/run|none/ {
 printf " %-16s : %s / %s (%s)\n", $6, $4, $2, $5
 }' | while IFS= read -r _dline; do
 _dpct=$(echo "$_dline" | grep -o '([0-9]*%)' | tr -d '()%')
 if [ "${_dpct:-0}" -ge 90 ] 2>/dev/null; then echo -e "${RED}${_dline}${NC}"
 elif [ "${_dpct:-0}" -ge 70 ] 2>/dev/null; then echo -e "${YELLOW}${_dline}${NC}"
 else echo -e "${CYAN}${_dline}${NC}"; fi
 done

 # ─── AĞ ─────────────────────────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ── ${L_HEALTH_SEC_NET} ──${NC}"

 # WAN IP
 local _wip
 _wip=$(ip -4 addr show ppp0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 [ -z "$_wip" ] && _wip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)
 [ -z "$_wip" ] && _wip=$(ip -4 addr show br0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HEALTH_WAN_IP" $_LW)" "${_wip:-$L_HEALTH_NA}"

 # LAN IP
 local _lip
 _lip=$(ip -4 addr show br0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 [ -z "$_lip" ] && _lip=$(ip -4 addr show eth0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HEALTH_LAN_IP" $_LW)" "${_lip:-$L_HEALTH_NA}"

 # ─── ARIA2 ───────────────────────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ── ${L_HEALTH_SEC_ARIA2} ──${NC}"
 local _a2pid _a2rss
 _a2pid=$(pidof aria2c 2>/dev/null | awk '{print $1}')

 # aria2c binary
 if aria2_installed; then
 local _a2ver
 _a2ver=$(aria2_version)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(v%s)${NC}\n" "$(pad_label "$L_ARIA2C" $_LW)" "$L_INSTALLED" "${_a2ver:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_ARIA2C" $_LW)" "$L_NOT_INSTALLED"
 fi

 # Servis / PID
 if [ -n "$_a2pid" ]; then
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(PID: %s)${NC}\n" "$(pad_label "$L_SERVICE" $_LW)" "$L_RUNNING" "$_a2pid"
 _a2rss=$(awk '/^VmRSS:/{printf "%.0f MB", $2/1024}' /proc/$_a2pid/status 2>/dev/null)
 [ -n "$_a2rss" ] && printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_RSS" $_LW)" "$_a2rss"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_SERVICE" $_LW)" "$L_STOPPED"
 fi

 # Config dosyası
 if [ -f "$ARIA2_CONF" ]; then
 local _conf_sz
 _conf_sz=$(wc -c < "$ARIA2_CONF" 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} \033[2m(%s bytes)\033[0m\n" \
 "$(pad_label "$(if [ "$LANG_SEL" = "en" ]; then echo "Config File"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл конфигурации"; else echo "Config Dosyası"; fi)" $_LW)" \
 "$L_HEALTH_OK" "${_conf_sz:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" \
 "$(pad_label "$(if [ "$LANG_SEL" = "en" ]; then echo "Config File"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл конфигурации"; else echo "Config Dosyası"; fi)" $_LW)" \
 "$L_HEALTH_NA"
 fi

 # Session dosyası
 if [ -f "$ARIA2_SESSION" ]; then
 local _sessz
 _sessz=$(wc -c < "$ARIA2_SESSION" 2>/dev/null)
 local _sessl
 _sessl=$(wc -l < "$ARIA2_SESSION" 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} \033[2m(%s bytes, %s lines)\033[0m\n" \
 "$(pad_label "$L_HEALTH_ARIA2_SESSIONS" $_LW)" "$L_HEALTH_OK" "${_sessz:-?}" "${_sessl:-?}"
 else
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_SESSIONS" $_LW)" "$L_HEALTH_NA"
 fi

 # Log dosyası
 if [ -f "$ARIA2_LOG" ]; then
 local _logsz
 _logsz=$(du -h "$ARIA2_LOG" 2>/dev/null | awk '{print $1}')
 local _loglast
 _loglast=$(tail -1 "$ARIA2_LOG" 2>/dev/null | cut -c1-40)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} \033[2m(%s)\033[0m\n" \
 "$(pad_label "$(if [ "$LANG_SEL" = "en" ]; then echo "Log File"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл лога"; else echo "Log Dosyası"; fi)" $_LW)" \
 "${_logsz:-?}" "${_loglast:-...}"
 else
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" \
 "$(pad_label "$(if [ "$LANG_SEL" = "en" ]; then echo "Log File"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл лога"; else echo "Log Dosyası"; fi)" $_LW)" \
 "$L_HEALTH_NA"
 fi

 # Oto başlatma (init.d)
 if [ -f "$INIT_FILE" ]; then
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} \033[2m(%s)\033[0m\n" \
 "$(pad_label "$L_AUTO_START" $_LW)" "$L_ACTIVE" "$INIT_FILE"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_AUTO_START" $_LW)" "$L_INACTIVE"
 fi

 # RPC soket kontrolü
 local _rp
 _rp=$(conf_get "rpc-listen-port"); _rp="${_rp:-6800}"
 local _rpc_en
 _rpc_en=$(conf_get "enable-rpc")
 if [ "$_rpc_en" = "true" ]; then
 if [ -n "$_a2pid" ]; then
 local _rpc_ok
 local _rs_h
 _rs_h=$(conf_get "rpc-secret")
 [ -n "$_rs_h" ] && local _ra_h="\"token:${_rs_h}\"" || local _ra_h=""
 _rpc_ok=$(curl -s --connect-timeout 1 \
 "http://localhost:${_rp}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getVersion\",\"id\":1,\"params\":[${_ra_h}]}" 2>/dev/null)
 if echo "$_rpc_ok" | grep -q '"result"'; then
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(port: %s)${NC}\n" "$(pad_label "$L_RPC" $_LW)" "$L_ACTIVE" "$_rp"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}(port: %s)${NC}\n" "$(pad_label "$L_RPC" $_LW)" \
 "$(if [ "$LANG_SEL" = "en" ]; then echo "NO RESPONSE"; elif [ "$LANG_SEL" = "ru" ]; then echo "НЕТ ОТВЕТА"; else echo "YANIT YOK"; fi)" "$_rp"
 fi
 else
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_RPC" $_LW)" \
 "$(if [ "$LANG_SEL" = "en" ]; then echo "ENABLED (service down)"; elif [ "$LANG_SEL" = "ru" ]; then echo "включён (сервис остановлен)"; else echo "ETKİN (servis kapalı)"; fi)"
 fi
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_RPC" $_LW)" "$L_INACTIVE"
 fi

 # AriaNg (lighttpd) durumu
 if ariang_is_installed; then
 if ariang_is_running; then
 local _ang_port
 _ang_port=$(cat "$ARIANG_PORT_FILE" 2>/dev/null || echo "6880")
 local _ang_ip2
 _ang_ip2=$(ariang_get_ip 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}http://%s:%s/${NC}\n" \
 "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_RUNNING" "${_ang_ip2}" "${_ang_port}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}(%s)${NC}\n" \
 "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_STOPPED" "$L_ARIANG_INSTALLED"
 fi
 else
 printf " ${BOLD}%s${NC} : \033[2m%s\033[0m\n" "$(pad_label "AriaNg WebUI" $_LW)" "$L_ARIANG_NOT_INSTALLED"
 fi

 # RPC istatistikleri (servis çalışıyorsa)
 if [ -n "$_a2pid" ] && [ "$_rpc_en" = "true" ]; then
 local _rs
 _rs=$(conf_get "rpc-secret")
 [ -n "$_rs" ] && local _ra="\"token:${_rs}\"" || local _ra=""
 local _rr
 _rr=$(curl -s --connect-timeout 1 \
 "http://localhost:${_rp}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getGlobalStat\",\"id\":1,\"params\":[${_ra}]}" 2>/dev/null)
 if echo "$_rr" | grep -q '"result"'; then
 local _act _wait _stop _dspd _uspd
 _act=$(echo "$_rr" | grep -o '"numActive":"[^"]*"' | cut -d'"' -f4)
 _wait=$(echo "$_rr" | grep -o '"numWaiting":"[^"]*"' | cut -d'"' -f4)
 _stop=$(echo "$_rr" | grep -o '"numStoppedTotal":"[^"]*"' | cut -d'"' -f4)
 _dspd=$(echo "$_rr" | grep -o '"downloadSpeed":"[^"]*"' | cut -d'"' -f4)
 _uspd=$(echo "$_rr" | grep -o '"uploadSpeed":"[^"]*"' | cut -d'"' -f4)
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_ACTIVE" $_LW)" "${_act:-0}"
 printf " ${BOLD}%s${NC} : ${CYAN}%s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_WAITING" $_LW)" "${_wait:-0}"
 printf " ${BOLD}%s${NC} : \033[2m%s\033[0m\n" "$(pad_label "$L_HEALTH_ARIA2_STOPPED" $_LW)" "${_stop:-0}"
 _fmt_spd() {
 local _b="$1"
 if [ "${_b:-0}" -ge 1048576 ] 2>/dev/null; then awk "BEGIN{printf \"%.1f MB/s\",$_b/1048576}"
 elif [ "${_b:-0}" -ge 1024 ] 2>/dev/null; then awk "BEGIN{printf \"%.0f KB/s\",$_b/1024}"
 else echo "${_b:-0} B/s"; fi
 }
 printf " ${BOLD}%s${NC} : ${GREEN}⬇ %s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_SPEED" $_LW)" "$(_fmt_spd "$_dspd")"
 printf " ${BOLD}%s${NC} : ${YELLOW}⬆ %s${NC}\n" "$(pad_label "$L_HEALTH_ARIA2_UPSPEED" $_LW)" "$(_fmt_spd "$_uspd")"
 fi
 fi

 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf " \033[2m%s\033[0m\n" "$L_HEALTH_PRESS_R"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 }

 while true; do
 _health_draw
 printf "${GREEN}${L_CHOICE_PROMPT}: ${NC}"; read _hc
 case "$_hc" in
 r|R)
 echo -e "${YELLOW}${L_HEALTH_REFRESHING}${NC}"; sleep 0.5 ;;
 a|A)
 while true; do
 _health_draw
 printf " \033[2m%s\033[0m\n" "$L_HEALTH_AUTO_REF"
 # 5 saniye bekle, tuş gelirse çık
 local _i=0
 while [ "$_i" -lt 5 ]; do
 if read -r -t 1 _ak 2>/dev/null; then break 2; fi
 _i=$(( _i + 1 ))
 done
 done
 ;;
 0|"") return ;;
 *) return ;;
 esac
 done
}

# ============================================
# TANI & TEST MENÜSÜ / DIAGNOSTICS MENU
# ============================================
diag_menu() {
 _diag_status() {
 # $1=label $2=status_color $3=status_text [$4=detail]
 local _LW=24
 if [ -n "$4" ]; then
 printf " ${BOLD}%s${NC} : %b%-18s${NC} \033[2m%s\033[0m\n" "$(pad_label "$1" $_LW)" "$2" "$3" "$4"
 else
 printf " ${BOLD}%s${NC} : %b%s${NC}\n" "$(pad_label "$1" $_LW)" "$2" "$3"
 fi
 }

 _diag_draw() {
 clear
 local _LW=24
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_DIAG_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 # Sorun sayacı
 _issues=0

 # ─── TEMEL GEREKSİNİMLER ──────────────────────────
 echo -e "${CYAN}${BOLD} ${L_DIAG_SEC_CORE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # 1. Entware /opt
 if [ -d "/opt/bin" ] && [ -f "/opt/bin/opkg" -o -x "/opt/bin/opkg" ]; then
 _diag_status "Entware /opt" "${GREEN}" "${L_DIAG_ENTWARE_OK}" "${L_DIAG_D_OPTBIN}"
 elif [ -d "/opt" ]; then
 _diag_status "Entware /opt" "${YELLOW}" "${L_DIAG_WARN}" "/opt ${L_DIAG_D_OPTNO}"
 _issues=$((_issues+1))
 else
 _diag_status "Entware /opt" "${RED}" "${L_DIAG_ENTWARE_MISS}"
 _issues=$((_issues+1))
 fi

 # 2. opkg
 if command -v opkg >/dev/null 2>&1; then
 _diag_status "opkg" "${GREEN}" "${L_DIAG_OPKG_OK}" "$(command -v opkg)"
 else
 _diag_status "opkg" "${RED}" "${L_DIAG_OPKG_MISS}"
 _issues=$((_issues+1))
 fi

 # 3. aria2c binary
 if aria2_installed; then
 _a2ver=$(aria2_version)
 _diag_status "aria2c" "${GREEN}" "${L_DIAG_INSTALLED}" "v${_a2ver:-?} $(command -v aria2c)"
 else
 _diag_status "aria2c" "${RED}" "${L_DIAG_FAIL}"
 _issues=$((_issues+1))
 fi

 # 4. curl
 if command -v curl >/dev/null 2>&1; then
 _diag_status "curl" "${GREEN}" "${L_DIAG_CURL_OK}" "$(command -v curl)"
 else
 _diag_status "curl" "${RED}" "${L_DIAG_CURL_MISS}"
 _issues=$((_issues+1))
 fi

 # 5. aria2 config dosyası
 if [ -f "$ARIA2_CONF" ]; then
 _diag_status "aria2.conf" "${GREEN}" "${L_DIAG_CONF_OK}" "$ARIA2_CONF"
 else
 _diag_status "aria2.conf" "${RED}" "${L_DIAG_CONF_MISS}" "$ARIA2_CONF"
 _issues=$((_issues+1))
 fi

 # 6. Oturum (session) dosyası
 if [ -f "$ARIA2_SESSION" ]; then
 _diag_status "aria2.session" "${GREEN}" "${L_DIAG_SESSION_OK}" "$ARIA2_SESSION"
 else
 _diag_status "aria2.session" "${YELLOW}" "${L_DIAG_SESSION_MISS}" "$ARIA2_SESSION"
 _issues=$((_issues+1))
 fi

 # 7. Log dizini
 if [ -d "/opt/var/log" ]; then
 _diag_status "${L_DIAG_LBL_LOGDIR}" "${GREEN}" "${L_DIAG_LOGDIR_OK}" "/opt/var/log"
 else
 _diag_status "${L_DIAG_LBL_LOGDIR}" "${YELLOW}" "${L_DIAG_LOGDIR_MISS}" "/opt/var/log"
 _issues=$((_issues+1))
 fi

 # 8. İndirme dizini
 _dldir=$(conf_get "dir" 2>/dev/null)
 if [ -z "$_dldir" ]; then
 _diag_status "${L_DIAG_LBL_DLDIR}" "${YELLOW}" "${L_DIAG_DL_DIR_NOTSET}"
 _issues=$((_issues+1))
 elif [ -d "$_dldir" ]; then
 _dfree=$(df -h "$_dldir" 2>/dev/null | awk 'NR==2{print $4}')
 _diag_status "${L_DIAG_LBL_DLDIR}" "${GREEN}" "${L_DIAG_DL_DIR_OK}" "$_dldir [${L_DIAG_D_FREE}: ${_dfree:-?}]"
 else
 _diag_status "${L_DIAG_LBL_DLDIR}" "${RED}" "${L_DIAG_DL_DIR_MISS}" "$_dldir"
 _issues=$((_issues+1))
 fi

 # 9. aria2c servisi
 if status_check; then
 _pid=$(cat "$PID_FILE" 2>/dev/null)
 _diag_status "${L_DIAG_LBL_SERVICE}" "${GREEN}" "${L_DIAG_RUNNING}" "PID: ${_pid:-?}"
 else
 _diag_status "${L_DIAG_LBL_SERVICE}" "${RED}" "${L_DIAG_STOPPED}"
 fi

 # 10. Oto başlatma (init.d)
 if [ -f "$INIT_FILE" ]; then
 _diag_status "${L_DIAG_LBL_AUTOSTART}" "${GREEN}" "${L_DIAG_AUTOSTART_ON}" "$INIT_FILE"
 else
 _diag_status "${L_DIAG_LBL_AUTOSTART}" "${YELLOW}" "${L_DIAG_AUTOSTART_OFF}"
 fi

 # 11. RPC
 _rpc_en=$(conf_get "enable-rpc" 2>/dev/null)
 _rpc_port=$(conf_get "rpc-listen-port" 2>/dev/null); _rpc_port="${_rpc_port:-6800}"
 if [ "$_rpc_en" = "true" ]; then
 if status_check; then
 _rpc_secret_d=$(conf_get "rpc-secret" 2>/dev/null)
 [ -n "$_rpc_secret_d" ] && _rpc_auth_d="\"token:${_rpc_secret_d}\"" || _rpc_auth_d=""
 _rpc_resp=$(curl -s --connect-timeout 2 \
 "http://localhost:${_rpc_port}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getVersion\",\"id\":1,\"params\":[${_rpc_auth_d}]}" 2>/dev/null)
 if echo "$_rpc_resp" | grep -q '"result"'; then
 _rpc_ver=$(echo "$_rpc_resp" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
 _diag_status "RPC (port ${_rpc_port})" "${GREEN}" "${L_DIAG_RPC_OK}" "v${_rpc_ver:-?}"
 else
 _diag_status "RPC (port ${_rpc_port})" "${RED}" "${L_DIAG_RPC_FAIL}"
 _issues=$((_issues+1))
 fi
 else
 _diag_status "RPC (port ${_rpc_port})" "${YELLOW}" "${L_DIAG_ACTIVE} (${L_DIAG_D_RPCSVCDOWN})"
 fi
 else
 _diag_status "RPC" "${YELLOW}" "${L_DIAG_RPC_DISABLED}"
 fi

 # 12. RPC Secret Key
 _diag_sec=$(conf_get "rpc-secret" 2>/dev/null)
 if [ -n "$_diag_sec" ]; then
 _diag_status "${L_RPC_SECRET_LABEL}" "${GREEN}" "${_diag_sec}"
 else
 _diag_status "${L_RPC_SECRET_LABEL}" "${RED}" "${L_NOT_SET}"
 _issues=$((_issues+1))
 fi

 # ─── OPSİYONEL BİLEŞENLER ───────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ${L_DIAG_SEC_OPT}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # AriaNg + lighttpd
 if command -v lighttpd >/dev/null 2>&1; then
 _diag_status "lighttpd" "${GREEN}" "${L_DIAG_LIGHTTPD_OK}" "$(command -v lighttpd)"
 else
 _diag_status "lighttpd" "${YELLOW}" "${L_DIAG_LIGHTTPD_MISS}" "(${L_DIAG_OPTIONAL})"
 fi

 if ariang_is_installed; then
 if ariang_is_running; then
 _ang_p=$(cat "$ARIANG_PORT_FILE" 2>/dev/null || echo "6880")
 _ang_ip=$(ariang_get_ip 2>/dev/null)
 _diag_status "AriaNg WebUI" "${GREEN}" "${L_DIAG_ARIANG_RUNNING}" "http://${_ang_ip}:${_ang_p}/"
 else
 _diag_status "AriaNg WebUI" "${RED}" "${L_DIAG_ARIANG_STOPPED}" "(${L_DIAG_OPTIONAL}: kurulu ama durdu)"
 fi
 else
 _diag_status "AriaNg WebUI" "${YELLOW}" "${L_DIAG_ARIANG_NOT_INST}" "(${L_DIAG_OPTIONAL})"
 fi

 # Telegram
 _tg_en=$(tg_get TG_ENABLED 2>/dev/null)
 _tg_tok=$(tg_get TG_BOT_TOKEN 2>/dev/null)
 _tg_chat=$(tg_get TG_CHAT_ID 2>/dev/null)
 if [ "$_tg_en" = "true" ]; then
 _tg_issues=""
 [ -z "$_tg_tok" ] && _tg_issues="${_tg_issues} ${L_DIAG_TG_NO_TOKEN}"
 [ -z "$_tg_chat" ] && _tg_issues="${_tg_issues} ${L_DIAG_TG_NO_CHAT}"
 if [ -z "$_tg_issues" ]; then
 _diag_status "Telegram" "${GREEN}" "${L_DIAG_TG_ENABLED}" "token: $(echo "$_tg_tok" | cut -c1-8)..."
 else
 _diag_status "Telegram" "${RED}" "${L_DIAG_TG_ENABLED} " "$_tg_issues"
 fi
 else
 _diag_status "Telegram" "${YELLOW}" "${L_DIAG_TG_DISABLED}" "(${L_DIAG_OPTIONAL})"
 fi

 # ─── GÜNCELLEME KONTROLÜ ──────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ${L_DIAG_SEC_UPDATE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # Manager betiği güncelleme kontrolü
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\r" "$(pad_label "${L_DIAG_UPDATE_MGR}" 24)" "${L_DIAG_UPDATE_CHECKING}"
 _tmp_upd="/tmp/k2m_diag_update.sh"
 curl -fsSL --connect-timeout 8 "$UPDATE_URL" -o "$_tmp_upd" 2>/dev/null
 if [ -f "$_tmp_upd" ] && [ -s "$_tmp_upd" ]; then
 _remote_ver=$(grep -m1 '^SCRIPT_VERSION=' "$_tmp_upd" 2>/dev/null | cut -d'"' -f2)
 rm -f "$_tmp_upd" 2>/dev/null
 if [ -z "$_remote_ver" ]; then
 _diag_status "${L_DIAG_UPDATE_MGR}" "${YELLOW}" "${L_DIAG_UPDATE_FAIL}" "${L_DIAG_D_GHVER}"
 elif [ "$SCRIPT_VERSION" = "$_remote_ver" ]; then
 _diag_status "${L_DIAG_UPDATE_MGR}" "${GREEN}" "${L_DIAG_UPDATE_LATEST}" "${L_DIAG_D_LOCAL}: $SCRIPT_VERSION"
 else
 _diag_status "${L_DIAG_UPDATE_MGR}" "${YELLOW}" "${L_DIAG_UPDATE_AVAIL}" "${L_DIAG_D_LOCAL}: $SCRIPT_VERSION → ${L_DIAG_D_NEW}: $_remote_ver"
 fi
 else
 rm -f "$_tmp_upd" 2>/dev/null
 _diag_status "${L_DIAG_UPDATE_MGR}" "${YELLOW}" "${L_DIAG_UPDATE_FAIL}" "${L_DIAG_D_NOSERVER}"
 fi

 # aria2c opkg güncelleme kontrolü
 if aria2_installed; then
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\r" "$(pad_label "${L_DIAG_UPDATE_ARIA2}" 24)" "${L_DIAG_UPDATE_CHECKING}"
 _curr_a2=$(aria2_version)
 _avail_a2_full=$(opkg info aria2 2>/dev/null | grep -m1 '^Version:' | awk '{print $2}')
 [ -z "$_avail_a2_full" ] && _avail_a2_full=$(opkg list aria2 2>/dev/null | grep -m1 'aria2 ' | awk '{print $3}')
 _avail_a2=$(echo "$_avail_a2_full" | cut -d'-' -f1)
 if [ -z "$_avail_a2" ]; then
 _diag_status "${L_DIAG_UPDATE_ARIA2}" "${YELLOW}" "${L_DIAG_UPDATE_FAIL}" "${L_DIAG_D_OPKGFAIL}"
 elif [ "$_curr_a2" = "$_avail_a2" ]; then
 _diag_status "${L_DIAG_UPDATE_ARIA2}" "${GREEN}" "${L_DIAG_UPDATE_LATEST}" "v${_curr_a2}"
 else
 _diag_status "${L_DIAG_UPDATE_ARIA2}" "${YELLOW}" "${L_DIAG_UPDATE_AVAIL}" "${L_DIAG_D_INSTALLED}: v${_curr_a2} → ${L_DIAG_D_AVAILPKG}: ${_avail_a2_full}"
 fi
 else
 _diag_status "${L_DIAG_UPDATE_ARIA2}" "${RED}" "${L_DIAG_NOT_INSTALLED}" "${L_DIAG_D_MENU1}"
 fi

 # ─── ÖZELLİK TESTLERİ ────────────────────────────
 echo ""
 echo -e "${CYAN}${BOLD} ${L_DIAG_SEC_FUNC}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"

 # USB bağlı mı?
 _usb_list=$(detect_usb 2>/dev/null)
 if [ -n "$_usb_list" ]; then
 _usb_count=$(echo "$_usb_list" | tr ' ' '\n' | grep -c '\S')
 _diag_status "${L_DIAG_LBL_USB}" "${GREEN}" "${L_DIAG_OK}" "${_usb_count} ${L_DIAG_D_DISKS}: $(echo "$_usb_list" | tr '\n' ' ')"
 else
 _diag_status "${L_DIAG_LBL_USB}" "${YELLOW}" "${L_DIAG_WARN}" "${L_DIAG_D_NODISK}"
 fi

 # RPC işlevsel test (servis çalışıyorsa indirme sayısını al)
 if status_check && [ "$_rpc_en" = "true" ]; then
 _rs_test=$(conf_get "rpc-secret" 2>/dev/null)
 [ -n "$_rs_test" ] && _ra_test="\"token:${_rs_test}\"" || _ra_test=""
 _stat_resp=$(curl -s --connect-timeout 2 \
 "http://localhost:${_rpc_port}/jsonrpc" \
 -H "Content-Type: application/json" \
 -d "{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getGlobalStat\",\"id\":1,\"params\":[${_ra_test}]}" 2>/dev/null)
 if echo "$_stat_resp" | grep -q '"result"'; then
 _act_n=$(echo "$_stat_resp" | grep -o '"numActive":"[^"]*"' | cut -d'"' -f4)
 _wait_n=$(echo "$_stat_resp"| grep -o '"numWaiting":"[^"]*"' | cut -d'"' -f4)
 _diag_status "${L_DIAG_LBL_RPC_TEST}" "${GREEN}" "${L_DIAG_OK}" "${L_DIAG_D_ACTIVE}: ${_act_n:-0} ${L_DIAG_D_WAITING}: ${_wait_n:-0}"
 else
 _diag_status "${L_DIAG_LBL_RPC_TEST}" "${RED}" "${L_DIAG_FAIL}" "${L_DIAG_D_NORPC}"
 fi
 else
 _diag_status "${L_DIAG_LBL_RPC_TEST}" "${YELLOW}" "${L_DIAG_WARN}" "${L_DIAG_D_SVCRPC}"
 fi

 # İnternet bağlantısı testi
 _inet_ok=false
 if curl -s --connect-timeout 4 --max-time 5 https://github.com >/dev/null 2>&1; then
 _inet_ok=true
 _diag_status "${L_DIAG_LBL_INTERNET} (GitHub)" "${GREEN}" "${L_DIAG_OK}" "${L_DIAG_D_GITHUB}"
 elif curl -s --connect-timeout 4 --max-time 5 http://1.1.1.1 >/dev/null 2>&1; then
 _inet_ok=true
 _diag_status "${L_DIAG_LBL_INTERNET} (1.1.1.1)" "${GREEN}" "${L_DIAG_OK}" "${L_DIAG_D_CFONE}"
 else
 _diag_status "${L_DIAG_LBL_INTERNET}" "${RED}" "${L_DIAG_FAIL}" "${L_DIAG_D_NOINET}"
 fi

 # Telegram hook dosyaları
 _tg_hooks_ok=true
 for _hf in "$TG_HOOK_MAIN" "$TG_HOOK_COMPLETE" "$TG_HOOK_ERROR"; do
 [ -f "$_hf" ] || { _tg_hooks_ok=false; break; }
 done
 if [ "$_tg_en" = "true" ]; then
 if [ "$_tg_hooks_ok" = "true" ]; then
 _diag_status "${L_DIAG_LBL_TGHOOKS}" "${GREEN}" "${L_DIAG_OK}" "${L_DIAG_D_HOOKSOK}"
 else
 _diag_status "${L_DIAG_LBL_TGHOOKS}" "${YELLOW}" "${L_DIAG_WARN}" "${L_DIAG_D_HOOKSMISS}"
 fi
 else
 _diag_status "${L_DIAG_LBL_TGHOOKS}" "${YELLOW}" "${L_DIAG_INACTIVE}" "(${L_DIAG_OPTIONAL})"
 fi

 # ─── ÖZET ─────────────────────────────────────────
 echo ""
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e "${CYAN}${BOLD} ${L_DIAG_SUMMARY}${NC}"
 if [ "$_issues" -eq 0 ]; then
 echo -e " ${GREEN} ${L_DIAG_ALL_OK}${NC}"
 else
 echo -e " ${RED} ${L_DIAG_ISSUES} ${YELLOW}${_issues}${NC}"
 fi
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf " \033[2m%s\033[0m\n" "${L_DIAG_PRESS_R}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 }

 # ── F: Sorun Giderme / Fix Issues ──────────────────
 _diag_fix() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_DIAG_FIX_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"

 _fix_did_something=false

 # aria2c eksikse kur
 if ! aria2_installed; then
 echo -e "${YELLOW} ${L_DIAG_FIX_ARIA2}...${NC}"
 opkg update 2>&1 | tail -2
 if opkg install aria2 2>&1 | tail -3; then
 echo -e "${GREEN} aria2c ${L_DIAG_OK}.${NC}"
 _fix_did_something=true
 else
 echo -e "${RED} aria2c ${L_DIAG_FAIL}. ${L_INSTALL_FAIL}${NC}"
 fi
 sleep 1
 fi

 # curl eksikse kur
 if ! command -v curl >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_DIAG_FIX_CURL}...${NC}"
 opkg update >/dev/null 2>&1
 if opkg install curl 2>&1 | tail -3; then
 echo -e "${GREEN} curl ${L_DIAG_OK}.${NC}"
 _fix_did_something=true
 else
 echo -e "${RED} curl ${L_DIAG_FAIL}.${NC}"
 fi
 sleep 1
 fi

 # Config eksikse oluştur
 if [ ! -f "$ARIA2_CONF" ]; then
 echo -e "${YELLOW} ${L_DIAG_FIX_CONF}...${NC}"
 create_default_config
 _fix_did_something=true
 sleep 1
 fi

 # Session dosyası eksikse oluştur
 if [ ! -f "$ARIA2_SESSION" ]; then
 echo -e "${YELLOW} ${L_DIAG_FIX_SESSION}...${NC}"
 mkdir -p "$CONF_DIR" 2>/dev/null
 touch "$ARIA2_SESSION" 2>/dev/null
 echo -e "${GREEN} ${ARIA2_SESSION} ${L_DIAG_OK}.${NC}"
 _fix_did_something=true
 sleep 1
 fi

 # Log dizini eksikse oluştur
 if [ ! -d "/opt/var/log" ]; then
 echo -e "${YELLOW} ${L_DIAG_FIX_LOGDIR}...${NC}"
 mkdir -p "/opt/var/log" 2>/dev/null
 echo -e "${GREEN} /opt/var/log ${L_DIAG_OK}.${NC}"
 _fix_did_something=true
 sleep 1
 fi

 # İndirme dizini ayarlanmamışsa veya dizin yoksa USB tara / otomatik seç
 _dldir_fix=$(conf_get "dir" 2>/dev/null)
 if [ -z "$_dldir_fix" ] || [ ! -d "$_dldir_fix" ]; then
 echo -e "${YELLOW} ${L_DIAG_FIX_DLDIR}...${NC}"
 _usb_fix=$(detect_usb 2>/dev/null)
 if [ -n "$_usb_fix" ]; then
 _first_usb=$(echo "$_usb_fix" | tr ' ' '\n' | grep -v '^$' | head -1)
 _proposed="${_first_usb}/aria2/downloads"
 # USB varsa sormadan otomatik ayarla
 mkdir -p "$_proposed" 2>/dev/null
 conf_set "dir" "$_proposed"
 echo -e "${GREEN} ${L_USB_DIR_SET} ${_proposed}${NC}"
 _fix_did_something=true
 else
 # USB yoksa manuel sor
 printf " ${YELLOW}${L_DIAG_D_FIXDIR}${NC}"; read _fix_dir_manual
 if [ -n "$_fix_dir_manual" ]; then
 mkdir -p "$_fix_dir_manual" 2>/dev/null
 conf_set "dir" "$_fix_dir_manual"
 echo -e "${GREEN} ${L_USB_DIR_SET} ${_fix_dir_manual}${NC}"
 _fix_did_something=true
 fi
 fi
 sleep 1
 fi

 # Oto başlatma yoksa etkinleştir
 if [ ! -f "$INIT_FILE" ]; then
 echo -e "${YELLOW} ${L_DIAG_FIX_AUTOSTART}...${NC}"
 toggle_autostart
 _fix_did_something=true
 fi

 # Her şey hazırsa servisi başlat
 if aria2_installed && [ -f "$ARIA2_CONF" ] && ! status_check; then
 echo -e "${YELLOW}${L_SVC_STARTING}${NC}"
 start_service_silent
 sleep 2
 if status_check; then
 _pid_fix=$(cat "$PID_FILE" 2>/dev/null)
 echo -e "${GREEN} ${L_SVC_STARTED} PID: ${_pid_fix:-?}${NC}"
 _fix_did_something=true
 else
 echo -e "${RED} ${L_SVC_START_FAIL}${NC}"
 fi
 fi

 echo ""
 if [ "$_fix_did_something" = "true" ]; then
 echo -e "${GREEN}${BOLD} ${L_DIAG_FIX_DONE}${NC}"
 else
 echo -e "${CYAN}ℹ ${L_DIAG_FIX_NOTHING}${NC}"
 fi
 printf "${YELLOW}${L_PRESS_ENTER}${NC}"; read _
 }

 while true; do
 _diag_draw
 printf "${GREEN}${L_CHOICE_PROMPT}: ${NC}"; read _dc
 case "$_dc" in
 r|R) echo -e "${YELLOW}${L_HEALTH_REFRESHING}${NC}"; sleep 0.3 ;;
 f|F) _diag_fix ;;
 0|"") return ;;
 *) return ;;
 esac
 done
}

language_menu() {
 clear
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then CURR_D="${GREEN}English${NC}"; elif [ "$LANG_SEL" = "ru" ]; then CURR_D="${GREEN}Русский${NC}"; else CURR_D="${GREEN}Türkçe${NC}"; fi
 echo -e " ${YELLOW}●${NC} ${L_LANG_CURRENT} ${CURR_D}"; echo ""
 echo -e "${L_LANG_SELECT}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${L_LANG_TR}"
 echo -e " ${YELLOW}2)${NC} ${L_LANG_EN}"
 echo -e " ${YELLOW}3)${NC} ${L_LANG_RU}"
 echo -e " ${YELLOW}0)${NC} ${L_LANG_BACK}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-3]: ${NC}"; read lchoice
 case "$lchoice" in
 1) LANG_SEL="tr"; echo "tr" > "$LANG_FILE"; load_lang; echo -e "${GREEN} ${L_LANG_CHANGED} → Türkçe${NC}"; sleep 1 ;;
 2) LANG_SEL="en"; echo "en" > "$LANG_FILE"; load_lang; echo -e "${GREEN} ${L_LANG_CHANGED} → English${NC}"; sleep 1 ;;
 3) LANG_SEL="ru"; echo "ru" > "$LANG_FILE"; load_lang; echo -e "${GREEN} ${L_LANG_CHANGED} → Русский${NC}"; sleep 1 ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
}


# ============================================
# ARIANG WEB UI
# ============================================
ARIANG_DIR="/opt/www/ariang"
ARIANG_HTML="$ARIANG_DIR/index.html"
ARIANG_LIGHTTPD_CONF="/opt/etc/lighttpd/ariang.conf"
ARIANG_LIGHTTPD_INIT="/opt/etc/init.d/S81ariang"
ARIANG_PORT_FILE="/opt/etc/aria2/ariang_port"
ARIANG_PORT=6880
[ -f "$ARIANG_PORT_FILE" ] && ARIANG_PORT=$(cat "$ARIANG_PORT_FILE" 2>/dev/null)

ariang_get_ip() {
 _ip=$(ip route 2>/dev/null | awk '/^default/{print $3}' | head -1)
 [ -n "$_ip" ] && _ip=$(ip route get "$_ip" 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -1)
 [ -z "$_ip" ] && _ip=$(ifconfig br0 2>/dev/null | awk '/inet addr/{split($2,a,":"); print a[2]}' | head -1)
 [ -z "$_ip" ] && _ip=$(ifconfig eth0 2>/dev/null | awk '/inet addr/{split($2,a,":"); print a[2]}' | head -1)
 [ -z "$_ip" ] && _ip="192.168.1.1"
 echo "$_ip"
}

ariang_is_installed() { [ -f "$ARIANG_HTML" ] && command -v lighttpd >/dev/null 2>&1; }
ariang_is_running() { pidof lighttpd >/dev/null 2>&1; }

#cut here
#cut here

ariang_write_conf() {
 mkdir -p /opt/etc/lighttpd /opt/var/log /opt/var/run 2>/dev/null
 cat > "$ARIANG_LIGHTTPD_CONF" << LEOF
server.modules = ( "mod_staticfile", "mod_dirlisting" )
server.document-root = "$ARIANG_DIR"
server.port = $ARIANG_PORT
server.pid-file = "/opt/var/run/lighttpd-ariang.pid"
server.errorlog = "/opt/var/log/lighttpd-ariang.log"
index-file.names = ( "index.html" )
dir-listing.activate = "disable"
mimetype.assign = ( ".html" => "text/html; charset=utf-8", "" => "text/html" )
LEOF
}

ariang_write_init() {
 cat > "$ARIANG_LIGHTTPD_INIT" << 'INITEOF'
#!/bin/sh
CONF="/opt/etc/lighttpd/ariang.conf"
PID="/opt/var/run/lighttpd-ariang.pid"
case "$1" in
 start) [ -f "$CONF" ] && lighttpd -f "$CONF" >/dev/null 2>&1 ;;
 stop) kill $(cat "$PID" 2>/dev/null) 2>/dev/null; rm -f "$PID" ;;
 restart) $0 stop; sleep 1; $0 start ;;
esac
INITEOF
 chmod +x "$ARIANG_LIGHTTPD_INIT"
}

ariang_start() {
 if ! ariang_is_installed; then echo -e "${RED} ${L_ARIANG_NOT_INST_ERR}${NC}"; sleep 2; return 1; fi
 echo -e "${YELLOW}${L_ARIANG_STARTING}${NC}"
 ariang_write_conf
 kill $(cat /opt/var/run/lighttpd-ariang.pid 2>/dev/null) 2>/dev/null; sleep 1
 lighttpd -f "$ARIANG_LIGHTTPD_CONF" >/dev/null 2>&1; sleep 1
 if ariang_is_running; then
 echo -e "${GREEN} ${L_ARIANG_START_OK}${NC}"
 echo -e "${CYAN} ${L_ARIANG_URL_LABEL}: http://$(ariang_get_ip):${ARIANG_PORT}/${NC}"
 tg_notify "webui_start"
 else
 echo -e "${RED} ${L_ARIANG_START_FAIL}${NC}"
 tail -3 /opt/var/log/lighttpd-ariang.log 2>/dev/null
 fi
 sleep 3
}

ariang_stop() {
 echo -e "${YELLOW}${L_ARIANG_STOPPING}${NC}"
 kill $(cat /opt/var/run/lighttpd-ariang.pid 2>/dev/null) 2>/dev/null
 pkill lighttpd 2>/dev/null; rm -f /opt/var/run/lighttpd-ariang.pid; sleep 1
 echo -e "${GREEN} ${L_ARIANG_STOP_OK}${NC}"
 tg_notify "webui_stop"
 sleep 2
}

ariang_install() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_ARIANG_TITLE}${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 opkg update >/dev/null 2>&1
 if ! command -v lighttpd >/dev/null 2>&1; then
 echo -e "${YELLOW} ${L_ARIANG_LIGHTTPD_INST}${NC}"
 if ! opkg install lighttpd >/dev/null 2>&1; then
 echo -e "${RED} ${L_ARIANG_LIGHTTPD_FAIL}${NC}"; sleep 3; return 1
 fi
 fi
 echo -e "${YELLOW} ${L_ARIANG_WRITING}${NC}"
 ariang_write_html
 ariang_write_conf
 ariang_write_init
 kill $(cat /opt/var/run/lighttpd-ariang.pid 2>/dev/null) 2>/dev/null; sleep 1
 lighttpd -f "$ARIANG_LIGHTTPD_CONF" >/dev/null 2>&1; sleep 1
 echo ""
 if ariang_is_running; then
 _ip=$(ariang_get_ip)
 RPC_P=$(conf_get "rpc-listen-port"); RPC_P="${RPC_P:-6800}"
 echo -e "${GREEN} ${L_ARIANG_INSTALL_OK}${NC}"
 echo -e "${CYAN}${BOLD} http://${_ip}:${ARIANG_PORT}/${NC}"
 echo ""
 echo -e "${YELLOW} RPC: http://${_ip}:${RPC_P}/jsonrpc${NC}"
 else
 echo -e "${YELLOW} ${L_ARIANG_START_FAIL}${NC}"
 tail -5 /opt/var/log/lighttpd-ariang.log 2>/dev/null
 fi
 sleep 5
}

ariang_uninstall() {
 printf "${YELLOW}${L_ARIANG_CONFIRM_UNINST}${NC}"; read ans
 if [ "$ans" = "$L_CONFIRM_YES" ] || [ "$ans" = "$L_CONFIRM_YES2" ]; then
 ariang_stop 2>/dev/null
 rm -rf "$ARIANG_DIR"; rm -f "$ARIANG_LIGHTTPD_CONF" "$ARIANG_LIGHTTPD_INIT"
 echo -e "${GREEN} ${L_ARIANG_UNINSTALL_OK}${NC}"
 fi
 sleep 2
}

ariang_menu() {
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_ARIANG_TITLE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if ariang_is_installed; then
 echo -e " ${YELLOW}${NC} ${L_ARIANG_STATUS}: ${GREEN}${L_ARIANG_INSTALLED}${NC}"
 else
 echo -e " ${YELLOW}${NC} ${L_ARIANG_STATUS}: ${RED}${L_ARIANG_NOT_INSTALLED}${NC}"
 fi
 if ariang_is_running; then
 echo -e " ${YELLOW}${NC} Web UI : ${GREEN}${L_ARIANG_RUNNING}${NC} ${CYAN}http://$(ariang_get_ip):${ARIANG_PORT}/${NC}"
 else
 echo -e " ${YELLOW}${NC} Web UI : ${RED}${L_ARIANG_STOPPED}${NC}"
 fi
 echo -e " ${YELLOW}${NC} ${L_ARIANG_PORT} : ${CYAN}${ARIANG_PORT}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${GREEN}${L_ARIANG_INSTALL}${NC}"
 echo -e " ${YELLOW}2)${NC} ${RED}${L_ARIANG_UNINSTALL}${NC}"
 echo -e " ${YELLOW}3)${NC} ${CYAN}${L_ARIANG_START}${NC}"
 echo -e " ${YELLOW}4)${NC} ${RED}${L_ARIANG_STOP}${NC}"
 echo -e " ${YELLOW}0)${NC} ${L_ARIANG_BACK}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-4]: ${NC}"; read achoice
 case "$achoice" in
 1) ariang_install ;; 2) ariang_uninstall ;;
 3) ariang_start ;; 4) ariang_stop ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
 done
}

# ============================================
# OTO BAŞLATMA / AUTOSTART
# ============================================
toggle_autostart() {
 if [ -f "$INIT_FILE" ]; then
 printf "${YELLOW}${L_AUTO_INSTALLED}${NC}"; read rm_init
 if [ "$rm_init" = "$L_CONFIRM_YES" ] || [ "$rm_init" = "$L_CONFIRM_YES2" ]; then
 rm -f "$INIT_FILE"; echo -e "${GREEN} ${L_AUTO_REMOVED}${NC}"
 fi
 else
 cat > "$INIT_FILE" <<INITEOF
#!/bin/sh
# Keenetic Aria2 Manager - Auto Start
case "\$1" in
 start)
 pidof aria2c >/dev/null 2>&1 && exit 0
 aria2c --conf-path="$ARIA2_CONF" >>"$ARIA2_LOG" 2>&1 &
 echo \$! > "$PID_FILE"
 ;;
 stop)
 PID=\$(cat "$PID_FILE" 2>/dev/null)
 [ -n "\$PID" ] && kill "\$PID" 2>/dev/null
 pkill aria2c 2>/dev/null
 rm -f "$PID_FILE"
 ;;
 restart) \$0 stop; sleep 1; \$0 start ;;
esac
INITEOF
 chmod +x "$INIT_FILE"
 echo -e "${GREEN} ${L_AUTO_INSTALLED_OK} $INIT_FILE${NC}"
 fi
 sleep 2
}

# ============================================
# RPC AÇ/KAPAT / RPC TOGGLE
# ============================================
toggle_rpc_enabled() {
 _cur_rpc=$(conf_get "enable-rpc")
 if [ "$_cur_rpc" = "true" ]; then
 conf_set "enable-rpc" "false"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${YELLOW} RPC disabled. Restarting...${NC}"
 else
 echo -e "${YELLOW} RPC kapatıldı. Yeniden başlatılıyor...${NC}"
 fi
 else
 conf_set "enable-rpc" "true"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${GREEN} RPC enabled. Restarting...${NC}"
 else
 echo -e "${GREEN} RPC açıldı. Yeniden başlatılıyor...${NC}"
 fi
 fi
 if status_check; then
 stop_service_silent; sleep 1; start_service_silent; sleep 1
 fi
}

# ============================================
# ARIA2 YÖNETİM SUBMENÜSÜ / MANAGEMENT SUBMENU
# ============================================
aria2_management_menu() {
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} ${L_ARIA2_MGMT_TITLE}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 _LW2=14
 if status_check; then
 PID_NOW=$(cat "$PID_FILE" 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(PID: %s)${NC}\n" "$(pad_label "$L_SERVICE" $_LW2)" "$L_RUNNING" "${PID_NOW:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_SERVICE" $_LW2)" "$L_STOPPED"
 fi
 if aria2_installed; then
 ARIA2_VER=$(aria2_version)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(v%s)${NC}\n" "$(pad_label "$L_ARIA2C" $_LW2)" "$L_INSTALLED" "${ARIA2_VER:-?}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_ARIA2C" $_LW2)" "$L_NOT_INSTALLED"
 fi
 printf " ${BOLD}%s${NC} : %b\n" "$(pad_label "$L_AUTO_SHORT" $_LW2)" \
 "$([ -f "$INIT_FILE" ] && echo "${GREEN}${L_ACTIVE}${NC}" || echo "${RED}${L_INACTIVE}${NC}")"
 _ang_p=$(cat "$ARIANG_PORT_FILE" 2>/dev/null || echo "6880")
 if ariang_is_installed; then
 if ariang_is_running; then
 _ang_ip2=$(ariang_get_ip 2>/dev/null)
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}http://%s:%s/${NC}\n" "$(pad_label "AriaNg WebUI" $_LW2)" "$L_ARIANG_RUNNING" "${_ang_ip2}" "${_ang_p}"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${YELLOW}(%s)${NC}\n" "$(pad_label "AriaNg WebUI" $_LW2)" "$L_ARIANG_STOPPED" "$L_ARIANG_INSTALLED"
 fi
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "AriaNg WebUI" $_LW2)" "$L_ARIANG_NOT_INSTALLED"
 fi
 _mgmt_sec=$(conf_get "rpc-secret" 2>/dev/null)
 if [ -n "$_mgmt_sec" ]; then
 printf " ${BOLD}%s${NC} : ${YELLOW}%s${NC}\n" "$(pad_label "$L_RPC_SECRET_LABEL" $_LW2)" "$_mgmt_sec"
 else
 printf " ${BOLD}%s${NC} : ${RED}%s${NC}\n" "$(pad_label "$L_RPC_SECRET_LABEL" $_LW2)" "$L_NOT_SET"
 fi
 _mgmt_rpc_en=$(conf_get "enable-rpc" 2>/dev/null)
 _mgmt_rpc_port=$(conf_get "rpc-listen-port" 2>/dev/null); _mgmt_rpc_port="${_mgmt_rpc_port:-6800}"
 if [ "$_mgmt_rpc_en" = "true" ]; then
 _mgmt_rpc_lbl="$(if [ "$LANG_SEL" = "en" ]; then echo "ON"; elif [ "$LANG_SEL" = "ru" ]; then echo "ВКЛ"; else echo "AÇIK"; fi)"
 printf " ${BOLD}%s${NC} : ${GREEN}%s${NC} ${CYAN}(port: %s)${NC}\n" "$(pad_label "RPC" $_LW2)" "$_mgmt_rpc_lbl" "$_mgmt_rpc_port"
 else
 _mgmt_rpc_lbl="$(if [ "$LANG_SEL" = "en" ]; then echo "OFF"; elif [ "$LANG_SEL" = "ru" ]; then echo "ВЫКЛ"; else echo "KAPALI"; fi)"
 printf " ${BOLD}%s${NC} : ${RED}%s${NC} ${CYAN}(port: %s)${NC}\n" "$(pad_label "RPC" $_LW2)" "$_mgmt_rpc_lbl" "$_mgmt_rpc_port"
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${DIM_CYAN}── INFO ──────────────────────────────────────────${NC}"
 echo -e " ${CYAN}First install:${NC} Secret key (24-char) is auto-generated."
 echo -e " ${CYAN}USB detected:${NC} Download folder created at USB/aria2/downloads"
 echo -e " ${CYAN}Manual RPC Key:${NC} → Option 4 Settings to edit folder & secret."
 elif [ "$LANG_SEL" = "ru" ]; then
 echo -e "${DIM_CYAN}── О ПРОГРАММЕ ───────────────────────────────────${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${CYAN}При первой установке:${NC} 24-символьный Secret Key создаётся автоматически."
 echo -e " ${CYAN}При обнаружении USB:${NC} папка загрузок создана в USB/aria2/downloads"
 echo -e " ${CYAN}Для ручного RPC Key:${NC} → меню настроек под номером 4."
 echo -e " ${CYAN}Этот скрипт${NC} включает встроенный веб-интерфейс ${CYAN}AriaNg${NC};"
 echo -e " его можно активировать через меню ${CYAN}8${NC} и использовать"
 echo -e " ${GREEN}без необходимости скачивать${NC} веб-интерфейс на устройство."
 else
 echo -e "${DIM_CYAN}── HAKKINDA ──────────────────────────────────────${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${CYAN}İlk kurulumda${NC} 24 haneli Secret Key otomatik oluşturulur."
 echo -e " ${CYAN}USB algılanırsa${NC} USB/aria2/downloads klasörü otomatik kurulur."
 echo -e " ${CYAN}Manuel RPC Key için${NC} → 4 numaralı Ayarlar menüsünü kullanın."
 echo -e " ${CYAN}Bu betik,${NC} dahili olarak ${CYAN}AriaNg${NC} web arayüzü barındırır;"
 echo -e " menü ${CYAN}8)${NC}'den etkinleştirilebilir ve web arayüzünü"
 echo -e " ${CYAN}cihazınıza indirmeye gerek kalmadan${NC} ${GREEN}kullanabilirsiniz.${NC}"
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${GREEN}${L_START_SVC}${NC}"
 echo -e " ${YELLOW}2)${NC} ${RED}${L_STOP_SVC}${NC}"
 echo -e " ${YELLOW}3)${NC} ${CYAN}${L_RESTART_SVC}${NC}"
 echo -e " ${YELLOW}4)${NC} ${CYAN}${L_SETTINGS}${NC}"
 echo -e " ${YELLOW}5)${NC} ${MAGENTA}${L_INSTALL_ARIA2}${NC}"
 echo -e " ${YELLOW}6)${NC} ${L_AUTO_TOGGLE}"
 echo -e " ${YELLOW}7)${NC} ${CYAN}${L_ARIA2_UPDATE}${NC}"
 echo -e " ${YELLOW}8)${NC} ${CYAN}${L_ARIANG_MENU}${NC}"
 echo -e " ${YELLOW}9)${NC} ${RED}${L_ARIA2_ONLY_TITLE}${NC}"
 if [ "$_mgmt_rpc_en" = "true" ]; then
 echo -e " ${YELLOW}R)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_mgmt_rpc_port}) ${GREEN}ON${NC}"; elif [ "$LANG_SEL" = "ru" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_mgmt_rpc_port}) ${GREEN}ON${NC}"; else echo "RPC ${GREEN}Aç${NC}/${RED}Kapat${NC} (port: ${_mgmt_rpc_port}) ${GREEN}AÇIK${NC}"; fi)"
 else
 echo -e " ${YELLOW}R)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_mgmt_rpc_port}) ${RED}OFF${NC}"; elif [ "$LANG_SEL" = "ru" ]; then echo "RPC ${GREEN}On${NC}/${RED}Off${NC} (port: ${_mgmt_rpc_port}) ${RED}OFF${NC}"; else echo "RPC ${GREEN}Aç${NC}/${RED}Kapat${NC} (port: ${_mgmt_rpc_port}) ${RED}KAPALI${NC}"; fi)"
 fi
 echo -e " ${YELLOW}0)${NC} ${L_BACK_MAIN}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_CHOICE_PROMPT} [0-9, R]: ${NC}"; read mchoice
 case "$mchoice" in
 1) start_service ;; 2) stop_service ;; 3) restart_service ;;
 4) settings_menu ;; 5) install_aria2 ;; 6) toggle_autostart ;;
 r|R) toggle_rpc_enabled ;;
 7) update_aria2 ;;
 8) ariang_menu ;;
 9) uninstall_aria2_only ;;
 0) return ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
 done
}

# ============================================
# GİZLİ ARGÜMAN / HIDDEN ARG
# ============================================
if [ "$1" = "--start-daemon" ]; then
 pidof aria2c >/dev/null 2>&1 && exit 0
 [ -f "$ARIA2_CONF" ] && sed -i '/^daemon=true/d' "$ARIA2_CONF" 2>/dev/null
 aria2c --conf-path="$ARIA2_CONF" >>"$ARIA2_LOG" 2>&1 &
 ARIA2_PID=$!
 echo "$ARIA2_PID" > "$PID_FILE"
 exit 0
fi

# ============================================
# YARDIM & KULLANIM KILAVUZU / HELP MENU
# ============================================
backup_menu() {
 mkdir -p "$BACKUP_DIR"

 _backup_list() {
  # Yedekleri listele, tip bilgisiyle birlikte
  _bfiles=$(ls "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null)
  if [ -z "$_bfiles" ]; then
   if [ "$LANG_SEL" = "en" ]; then
    echo -e " ${RED}You have no backups.${NC}"
   else
    echo -e " ${RED}Hiç yedeğiniz yok.${NC}"
   fi
   return 1
  fi
  _bcount=$(echo "$_bfiles" | wc -l)
  if [ "$LANG_SEL" = "en" ]; then
   echo -e " ${GREEN}You have ${_bcount} backup(s):${NC}"
  else
   echo -e " ${GREEN}${_bcount} adet yedeğiniz bulunmaktadır:${NC}"
  fi
  echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${BACKUP_DIR}${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  echo -e "${DIM_CYAN}── $(if [ "$LANG_SEL" = "en" ]; then echo "BACKUP LIST"; elif [ "$LANG_SEL" = "ru" ]; then echo "СПИСОК РЕЗЕРВНЫХ КОПИЙ"; else echo "YEDEK LİSTESİ"; fi) ──────────────────────────────────${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  _i=1
  for _f in $_bfiles; do
   _fname=$(basename "$_f")
   _fsize=$(du -sh "$_f" 2>/dev/null | cut -f1)
   _fdate=$(echo "$_fname" | sed 's/aria2manager_backup_\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)_.*/\3.\2.\1 \4:\5/')
   if echo "$_fname" | grep -q "_basic"; then
    _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi)"
    _fcolor="${CYAN}"
   else
    _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi)"
    _fcolor="${GREEN}"
   fi
   echo -e " ${YELLOW}${_i})${NC} ${_fname}"
   echo -e "    ${_fcolor}${_ftype}${NC}  │  ${_fdate}  │  ${_fsize}"
   _i=$((_i+1))
  done
  return 0
 }

 _get_backup_file() {
  # $1 = numara, döndürür: seçilen dosya yolu
  _bfiles=$(ls "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null)
  echo "$_bfiles" | sed -n "${1}p"
 }

 while true; do
  clear
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "BACKUP & RESTORE"; elif [ "$LANG_SEL" = "ru" ]; then echo "РЕЗЕРВНАЯ КОПИЯ И ВОССТАНОВЛЕНИЕ"; else echo "YEDEK & GERİ YÜKLEME"; fi)${NC}"
  echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
  _backup_list
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  echo -e " ${YELLOW}1)${NC} ${CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi)${NC}"
  echo -e " ${YELLOW}2)${NC} ${GREEN}$(if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi)${NC}"
  echo -e " ${YELLOW}3)${NC} ${MAGENTA}$(if [ "$LANG_SEL" = "en" ]; then echo "Restore from Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Восстановить из копии"; else echo "Yedekten Geri Yükle"; fi)${NC}"
  echo -e " ${YELLOW}4)${NC} ${RED}$(if [ "$LANG_SEL" = "en" ]; then echo "Delete Backups"; elif [ "$LANG_SEL" = "ru" ]; then echo "Удалить копии"; else echo "Yedekleri Sil"; fi)${NC}"
  echo -e " ${YELLOW}0)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "Back to Main Menu"; elif [ "$LANG_SEL" = "ru" ]; then echo "Назад в главное меню"; else echo "Ana Menüye Dön"; fi)"
  echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
  printf "${GREEN}${L_CHOICE_PROMPT} [0-4]: ${NC}"; read _bc

  case "$_bc" in

  1)
   clear
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "BASIC BACKUP"; elif [ "$LANG_SEL" = "ru" ]; then echo "БАЗОВАЯ РЕЗЕРВНАЯ КОПИЯ"; else echo "TEMEL YEDEK"; fi)${NC}"
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   if [ "$LANG_SEL" = "en" ]; then
    echo -e " The following files will be backed up:"
    echo -e " ${CYAN}•${NC} aria2.conf ${DIM_CYAN}(all settings)${NC}"
    echo -e " ${CYAN}•${NC} telegram.conf ${DIM_CYAN}(Telegram token, chat ID, settings)${NC}"
    echo -e " ${CYAN}•${NC} lang ${DIM_CYAN}(language preference)${NC}"
   else
    echo -e " Şu dosyalar yedeklenecek:"
    echo -e " ${CYAN}•${NC} aria2.conf ${DIM_CYAN}(tüm config ayarları)${NC}"
    echo -e " ${CYAN}•${NC} telegram.conf ${DIM_CYAN}(Telegram token, chat ID, ayarlar)${NC}"
    echo -e " ${CYAN}•${NC} lang ${DIM_CYAN}(dil tercihi)${NC}"
   fi
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   _backup_list
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Create basic backup? [Y/N]: "; elif [ "$LANG_SEL" = "ru" ]; then echo "Создать базовую копию? [Д/Н]: "; else echo "Temel yedek alınsın mı? [E/H]: "; fi)"; read _ans
   case "$_ans" in
    [EeYy])
     _ts=$(date +%Y%m%d_%H%M)
     _bfile="${BACKUP_DIR}/aria2manager_backup_${_ts}_basic.tar.gz"
     mkdir -p "$BACKUP_DIR"
     # Var olan dosyaları topla
     _basic_files=""
     [ -f "$ARIA2_CONF" ]  && _basic_files="$_basic_files aria2.conf"
     [ -f "$TG_CONF" ]     && _basic_files="$_basic_files telegram.conf"
     [ -f "$LANG_FILE" ]   && _basic_files="$_basic_files lang"
     # En az bir dosya varsa yedekle, yoksa dizini yedekle
     if [ -n "$_basic_files" ]; then
      tar -czf "$_bfile" -C "$CONF_DIR" $_basic_files 2>/dev/null
     else
      tar -czf "$_bfile" -C "$(dirname $CONF_DIR)" "$(basename $CONF_DIR)" 2>/dev/null
     fi
     if [ -f "$_bfile" ]; then
      _fsize=$(du -sh "$_bfile" 2>/dev/null | cut -f1)
      echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup created:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Резервная копия создана:"; else echo "Yedek oluşturuldu:"; fi)${NC}"
      echo -e " ${CYAN}$(basename $_bfile)${NC}"
      echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_bfile}${NC}  │  ${_fsize}"
      _tg_type="$(if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi)"
      _fdate=$(date "+%d.%m.%Y %H:%M")
      _tg_extra="📁 $(if [ "$LANG_SEL" = "en" ]; then echo "File:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл:"; else echo "Dosya:"; fi) $(basename $_bfile)
🏷 $(if [ "$LANG_SEL" = "en" ]; then echo "Type:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Тип:"; else echo "Tür:"; fi) ${_tg_type}
📅 $(if [ "$LANG_SEL" = "en" ]; then echo "Date:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Дата:"; else echo "Tarih:"; fi) ${_fdate}
📦 $(if [ "$LANG_SEL" = "en" ]; then echo "Size:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Размер:"; else echo "Boyut:"; fi) ${_fsize}
📂 $(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_bfile}"
      tg_notify "backup_created" "$_tg_extra"
     else
      echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup failed!"; elif [ "$LANG_SEL" = "ru" ]; then echo "Резервное копирование не удалось!"; else echo "Yedekleme başarısız!"; fi)${NC}"
     fi
     sleep 3
     ;;
    *)
     echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup cancelled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Создание копии отменено."; else echo "Yedekleme iptal edildi."; fi)${NC}"; sleep 2 ;;
   esac
   ;;

  2)
   clear
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "FULL BACKUP"; elif [ "$LANG_SEL" = "ru" ]; then echo "ПОЛНАЯ РЕЗЕРВНАЯ КОПИЯ"; else echo "TAM YEDEK"; fi)${NC}"
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   if [ "$LANG_SEL" = "en" ]; then
    echo -e " The following files will be backed up:"
    echo -e " ${CYAN}•${NC} aria2.conf ${DIM_CYAN}(all config settings)${NC}"
    echo -e " ${CYAN}•${NC} telegram.conf ${DIM_CYAN}(Telegram token, chat ID, settings)${NC}"
    echo -e " ${CYAN}•${NC} lang ${DIM_CYAN}(language preference)${NC}"
    echo -e " ${CYAN}•${NC} aria2.session ${DIM_CYAN}(active download sessions)${NC}"
    echo -e " ${CYAN}•${NC} S99aria2 ${DIM_CYAN}(autostart init script)${NC}"
    echo -e " ${CYAN}•${NC} tg_notify.sh + hook scripts ${DIM_CYAN}(all Telegram hooks)${NC}"
    echo -e " ${CYAN}•${NC} ariang_port ${DIM_CYAN}(AriaNg port config)${NC}"
   else
    echo -e " Şu dosyalar yedeklenecek:"
    echo -e " ${CYAN}•${NC} aria2.conf ${DIM_CYAN}(tüm config ayarları)${NC}"
    echo -e " ${CYAN}•${NC} telegram.conf ${DIM_CYAN}(Telegram token, chat ID, ayarlar)${NC}"
    echo -e " ${CYAN}•${NC} lang ${DIM_CYAN}(dil tercihi)${NC}"
    echo -e " ${CYAN}•${NC} aria2.session ${DIM_CYAN}(aktif indirme oturumları)${NC}"
    echo -e " ${CYAN}•${NC} S99aria2 ${DIM_CYAN}(otomatik başlatma init scripti)${NC}"
    echo -e " ${CYAN}•${NC} tg_notify.sh + hook scriptleri ${DIM_CYAN}(tüm Telegram hookları)${NC}"
    echo -e " ${CYAN}•${NC} ariang_port ${DIM_CYAN}(AriaNg port ayarı)${NC}"
   fi
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   _backup_list
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Create full backup? [Y/N]: "; elif [ "$LANG_SEL" = "ru" ]; then echo "Создать полную копию? [Д/Н]: "; else echo "Tam yedek alınsın mı? [E/H]: "; fi)"; read _ans
   case "$_ans" in
    [EeYy])
     _ts=$(date +%Y%m%d_%H%M)
     _bfile="${BACKUP_DIR}/aria2manager_backup_${_ts}_full.tar.gz"
     mkdir -p "$BACKUP_DIR"
     # Yedeklenecek dosyaları topla
     _files=""
     [ -f "$CONF_DIR/aria2.conf" ]        && _files="$_files aria2.conf"
     [ -f "$CONF_DIR/telegram.conf" ]     && _files="$_files telegram.conf"
     [ -f "$CONF_DIR/lang" ]              && _files="$_files lang"
     [ -f "$CONF_DIR/aria2.session" ]     && _files="$_files aria2.session"
     [ -f "$CONF_DIR/tg_notify.sh" ]      && _files="$_files tg_notify.sh"
     [ -f "$CONF_DIR/tg_on_complete.sh" ] && _files="$_files tg_on_complete.sh"
     [ -f "$CONF_DIR/tg_on_error.sh" ]    && _files="$_files tg_on_error.sh"
     [ -f "$CONF_DIR/tg_on_dl_start.sh" ] && _files="$_files tg_on_dl_start.sh"
     [ -f "$CONF_DIR/tg_on_stop.sh" ]     && _files="$_files tg_on_stop.sh"
     [ -f "$CONF_DIR/ariang_port" ]       && _files="$_files ariang_port"
     # Dosya yoksa dizini yedekle
     if [ -z "$_files" ]; then
      _files="."
     fi
     if [ -f "$INIT_FILE" ]; then
      tar -czf "$_bfile" -C "$CONF_DIR" $_files -C /opt/etc/init.d S99aria2 2>/dev/null
     else
      tar -czf "$_bfile" -C "$CONF_DIR" $_files 2>/dev/null
     fi
     if [ -f "$_bfile" ]; then
      _fsize=$(du -sh "$_bfile" 2>/dev/null | cut -f1)
      echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup created:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Резервная копия создана:"; else echo "Yedek oluşturuldu:"; fi)${NC}"
      echo -e " ${CYAN}$(basename $_bfile)${NC}"
      echo -e " ${DIM_CYAN}$(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_bfile}${NC}  │  ${_fsize}"
      _tg_type2="$(if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi)"
      _fdate2=$(date "+%d.%m.%Y %H:%M")
      _tg_extra2="📁 $(if [ "$LANG_SEL" = "en" ]; then echo "File:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл:"; else echo "Dosya:"; fi) $(basename $_bfile)
🏷 $(if [ "$LANG_SEL" = "en" ]; then echo "Type:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Тип:"; else echo "Tür:"; fi) ${_tg_type2}
📅 $(if [ "$LANG_SEL" = "en" ]; then echo "Date:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Дата:"; else echo "Tarih:"; fi) ${_fdate2}
📦 $(if [ "$LANG_SEL" = "en" ]; then echo "Size:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Размер:"; else echo "Boyut:"; fi) ${_fsize}
📂 $(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_bfile}"
      tg_notify "backup_created" "$_tg_extra2"
     else
      echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup failed!"; elif [ "$LANG_SEL" = "ru" ]; then echo "Резервное копирование не удалось!"; else echo "Yedekleme başarısız!"; fi)${NC}"
     fi
     sleep 3
     ;;
    *)
     echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Backup cancelled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Создание копии отменено."; else echo "Yedekleme iptal edildi."; fi)${NC}"; sleep 2 ;;
   esac
   ;;

  3)
   clear
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "RESTORE FROM BACKUP"; elif [ "$LANG_SEL" = "ru" ]; then echo "ВОССТАНОВЛЕНИЕ ИЗ КОПИИ"; else echo "YEDEKTEN GERİ YÜKLE"; fi)${NC}"
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   if ! _backup_list; then
    printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Press Enter to go back..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Нажмите Enter для возврата..."; else echo "Geri dönmek için Enter'a basın..."; fi)"; read _
    continue
   fi
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   _bcount=$(ls "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null | wc -l)
   printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Select backup number (0=cancel): "; elif [ "$LANG_SEL" = "ru" ]; then echo "Select backup number (0=cancel): "; else echo "Yedek numarasını seçin (0=iptal): "; fi)"; read _sel
   [ "$_sel" = "0" ] || [ -z "$_sel" ] && continue
   _chosen=$(_get_backup_file "$_sel")
   if [ -z "$_chosen" ] || [ ! -f "$_chosen" ]; then
    echo -e "${RED} ${L_INVALID}${NC}"; sleep 2; continue
   fi
   _fname=$(basename "$_chosen")
   if echo "$_fname" | grep -q "_basic"; then
    _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi)"
   else
    _ftype="$(if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi)"
   fi
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   echo -e " $(if [ "$LANG_SEL" = "en" ]; then echo "Selected:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Выбрано:"; else echo "Seçilen:"; fi) ${CYAN}${_fname}${NC} ${YELLOW}(${_ftype})${NC}"
   if [ "$LANG_SEL" = "en" ]; then
    echo -e " ${RED}The current config will be overwritten!${NC}"
    printf " Confirm restore? [Y/N]: "
   else
    echo -e " ${RED}Mevcut config dosyaları üzerine yazılacak!${NC}"
    printf " Geri yüklemeyi onaylıyor musunuz? [E/H]: "
   fi
   read _conf
   case "$_conf" in
    [EeYy])
     echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Stopping service..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Остановка сервиса..."; else echo "Servis durduruluyor..."; fi)${NC}"
     stop_service_silent 2>/dev/null
     sleep 1
     echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Restoring files..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Восстановление файлов..."; else echo "Dosyalar geri yükleniyor..."; fi)${NC}"
     tar -xzf "$_chosen" -C "$CONF_DIR" 2>/dev/null
     # init dosyasını yerine koy
     if tar -tzf "$_chosen" 2>/dev/null | grep -q "S99aria2"; then
      tar -xzf "$_chosen" -C /opt/etc/init.d S99aria2 2>/dev/null
      chmod +x "$INIT_FILE" 2>/dev/null
     fi
     # Dil tercihini yeniden oku
     [ -f "$LANG_FILE" ] && LANG_SEL=$(cat "$LANG_FILE" 2>/dev/null)
     echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Restore complete! Restarting service..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Восстановление завершено! Перезапуск сервиса..."; else echo "Geri yükleme tamamlandı! Servis yeniden başlatılıyor..."; fi)${NC}"
     sleep 1
     start_service_silent
     sleep 2
     echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Done. Everything restored as it was."; elif [ "$LANG_SEL" = "ru" ]; then echo "Готово. Всё восстановлено."; else echo "Tamamdır. Her şey eski haline getirildi."; fi)${NC}"
     _rfname=$(basename "$_chosen")
     _rfsize=$(du -sh "$_chosen" 2>/dev/null | cut -f1)
     _rtype="$(echo "$_rfname" | grep -q "_basic" && (if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi) || (if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi))"
     _rdate=$(date "+%d.%m.%Y %H:%M")
     _tg_restore="📁 $(if [ "$LANG_SEL" = "en" ]; then echo "File:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл:"; else echo "Dosya:"; fi) ${_rfname}
🏷 $(if [ "$LANG_SEL" = "en" ]; then echo "Type:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Тип:"; else echo "Tür:"; fi) ${_rtype}
📅 $(if [ "$LANG_SEL" = "en" ]; then echo "Date:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Дата:"; else echo "Tarih:"; fi) ${_rdate}
📦 $(if [ "$LANG_SEL" = "en" ]; then echo "Size:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Размер:"; else echo "Boyut:"; fi) ${_rfsize}
📂 $(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_chosen}"
     tg_notify "backup_restored" "$_tg_restore"
     sleep 3
     ;;
    *)
     echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Restore cancelled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Восстановление отменено."; else echo "Geri yükleme iptal edildi."; fi)${NC}"; sleep 2 ;;
   esac
   ;;

  4)
   clear
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   echo -e "${RED}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "DELETE BACKUPS"; elif [ "$LANG_SEL" = "ru" ]; then echo "УДАЛИТЬ РЕЗЕРВНЫЕ КОПИИ"; else echo "YEDEKLERİ SİL"; fi)${NC}"
   echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
   if ! _backup_list; then
    printf " $(if [ "$LANG_SEL" = "en" ]; then echo "Press Enter to go back..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Нажмите Enter для возврата..."; else echo "Geri dönmek için Enter'a basın..."; fi)"; read _; continue
   fi
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   echo -e " ${YELLOW}A)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "${RED}Delete ALL backups${NC}"; elif [ "$LANG_SEL" = "ru" ]; then echo "${RED}Delete ALL backups${NC}"; else echo "${RED}Tüm yedekleri sil${NC}"; fi)"
   echo -e " ${YELLOW}#)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "Enter number to delete one"; elif [ "$LANG_SEL" = "ru" ]; then echo "Введите номер для удаления"; else echo "Tek silmek için numara girin"; fi)"
   echo -e " ${YELLOW}0)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "Cancel"; elif [ "$LANG_SEL" = "ru" ]; then echo "Отмена"; else echo "İptal"; fi)"
   echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
   printf "${GREEN}${L_CHOICE_PROMPT}: ${NC}"; read _dsel
   case "$_dsel" in
    [Aa])
     printf " ${RED}$(if [ "$LANG_SEL" = "en" ]; then echo "Delete ALL backups? [Y/N]: "; elif [ "$LANG_SEL" = "ru" ]; then echo "Удалить ВСЕ копии? [Д/Н]: "; else echo "Tüm yedekler silinsin mi? [E/H]: "; fi)${NC}"; read _dconf
     case "$_dconf" in
      [EeYy])
       rm -f "$BACKUP_DIR"/aria2manager_backup_*.tar.gz 2>/dev/null
       echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "All backups deleted."; elif [ "$LANG_SEL" = "ru" ]; then echo "Все копии удалены."; else echo "Tüm yedekler silindi."; fi)${NC}"
       tg_notify "backup_deleted" "$(if [ "$LANG_SEL" = "en" ]; then echo "All backups deleted."; elif [ "$LANG_SEL" = "ru" ]; then echo "Все копии удалены."; else echo "Tüm yedekler silindi."; fi)"
       sleep 2 ;;
      *) echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Cancelled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Отменено."; else echo "İptal edildi."; fi)${NC}"; sleep 2 ;;
     esac ;;
    0) ;;
    *)
     _dtarget=$(_get_backup_file "$_dsel")
     if [ -z "$_dtarget" ] || [ ! -f "$_dtarget" ]; then
      echo -e "${RED} ${L_INVALID}${NC}"; sleep 2
     else
      _dfname=$(basename "$_dtarget")
      printf " ${RED}$(if [ "$LANG_SEL" = "en" ]; then echo "Delete '${_dfname}'? [Y/N]: "; elif [ "$LANG_SEL" = "ru" ]; then echo "Delete '${_dfname}'? [Y/N]: "; else echo "'${_dfname}' silinsin mi? [E/H]: "; fi)${NC}"; read _dconf2
      case "$_dconf2" in
       [EeYy])
        rm -f "$_dtarget" 2>/dev/null
        _ddate=$(date "+%d.%m.%Y %H:%M")
        _dsize_del=$(du -sh "$_dtarget" 2>/dev/null | cut -f1 || echo "?")
        _dtype=$(echo "$_dfname" | grep -q "_basic" && (if [ "$LANG_SEL" = "en" ]; then echo "Basic Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Базовая резервная копия"; else echo "Temel Yedek"; fi) || (if [ "$LANG_SEL" = "en" ]; then echo "Full Backup"; elif [ "$LANG_SEL" = "ru" ]; then echo "Полная резервная копия"; else echo "Tam Yedek"; fi))
        echo -e "${GREEN} $(if [ "$LANG_SEL" = "en" ]; then echo "Deleted."; elif [ "$LANG_SEL" = "ru" ]; then echo "Удалено."; else echo "Silindi."; fi)${NC}"
        _tg_del="📁 $(if [ "$LANG_SEL" = "en" ]; then echo "File:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Файл:"; else echo "Dosya:"; fi) ${_dfname}
🏷 $(if [ "$LANG_SEL" = "en" ]; then echo "Type:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Тип:"; else echo "Tür:"; fi) ${_dtype}
📅 $(if [ "$LANG_SEL" = "en" ]; then echo "Date:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Дата:"; else echo "Tarih:"; fi) ${_ddate}
📦 $(if [ "$LANG_SEL" = "en" ]; then echo "Size:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Размер:"; else echo "Boyut:"; fi) ${_dsize_del}
📂 $(if [ "$LANG_SEL" = "en" ]; then echo "Location:"; elif [ "$LANG_SEL" = "ru" ]; then echo "Расположение:"; else echo "Konum:"; fi) ${_dtarget}"
        tg_notify "backup_deleted" "$_tg_del"
        sleep 2 ;;
       *) echo -e "${YELLOW} $(if [ "$LANG_SEL" = "en" ]; then echo "Cancelled."; elif [ "$LANG_SEL" = "ru" ]; then echo "Отменено."; else echo "İptal edildi."; fi)${NC}"; sleep 2 ;;
      esac
     fi ;;
   esac
   ;;

  0) return ;;
  *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
  esac
 done
}

help_menu() {
 while true; do
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e "${CYAN}${BOLD} $(if [ "$LANG_SEL" = "en" ]; then echo "HELP & USER GUIDE"; elif [ "$LANG_SEL" = "ru" ]; then echo "ПОМОЩЬ И РУКОВОДСТВО"; else echo "YARDIM & KULLANIM KILAVUZU"; fi)${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e " ${YELLOW}1)${NC} What is this script?"
 echo -e " ${YELLOW}2)${NC} Main Menu"
 echo -e " ${YELLOW}3)${NC} Menu 1 — aria2 Management"
 echo -e " ${YELLOW}4)${NC} Menu 1 → Settings (option 4)"
 echo -e " ${YELLOW}5)${NC} Menu 2 — Add Download"
 echo -e " ${YELLOW}6)${NC} Menu 3 — Active Downloads"
 echo -e " ${YELLOW}7)${NC} Menu 4 — USB Scan"
 echo -e " ${YELLOW}8)${NC} Menu 6 — Telegram Notifications"
 echo -e " ${YELLOW}9)${NC} S) System Health / H) Diagnostics"
 echo -e " ${YELLOW}A)${NC} RPC — What is it & how to use"
 echo -e " ${YELLOW}B)${NC} AriaNg WebUI"
 echo -e " ${YELLOW}C)${NC} First Install — Auto Setup"
 echo -e " ${YELLOW}D)${NC} FAQ — Common Questions"
 else
 echo -e " ${YELLOW}1)${NC} Bu betik nedir?"
 echo -e " ${YELLOW}2)${NC} Ana Menü"
 echo -e " ${YELLOW}3)${NC} Menü 1 — aria2 Yönetimi"
 echo -e " ${YELLOW}4)${NC} Menü 1 → Ayarlar (seçenek 4)"
 echo -e " ${YELLOW}5)${NC} Menü 2 — İndirme Ekle"
 echo -e " ${YELLOW}6)${NC} Menü 3 — Aktif İndirmeler"
 echo -e " ${YELLOW}7)${NC} Menü 4 — USB Tara"
 echo -e " ${YELLOW}8)${NC} Menü 6 — Telegram Bildirimleri"
 echo -e " ${YELLOW}9)${NC} S) Sistem Sağlığı / H) Tanı & Test"
 echo -e " ${YELLOW}A)${NC} RPC — Nedir, nasıl kullanılır?"
 echo -e " ${YELLOW}B)${NC} AriaNg WebUI"
 echo -e " ${YELLOW}C)${NC} İlk Kurulum — Otomatik Yapılandırma"
 echo -e " ${YELLOW}D)${NC} SSS — Sık Sorulan Sorular"
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}0)${NC} $(if [ "$LANG_SEL" = "en" ]; then echo "Back to Main Menu"; elif [ "$LANG_SEL" = "ru" ]; then echo "Назад в главное меню"; else echo "Ana Menüye Dön"; fi)"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}$(if [ "$LANG_SEL" = "en" ]; then echo "Your choice"; elif [ "$LANG_SEL" = "ru" ]; then echo "Your choice"; else echo "Seçiminiz"; fi) [0-9, A-D]: ${NC}"; read hchoice
 case "$hchoice" in
 1) help_page_1 ;;
 2) help_page_2 ;;
 3) help_page_3 ;;
 4) help_page_4 ;;
 5) help_page_5 ;;
 6) help_page_6 ;;
 7) help_page_7 ;;
 8) help_page_8 ;;
 9) help_page_9 ;;
 a|A) help_page_A ;;
 b|B) help_page_B ;;
 c|C) help_page_C ;;
 d|D) help_page_D ;;
 0) return ;;
 *) echo -e "${RED} $(if [ "$LANG_SEL" = "en" ]; then echo "Invalid selection."; elif [ "$LANG_SEL" = "ru" ]; then echo "Неверный выбор."; else echo "Geçersiz seçim."; fi)${NC}"; sleep 1 ;;
 esac
 done
}

_help_pause() {
 echo ""
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 printf "${YELLOW}$(if [ "$LANG_SEL" = "en" ]; then echo "Press Enter to go back..."; elif [ "$LANG_SEL" = "ru" ]; then echo "Нажмите Enter для возврата..."; else echo "Geri dönmek için Enter'a basın..."; fi)${NC}"; read _
}

help_page_1() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} WHAT IS THIS SCRIPT?${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${CYAN}Keenetic Aria2 Manager${NC} is a shell script designed"
 echo -e " for Keenetic routers. It manages the ${CYAN}aria2c${NC}"
 echo -e " download daemon entirely from a terminal menu."
 echo -e ""
 echo -e " ${YELLOW}What it does:${NC}"
 echo -e " • Installs / uninstalls aria2c via opkg"
 echo -e " • Starts, stops, restarts the aria2 service"
 echo -e " • Adds downloads by URL (HTTP/FTP/Magnet/Torrent)"
 echo -e " • Lists active, waiting and completed downloads"
 echo -e " • Scans USB drives and sets the download folder"
 echo -e " • Sends Telegram notifications on events"
 echo -e " • Exposes an RPC API for AriaNg WebUI"
 echo -e " • Auto-configures on first run (secret key + USB path)"
 echo -e ""
 echo -e " ${YELLOW}Runs on:${NC} Keenetic OS (sh/ash compatible)"
 echo -e " ${YELLOW}Author:${NC} SoulsTurk"
 echo -e " ${YELLOW}GitHub:${NC} github.com/SoulsTurk/keenetic-aria2-manager"
 else
 echo -e "${CYAN}${BOLD} BU BETİK NEDİR?${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${CYAN}Keenetic Aria2 Manager${NC}; Keenetic tabanlı"
 echo -e " routerlar için geliştirilmiş bir kabuk betiğidir."
 echo -e " Terminal üzerinden tam menü arayüzüyle ${CYAN}aria2c${NC} indirme"
 echo -e " arka plan servisini yönetir."
 echo -e ""
 echo -e " ${YELLOW}Ne yapar?${NC}"
 echo -e " • aria2c'yi opkg ile kurar / kaldırır"
 echo -e " • Servisi başlatır, durdurur, yeniden başlatır"
 echo -e " • URL ile indirme ekler (HTTP/FTP/Magnet/Torrent)"
 echo -e " • Aktif, bekleyen ve tamamlanan indirmeleri listeler"
 echo -e " • USB diskleri tarar ve indirme klasörünü ayarlar"
 echo -e " • İndirme olaylarında Telegram bildirimi gönderir"
 echo -e " • AriaNg WebUI için RPC API sunar"
 echo -e " • İlk çalıştırmada otomatik yapılandırır (key + USB)"
 echo -e ""
 echo -e " ${YELLOW}Çalıştığı sistemler:${NC} Keenetic OS (sh/ash)"
 echo -e " ${YELLOW}Geliştirici:${NC} SoulsTurk"
 echo -e " ${YELLOW}GitHub:${NC} github.com/SoulsTurk/keenetic-aria2-manager"
 fi
 _help_pause
}

help_page_2() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MAIN MENU${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " The main menu is the entry point of the script."
 echo -e " At the top, the ${CYAN}header${NC} shows real-time status:"
 echo -e " • System name, uptime, WAN IP"
 echo -e " • Service (running / stopped)"
 echo -e " • aria2c version"
 echo -e " • Active downloads & speed"
 echo -e " • RPC status & port"
 echo -e " • AriaNg WebUI status"
 echo -e " • RPC Secret Key"
 echo -e ""
 echo -e " ${YELLOW}Menu items:${NC}"
 echo -e " ${YELLOW}1)${NC} aria2 Management — service, settings, install"
 echo -e " ${YELLOW}2)${NC} Add Download — enter a URL to download"
 echo -e " ${YELLOW}3)${NC} Current Downloads — live list of tasks"
 echo -e " ${YELLOW}4)${NC} USB Scan — detect USB, set download dir"
 echo -e " ${YELLOW}5)${NC} View Logs — last 100 lines of aria2.log"
 echo -e " ${YELLOW}6)${NC} Telegram — configure notifications"
 echo -e " ${YELLOW}S)${NC} System Health — CPU/RAM/disk/network"
 echo -e " ${YELLOW}H)${NC} Diagnostics — full environment test"
 echo -e " ${YELLOW}M)${NC} Help — this guide"
 echo -e " ${YELLOW}L)${NC} Language — TR / EN switch"
 echo -e " ${YELLOW}U)${NC} Check Update — compare local vs GitHub"
 echo -e " ${YELLOW}K)${NC} Uninstall Manager — remove script & shortcuts"
 echo -e " ${YELLOW}0)${NC} Exit"
 else
 echo -e "${CYAN}${BOLD} ANA MENÜ${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Ana menü, betiğin giriş noktasıdır."
 echo -e " Üstteki ${CYAN}başlık bölümü${NC} anlık durumu gösterir:"
 echo -e " • Sistem adı, çalışma süresi, WAN IP"
 echo -e " • Servis (çalışıyor / durdu)"
 echo -e " • aria2c sürümü"
 echo -e " • Aktif indirme sayısı ve hızı"
 echo -e " • RPC durumu ve portu"
 echo -e " • AriaNg WebUI durumu"
 echo -e " • RPC Gizli Anahtarı"
 echo -e ""
 echo -e " ${YELLOW}Menü seçenekleri:${NC}"
 echo -e " ${YELLOW}1)${NC} aria2 Yönetimi — servis, ayarlar, kurulum"
 echo -e " ${YELLOW}2)${NC} İndirme Ekle — URL girerek indirme başlat"
 echo -e " ${YELLOW}3)${NC} Mevcut İndirmeler — görev listesi (canlı)"
 echo -e " ${YELLOW}4)${NC} USB Tara — USB algıla, indirme klasörü"
 echo -e " ${YELLOW}5)${NC} Logları İzle — aria2.log son 100 satır"
 echo -e " ${YELLOW}6)${NC} Telegram — bildirim yapılandırması"
 echo -e " ${YELLOW}S)${NC} Sistem Sağlığı — CPU/RAM/disk/ağ"
 echo -e " ${YELLOW}H)${NC} Tanı & Test — tam ortam testi"
 echo -e " ${YELLOW}M)${NC} Yardım — bu kılavuz"
 echo -e " ${YELLOW}L)${NC} Dil — TR / EN geçişi"
 echo -e " ${YELLOW}U)${NC} Güncelleme Kontrolü— yerel vs GitHub karşılaştır"
 echo -e " ${YELLOW}K)${NC} Manager'ı Kaldır — betik ve kısayolları sil"
 echo -e " ${YELLOW}0)${NC} Çıkış"
 fi
 _help_pause
}

help_page_3() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 1 — ARIA2 MANAGEMENT${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " The core control panel for aria2."
 echo -e " Status bar shows: service PID, aria2c version,"
 echo -e " auto-start state, AriaNg WebUI, RPC secret, RPC on/off."
 echo -e ""
 echo -e " ${YELLOW}Options:${NC}"
 echo -e " ${YELLOW}1)${NC} START Service — launches aria2c in background"
 echo -e " ${YELLOW}2)${NC} STOP Service — kills aria2c process"
 echo -e " ${YELLOW}3)${NC} RESTART Service — stop + start"
 echo -e " ${YELLOW}4)${NC} Settings — full config editor (see page 4)"
 echo -e " ${YELLOW}5)${NC} INSTALL aria2c — opkg update + opkg install aria2"
 echo -e " ${YELLOW}6)${NC} Auto Start ON/OFF— creates/removes /opt/etc/init.d/S99aria2"
 echo -e " ${YELLOW}7)${NC} Update aria2c — opkg upgrade aria2"
 echo -e " ${YELLOW}8)${NC} AriaNg WebUI — install/start/stop web interface"
 echo -e " ${YELLOW}9)${NC} Remove aria2 only— uninstall aria2 but keep manager"
 echo -e " ${YELLOW}R)${NC} RPC ON/OFF — toggle enable-rpc + auto restart"
 echo -e " ${YELLOW}0)${NC} Back to Main Menu"
 echo -e ""
 echo -e " ${CYAN}── INFO box:${NC} shows first-run auto-setup notes"
 echo -e " (24-char secret key, USB path, settings location)"
 else
 echo -e "${CYAN}${BOLD} MENÜ 1 — ARIA2 YÖNETİMİ${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " aria2'nin ana kontrol panelidir."
 echo -e " Durum satırı: servis PID, aria2c sürümü, otomatik"
 echo -e " başlatma durumu, AriaNg WebUI, RPC secret, RPC açık/kapalı"
 echo -e ""
 echo -e " ${YELLOW}Seçenekler:${NC}"
 echo -e " ${YELLOW}1)${NC} Servisi BAŞLAT — aria2c'yi arka planda başlatır"
 echo -e " ${YELLOW}2)${NC} Servisi DURDUR — aria2c sürecini sonlandırır"
 echo -e " ${YELLOW}3)${NC} Servisi YENİDEN BAŞLAT — durdur + başlat"
 echo -e " ${YELLOW}4)${NC} Ayarlar — tam yapılandırma editörü (→ sayfa 4)"
 echo -e " ${YELLOW}5)${NC} aria2c KUR (opkg) — opkg update + opkg install aria2"
 echo -e " ${YELLOW}6)${NC} Oto Başlatma AÇ/KAPAT — /opt/etc/init.d/S99aria2 oluşturur/siler"
 echo -e " ${YELLOW}7)${NC} aria2c Güncelle — opkg upgrade aria2"
 echo -e " ${YELLOW}8)${NC} AriaNg Web Arayüzü— web arayüzünü kur/başlat/durdur"
 echo -e " ${YELLOW}9)${NC} Sadece aria2'yi Kaldır — manager kalır, aria2 silinir"
 echo -e " ${YELLOW}R)${NC} RPC Aç/Kapat — enable-rpc değiştirir, otomatik restart"
 echo -e " ${YELLOW}0)${NC} Ana Menüye Dön"
 echo -e ""
 echo -e " ${CYAN}── HAKKINDA kutusu:${NC} ilk kurulum notları"
 echo -e " (24 haneli key, USB yolu, ayar konumu)"
 fi
 _help_pause
}

help_page_4() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 1 → SETTINGS (option 4)${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " All settings are stored in: ${CYAN}$ARIA2_CONF${NC}"
 echo -e " Changes take effect after service restart."
 echo -e ""
 echo -e " ${YELLOW}Settings overview (top panel):${NC}"
 echo -e " Download Dir — where files are saved"
 echo -e " Max concurrent — simultaneous downloads"
 echo -e " Max connections — connections per server"
 echo -e " Split count — segments per file"
 echo -e " ⬇ DL speed limit — 0 = unlimited (e.g. 5M)"
 echo -e " ⬆ UL speed limit — 0 = unlimited"
 echo -e " RPC — ON/OFF + port display"
 echo -e " RPC Secret — CONFIGURED / [EMPTY]"
 echo -e " File allocation — none / prealloc / falloc / trunc"
 echo -e " Log level — debug / info / notice / warn / error"
 echo -e ""
 echo -e " ${YELLOW}Sub-options:${NC}"
 echo -e " ${YELLOW}1)${NC} Change download dir (USB picker or manual path)"
 echo -e " ${YELLOW}2)${NC} Connection settings (concurrent, split, min-split)"
 echo -e " ${YELLOW}3)${NC} Speed limits (download + upload)"
 echo -e " ${YELLOW}4)${NC} RPC settings — port, secret, listen-all, origin"
 echo -e " • Leave secret blank → auto-generate 24-char key"
 echo -e " • Type 'clear' → remove secret (no auth)"
 echo -e " ${YELLOW}R)${NC} RPC ON/OFF — quick toggle without entering sub-menu"
 echo -e " ${YELLOW}5)${NC} File allocation method"
 echo -e " ${YELLOW}6)${NC} Log level"
 echo -e " ${YELLOW}7)${NC} Show full config file"
 echo -e " ${YELLOW}8)${NC} Reset config to defaults"
 else
 echo -e "${CYAN}${BOLD} MENÜ 1 → AYARLAR (seçenek 4)${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Tüm ayarlar şu dosyada saklanır: ${CYAN}$ARIA2_CONF${NC}"
 echo -e " Değişiklikler servis yeniden başlatıldıktan sonra geçerli olur."
 echo -e ""
 echo -e " ${YELLOW}Ayar paneli özeti (üst bölüm):${NC}"
 echo -e " İndirme Klasörü — dosyaların kaydedileceği yer"
 echo -e " Maksimum eş zamanlı indirme sayısı"
 echo -e " Sunucu başına maksimum bağlantı sayısı"
 echo -e " Dosya bölüm sayısı (split)"
 echo -e " ⬇ İndirme hız limiti — 0 = sınırsız (örn. 5M)"
 echo -e " ⬆ Yükleme hız limiti — 0 = sınırsız"
 echo -e " RPC — AÇIK/KAPALI + port gösterimi"
 echo -e " RPC Secret — AYARLI / [BOŞ]"
 echo -e " Dosya ayırma — none / prealloc / falloc / trunc"
 echo -e " Log seviyesi — debug / info / notice / warn / error"
 echo -e ""
 echo -e " ${YELLOW}Alt seçenekler:${NC}"
 echo -e " ${YELLOW}1)${NC} İndirme klasörü değiştir (USB seçici veya manuel)"
 echo -e " ${YELLOW}2)${NC} Bağlantı ayarları (eş zamanlı, split, min-split)"
 echo -e " ${YELLOW}3)${NC} Hız limitleri (indirme + yükleme)"
 echo -e " ${YELLOW}4)${NC} RPC ayarları — port, secret, listen-all, origin"
 echo -e " • Secret boş bırak → otomatik 24 haneli key üretilir"
 echo -e " • 'sil' yaz → secret kaldırılır (kimlik doğrulama yok)"
 echo -e " ${YELLOW}R)${NC} RPC Aç/Kapat — alt menüye girmeden hızlı geçiş"
 echo -e " ${YELLOW}5)${NC} Dosya ayırma yöntemi"
 echo -e " ${YELLOW}6)${NC} Log seviyesi"
 echo -e " ${YELLOW}7)${NC} Tüm config dosyasını göster"
 echo -e " ${YELLOW}8)${NC} Config'i varsayılanlara sıfırla"
 fi
 _help_pause
}

help_page_5() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 2 — ADD DOWNLOAD${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Adds a download task directly via RPC."
 echo -e " aria2 service must be ${GREEN}running${NC} and RPC must be ${GREEN}ON${NC}."
 echo -e ""
 echo -e " ${YELLOW}Supported URL types:${NC}"
 echo -e " • HTTP / HTTPS — direct file links"
 echo -e " • FTP / SFTP — file transfer links"
 echo -e " • Magnet links — BitTorrent magnet URIs"
 echo -e " • .torrent files— paste the full path or URL"
 echo -e ""
 echo -e " ${YELLOW}How to use:${NC}"
 echo -e " 1. Select option 2 from the main menu"
 echo -e " 2. Paste or type the download URL"
 echo -e " 3. Optionally enter a custom save directory"
 echo -e " (leave blank to use the default download folder)"
 echo -e " 4. The task is queued — aria2 starts downloading"
 echo -e ""
 echo -e " ${YELLOW}Tip:${NC} Check Menu 3 to monitor progress."
 echo -e " ${YELLOW}Tip:${NC} AriaNg WebUI allows drag-and-drop .torrent files."
 else
 echo -e "${CYAN}${BOLD} MENÜ 2 — İNDİRME EKLE${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " RPC üzerinden doğrudan indirme görevi ekler."
 echo -e " aria2 servisi ${GREEN}çalışıyor${NC} ve RPC ${GREEN}AÇIK${NC} olmalıdır."
 echo -e ""
 echo -e " ${YELLOW}Desteklenen URL türleri:${NC}"
 echo -e " • HTTP / HTTPS — doğrudan dosya bağlantıları"
 echo -e " • FTP / SFTP — dosya transfer bağlantıları"
 echo -e " • Magnet link — BitTorrent magnet URI'leri"
 echo -e " • .torrent — tam yol veya URL yapıştırın"
 echo -e ""
 echo -e " ${YELLOW}Nasıl kullanılır:${NC}"
 echo -e " 1. Ana menüden 2 seçin"
 echo -e " 2. İndirme URL'sini yapıştırın veya yazın"
 echo -e " 3. İsteğe bağlı özel kayıt klasörü girin"
 echo -e " (boş bırakırsanız varsayılan klasör kullanılır)"
 echo -e " 4. Görev sıraya alınır — aria2 indirmeye başlar"
 echo -e ""
 echo -e " ${YELLOW}İpucu:${NC} İlerlemeyi izlemek için Menü 3'ü açın."
 echo -e " ${YELLOW}İpucu:${NC} AriaNg WebUI ile .torrent dosyası sürükle-bırak yapabilirsiniz."
 fi
 _help_pause
}

help_page_6() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 3 — ACTIVE DOWNLOADS${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Shows a live snapshot of all download tasks."
 echo -e " Fetched via RPC — service must be running."
 echo -e ""
 echo -e " ${YELLOW}Sections shown:${NC}"
 echo -e " • ${GREEN}ACTIVE${NC} — tasks currently downloading"
 echo -e " Shows: GID, filename, size, progress %, speed"
 echo -e " • ${YELLOW}WAITING${NC} — tasks queued but not yet started"
 echo -e " Shows: GID, filename, size"
 echo -e " • ${CYAN}COMPLETED${NC} — recently finished tasks"
 echo -e " Shows: GID, filename, total size"
 echo -e ""
 echo -e " ${YELLOW}GID:${NC} Globally unique ID assigned by aria2 to each task."
 echo -e " Use GID in AriaNg WebUI for detailed task management."
 echo -e ""
 echo -e " ${YELLOW}Tip:${NC} For pause/resume/delete, use AriaNg WebUI (Menu 1 → 8)"
 echo -e " or connect via external aria2 RPC client."
 else
 echo -e "${CYAN}${BOLD} MENÜ 3 — MEVCUT İNDİRMELER${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Tüm indirme görevlerinin anlık görüntüsünü gösterir."
 echo -e " RPC üzerinden çekilir — servis çalışıyor olmalıdır."
 echo -e ""
 echo -e " ${YELLOW}Gösterilen bölümler:${NC}"
 echo -e " • ${GREEN}AKTİF${NC} — şu an indirilen görevler"
 echo -e " Gösterir: GID, dosya adı, boyut, % ilerleme, hız"
 echo -e " • ${YELLOW}BEKLİYOR${NC} — sıraya alınmış, henüz başlamamış"
 echo -e " Gösterir: GID, dosya adı, boyut"
 echo -e " • ${CYAN}TAMAMLANDI${NC} — yakın zamanda biten görevler"
 echo -e " Gösterir: GID, dosya adı, toplam boyut"
 echo -e ""
 echo -e " ${YELLOW}GID:${NC} aria2'nin her göreve atadığı benzersiz kimlik."
 echo -e " AriaNg WebUI'de GID ile görev yönetimi yapılabilir."
 echo -e ""
 echo -e " ${YELLOW}İpucu:${NC} Duraklat/devam et/sil için AriaNg WebUI (Menü 1 → 8)"
 echo -e " ya da harici bir aria2 RPC istemcisi kullanın."
 fi
 _help_pause
}

help_page_7() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 4 — USB SCAN & DOWNLOAD DIR${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Scans connected USB drives and lets you pick one"
 echo -e " as the download destination."
 echo -e ""
 echo -e " ${YELLOW}How it works:${NC}"
 echo -e " 1. Detects all mounted USB drives under /tmp/mnt/"
 echo -e " 2. Shows each drive with free space"
 echo -e " 3. You select a drive by number"
 echo -e " 4. Default folder: USB_PATH/aria2/downloads"
 echo -e " 5. You can customize the subfolder name"
 echo -e " 6. Folder is created automatically if it doesn't exist"
 echo -e " 7. Config (dir=) is updated and service restarted"
 echo -e ""
 echo -e " ${YELLOW}Same function in:${NC} Menu 1 → Settings → option 1"
 echo -e ""
 echo -e " ${YELLOW}Tip:${NC} If USB is not listed, check it is mounted:"
 echo -e " ls /tmp/mnt/"
 echo -e " ${YELLOW}Tip:${NC} FAT32 drives → use 'prealloc' file allocation."
 echo -e " ${YELLOW}Tip:${NC} ext4 drives → use 'falloc' for best performance."
 else
 echo -e "${CYAN}${BOLD} MENÜ 4 — USB TARA VE İNDİRME KLASÖRÜ${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Bağlı USB diskleri tarar ve indirme hedefi olarak"
 echo -e " birini seçmenizi sağlar."
 echo -e ""
 echo -e " ${YELLOW}Nasıl çalışır:${NC}"
 echo -e " 1. /tmp/mnt/ altındaki tüm USB diskleri algılar"
 echo -e " 2. Her diski boş alanıyla birlikte listeler"
 echo -e " 3. Numarayla bir disk seçersiniz"
 echo -e " 4. Varsayılan klasör: USB_YOLU/aria2/downloads"
 echo -e " 5. Alt klasör adını özelleştirebilirsiniz"
 echo -e " 6. Klasör yoksa otomatik oluşturulur"
 echo -e " 7. Config (dir=) güncellenir, servis yeniden başlar"
 echo -e ""
 echo -e " ${YELLOW}Aynı işlev şurada da var:${NC} Menü 1 → Ayarlar → seçenek 1"
 echo -e ""
 echo -e " ${YELLOW}İpucu:${NC} USB listede görünmüyorsa mount edildiğini kontrol edin:"
 echo -e " ls /tmp/mnt/"
 echo -e " ${YELLOW}İpucu:${NC} FAT32 disk → 'prealloc' dosya ayırma yöntemi kullanın."
 echo -e " ${YELLOW}İpucu:${NC} ext4 disk → en iyi performans için 'falloc' kullanın."
 fi
 _help_pause
}

help_page_8() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} MENU 6 — TELEGRAM NOTIFICATIONS${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " Sends Telegram messages on download events."
 echo -e " Requires a Telegram Bot Token and Chat ID."
 echo -e ""
 echo -e " ${YELLOW}How to get credentials:${NC}"
 echo -e " 1. Open Telegram → search @BotFather"
 echo -e " 2. Send /newbot → get your Bot Token"
 echo -e " 3. Start a chat with your bot"
 echo -e " 4. Visit: api.telegram.org/bot<TOKEN>/getUpdates"
 echo -e " 5. Find 'chat' → 'id' in the JSON response"
 echo -e ""
 echo -e " ${YELLOW}Notification events:${NC}"
 echo -e " • Download started"
 echo -e " • Download completed"
 echo -e " • Download error"
 echo -e " • Download added (via Menu 2)"
 echo -e ""
 echo -e " ${YELLOW}Settings stored in:${NC} $TG_CONF"
 echo -e " ${YELLOW}Toggle per event:${NC} Menu 6 → notification settings"
 echo -e " ${YELLOW}Test button:${NC} Menu 6 → send test message"
 else
 echo -e "${CYAN}${BOLD} MENÜ 6 — TELEGRAM BİLDİRİMLERİ${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " İndirme olaylarında Telegram mesajı gönderir."
 echo -e " Telegram Bot Token ve Chat ID gerektirir."
 echo -e ""
 echo -e " ${YELLOW}Nasıl alınır:${NC}"
 echo -e " 1. Telegram'ı aç → @BotFather'ı ara"
 echo -e " 2. /newbot gönder → Bot Token al"
 echo -e " 3. Botunuzla sohbet başlatın"
 echo -e " 4. Şu adrese gidin: api.telegram.org/bot<TOKEN>/getUpdates"
 echo -e " 5. JSON yanıtında 'chat' → 'id' değerini bulun"
 echo -e ""
 echo -e " ${YELLOW}Bildirim olayları:${NC}"
 echo -e " • İndirme başladı"
 echo -e " • İndirme tamamlandı"
 echo -e " • İndirme hatası"
 echo -e " • İndirme eklendi (Menü 2 üzerinden)"
 echo -e ""
 echo -e " ${YELLOW}Ayarlar şurada:${NC} $TG_CONF"
 echo -e " ${YELLOW}Olay bazlı açma/kapama:${NC} Menü 6 → bildirim ayarları"
 echo -e " ${YELLOW}Test:${NC} Menü 6 → test mesajı gönder"
 fi
 _help_pause
}

help_page_9() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} S) SYSTEM HEALTH / H) DIAGNOSTICS${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}S) System Health${NC} — live system resources:"
 echo -e " • CPU load (1 / 5 / 15 min averages)"
 echo -e " • RAM usage (used / free / total)"
 echo -e " • Storage per mount point (USB + internal)"
 echo -e " • Network interfaces and IP addresses"
 echo -e " • aria2 RPC stat: active / waiting downloads"
 echo -e ""
 echo -e " ${YELLOW}H) Diagnostics & Test${NC} — full environment check:"
 echo -e " Checks every requirement and optional component:"
 echo -e " • aria2c binary — installed / version"
 echo -e " • curl, wget — needed for RPC / Telegram / updates"
 echo -e " • opkg — package manager available"
 echo -e " • RPC — ping test with auth token"
 echo -e " • AriaNg WebUI — installed / running"
 echo -e " • Telegram — token configured"
 echo -e " • Entware — /opt environment"
 echo -e " • Script version vs GitHub (update check)"
 echo -e " • Functional test: aria2.getGlobalStat via RPC"
 echo -e ""
 echo -e " ${CYAN}Both menus${NC} are read-only — they do not change any config."
 else
 echo -e "${CYAN}${BOLD} S) SİSTEM SAĞLIĞI / H) TANI & TEST${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}S) Sistem Sağlığı${NC} — anlık sistem kaynakları:"
 echo -e " • CPU yükü (1 / 5 / 15 dakika ortalamaları)"
 echo -e " • RAM kullanımı (kullanılan / boş / toplam)"
 echo -e " • Mount noktası başına depolama (USB + dahili)"
 echo -e " • Ağ arayüzleri ve IP adresleri"
 echo -e " • aria2 RPC istatistikleri: aktif / bekleyen indirmeler"
 echo -e ""
 echo -e " ${YELLOW}H) Tanı & Test${NC} — tam ortam kontrolü:"
 echo -e " Her gereksinim ve opsiyonel bileşen kontrol edilir:"
 echo -e " • aria2c ikili dosyası — kurulu / sürüm"
 echo -e " • curl, wget — RPC / Telegram / güncellemeler için"
 echo -e " • opkg — paket yöneticisi mevcut mu"
 echo -e " • RPC — auth token ile ping testi"
 echo -e " • AriaNg WebUI — kurulu / çalışıyor"
 echo -e " • Telegram — token yapılandırılmış mı"
 echo -e " • Entware — /opt ortamı"
 echo -e " • Betik sürümü vs GitHub (güncelleme kontrolü)"
 echo -e " • Fonksiyonel test: aria2.getGlobalStat RPC çağrısı"
 echo -e ""
 echo -e " ${CYAN}Her iki menü de${NC} salt okunurdur — hiçbir ayarı değiştirmez."
 fi
 _help_pause
}

help_page_A() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} RPC — WHAT IS IT & HOW TO USE${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}What is RPC?${NC}"
 echo -e " RPC (Remote Procedure Call) is aria2's built-in API."
 echo -e " It allows external apps (AriaNg, scripts, apps)"
 echo -e " to control aria2 over HTTP or WebSocket."
 echo -e ""
 echo -e " ${YELLOW}Key settings (in $ARIA2_CONF):${NC}"
 echo -e " enable-rpc=true — turns RPC on"
 echo -e " rpc-listen-port=6800 — default port"
 echo -e " rpc-listen-all=true — accept from all IPs (not just localhost)"
 echo -e " rpc-allow-origin-all=true — allow AriaNg browser access"
 echo -e " rpc-secret=YOUR_KEY — authentication token"
 echo -e ""
 echo -e " ${YELLOW}Secret key:${NC}"
 echo -e " All RPC requests must include the token."
 echo -e " Without it, aria2 rejects the connection."
 echo -e " Set/change: Menu 1 → Settings → option 4"
 echo -e " Quick toggle: Menu 1 → R) or Menu 1 → 4 → R)"
 echo -e ""
 echo -e " ${YELLOW}Testing RPC manually:${NC}"
 echo -e " curl http://localhost:6800/jsonrpc \\"
 echo -e " -d '{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getVersion\","
 echo -e " \"id\":1,\"params\":[\"token:YOUR_KEY\"]}'"
 else
 echo -e "${CYAN}${BOLD} RPC — NEDİR, NASIL KULLANILIR?${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}RPC nedir?${NC}"
 echo -e " RPC (Uzak Prosedür Çağrısı) aria2'nin dahili API'sidir."
 echo -e " Harici uygulamaların (AriaNg, betikler, uygulamalar)"
 echo -e " aria2'yi HTTP veya WebSocket üzerinden kontrol etmesini sağlar."
 echo -e ""
 echo -e " ${YELLOW}Temel ayarlar ($ARIA2_CONF içinde):${NC}"
 echo -e " enable-rpc=true — RPC'yi açar"
 echo -e " rpc-listen-port=6800 — varsayılan port"
 echo -e " rpc-listen-all=true — tüm IP'lerden kabul et (sadece localhost değil)"
 echo -e " rpc-allow-origin-all=true — AriaNg tarayıcı erişimine izin ver"
 echo -e " rpc-secret=ANAHTAR — kimlik doğrulama tokeni"
 echo -e ""
 echo -e " ${YELLOW}Secret key:${NC}"
 echo -e " Tüm RPC istekleri tokeni içermek zorundadır."
 echo -e " Olmadan aria2 bağlantıyı reddeder."
 echo -e " Ayarla/değiştir: Menü 1 → Ayarlar → seçenek 4"
 echo -e " Hızlı geçiş: Menü 1 → R) veya Menü 1 → 4 → R)"
 echo -e ""
 echo -e " ${YELLOW}RPC'yi elle test etmek:${NC}"
 echo -e " curl http://localhost:6800/jsonrpc \\"
 echo -e " -d '{\"jsonrpc\":\"2.0\",\"method\":\"aria2.getVersion\","
 echo -e " \"id\":1,\"params\":[\"token:ANAHTARINIZ\"]}'"
 fi
 _help_pause
}

help_page_B() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} ARIANG WEBUI${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " AriaNg is a web-based GUI for aria2."
 echo -e " It runs as a local web server on the router."
 echo -e " Access it from any browser on your network."
 echo -e ""
 echo -e " ${YELLOW}Install / manage:${NC} Menu 1 → option 8 (AriaNg WebUI)"
 echo -e " ${YELLOW}Default port:${NC} 6880 (configurable)"
 echo -e " ${YELLOW}Access URL:${NC} http://ROUTER_IP:6880"
 echo -e ""
 echo -e " ${YELLOW}First-time AriaNg setup:${NC}"
 echo -e " 1. Open http://ROUTER_IP:6880 in your browser"
 echo -e " 2. Go to AriaNg Settings → RPC"
 echo -e " 3. Set RPC Host: ROUTER_IP"
 echo -e " 4. Set RPC Port: 6800"
 echo -e " 5. Set Secret Token: (your rpc-secret value)"
 echo -e " 6. Save — AriaNg connects to aria2"
 echo -e ""
 echo -e " ${YELLOW}What you can do in AriaNg:${NC}"
 echo -e " • Add URLs / .torrent / .metalink files"
 echo -e " • Pause, resume, delete tasks"
 echo -e " • View detailed file progress & peers"
 echo -e " • Set per-task speed limits"
 echo -e " • Manage all aria2 global settings"
 else
 echo -e "${CYAN}${BOLD} ARIANG WEB ARAYÜZÜ${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " AriaNg, aria2 için web tabanlı bir arayüzdür."
 echo -e " Router üzerinde yerel bir web sunucusu olarak çalışır."
 echo -e " Ağınızdaki herhangi bir tarayıcıdan erişilebilir."
 echo -e ""
 echo -e " ${YELLOW}Kur / yönet:${NC} Menü 1 → seçenek 8 (AriaNg Web Arayüzü)"
 echo -e " ${YELLOW}Varsayılan port:${NC} 6880 (değiştirilebilir)"
 echo -e " ${YELLOW}Erişim URL'si:${NC} http://ROUTER_IP:6880"
 echo -e ""
 echo -e " ${YELLOW}AriaNg ilk kurulum:${NC}"
 echo -e " 1. Tarayıcıda http://ROUTER_IP:6880 adresini açın"
 echo -e " 2. AriaNg Ayarları → RPC bölümüne gidin"
 echo -e " 3. RPC Host: ROUTER_IP girin"
 echo -e " 4. RPC Port: 6800 girin"
 echo -e " 5. Secret Token: (rpc-secret değeriniz)"
 echo -e " 6. Kaydedin — AriaNg aria2'ye bağlanır"
 echo -e ""
 echo -e " ${YELLOW}AriaNg'de yapabilecekleriniz:${NC}"
 echo -e " • URL / .torrent / .metalink dosyası ekle"
 echo -e " • Görevleri duraklat, devam ettir, sil"
 echo -e " • Detaylı dosya ilerlemesi ve peer bilgisi"
 echo -e " • Görev bazlı hız limiti ayarla"
 echo -e " • Tüm aria2 global ayarlarını yönet"
 fi
 _help_pause
}

help_page_C() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} FIRST INSTALL — AUTO SETUP${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " When you install aria2c for the first time (Menu 1 → 5),"
 echo -e " the script runs an automatic post-install setup:"
 echo -e ""
 echo -e " ${YELLOW}What auto-setup does:${NC}"
 echo -e " 1. Creates config file: $ARIA2_CONF"
 echo -e " 2. Generates a random ${CYAN}24-character RPC secret key${NC}"
 echo -e " (alphanumeric, stored in rpc-secret=)"
 echo -e " 3. Scans for connected USB drives"
 echo -e " → If found: sets download dir to USB/aria2/downloads"
 echo -e " → If not: sets download dir to /tmp/mnt/USB"
 echo -e " 4. Creates the download folder if it doesn't exist"
 echo -e " 5. Sets sane defaults for all other options"
 echo -e ""
 echo -e " ${YELLOW}After auto-setup you can:${NC}"
 echo -e " • Change the secret key: Menu 1 → 4 → option 4"
 echo -e " • Change download folder: Menu 1 → 4 → option 1"
 echo -e " • Toggle RPC on/off: Menu 1 → R)"
 echo -e " • View full config: Menu 1 → 4 → option 7"
 else
 echo -e "${CYAN}${BOLD} İLK KURULUM — OTOMATİK YAPILANDIRMA${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " aria2c'yi ilk kez kurduğunuzda (Menü 1 → 5),"
 echo -e " betik otomatik kurulum sonrası yapılandırma çalıştırır:"
 echo -e ""
 echo -e " ${YELLOW}Otomatik kurulum ne yapar:${NC}"
 echo -e " 1. Config dosyası oluşturur: $ARIA2_CONF"
 echo -e " 2. Rastgele ${CYAN}24 haneli RPC secret key${NC} üretir"
 echo -e " (alfanümerik, rpc-secret= olarak kaydedilir)"
 echo -e " 3. Bağlı USB diskleri tarar"
 echo -e " → Bulunursa: indirme klasörü USB/aria2/downloads yapılır"
 echo -e " → Bulunamazsa: /tmp/mnt/USB olarak bırakılır"
 echo -e " 4. İndirme klasörü yoksa otomatik oluşturulur"
 echo -e " 5. Tüm diğer seçenekler için sağlıklı varsayılanlar atanır"
 echo -e ""
 echo -e " ${YELLOW}Otomatik kurulum sonrası:${NC}"
 echo -e " • Secret key değiştir: Menü 1 → 4 → seçenek 4"
 echo -e " • İndirme klasörü değiştir: Menü 1 → 4 → seçenek 1"
 echo -e " • RPC aç/kapat: Menü 1 → R)"
 echo -e " • Tam config'i görüntüle: Menü 1 → 4 → seçenek 7"
 fi
 _help_pause
}

help_page_D() {
 clear
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN}${BOLD} FAQ — COMMON QUESTIONS${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}Q: RPC shows 'NO RESPONSE' in the header.${NC}"
 echo -e " A: Service may be stopped. Check Menu 1 → 1 to start it."
 echo -e " Also verify RPC is ON (Menu 1 → R) shows ON)."
 echo -e " If secret is set, old clients without the key will fail."
 echo -e ""
 echo -e " ${YELLOW}Q: Downloads don't start / tasks not added.${NC}"
 echo -e " A: Ensure aria2 is running (Menu 1 → status: RUNNING)."
 echo -e " Ensure RPC is enabled (Menu 1 → R) shows ON)."
 echo -e " Check logs (Main menu → 5) for error details."
 echo -e ""
 echo -e " ${YELLOW}Q: USB not detected in Menu 4.${NC}"
 echo -e " A: Run 'ls /tmp/mnt/' in terminal to verify it's mounted."
 echo -e " Ensure USB is plugged in and recognized by the router."
 echo -e ""
 echo -e " ${YELLOW}Q: How do I update the script itself?${NC}"
 echo -e " A: Main menu → U) Check Update → confirm download."
 echo -e ""
 echo -e " ${YELLOW}Q: How to run the script from anywhere?${NC}"
 echo -e " A: After first run, shortcuts are created:"
 echo -e " aria2m / a2m / k2m / kam / aria2manager"
 echo -e ""
 echo -e " ${YELLOW}Q: How does the Telegram menu work?${NC}"
 echo -e " A: Menu 6 → Telegram Notifications:"
 echo -e " 1) Telegram ACTIVE/INACTIVE: Enable/Disable the service"
 echo -e " 2) Bot Token & Chat ID: Enter both Token and Chat ID together"
 echo -e " 3) Notification Settings: Choose which events to be notified"
 echo -e " 4) Test Message: Test if your settings work correctly"
 echo -e " 5) Install Curl: Manually install curl if missing"
 echo -e " After entering both Token and Chat ID, the service starts automatically."
 echo -e ""
 echo -e " ${YELLOW}Q: How do I configure all aria2 settings at once?${NC}"
 echo -e " A: Menu 1 → Settings (option 4) → C) Full Config Wizard"
 echo -e " The wizard walks through all 51 aria2 options in 8 categories:"
 echo -e " File/Directory, Connection/Speed, Timeout/Retry, HTTP/FTP,"
 echo -e " RPC, BitTorrent, Security, and Log settings."
 echo -e " Press K at any time to save and exit, Q to quit without saving."
 echo -e ""
 echo -e " ${YELLOW}Q: How does the Backup & Restore menu work?${NC}"
 echo -e " A: Main menu → B) Backup & Restore:"
 echo -e " 1) Basic Backup: backs up aria2.conf, telegram.conf and language preference."
 echo -e " 2) Full Backup: backs up everything — config, session, autostart, all Telegram"
 echo -e " hooks and AriaNg port. Restores the system exactly as it was."
 echo -e " 3) Restore: lists all backups with name, type, date and size."
 echo -e " Select a number, confirm, and the system is restored automatically."
 echo -e " Backups are saved to: /opt/etc/aria2/backups/"
 echo -e " File format: aria2manager_backup_YYYYMMDD_HHMM_basic/full.tar.gz"
 echo -e ""
 echo -e " ${YELLOW}Q: How to remove everything cleanly?${NC}"
 echo -e " A: Main menu → K) Uninstall Manager (removes script + shortcuts)"
 echo -e " Menu 1 → 9 (removes aria2 only, keeps manager)"
 else
 echo -e "${CYAN}${BOLD} SSS — SIK SORULAN SORULAR${NC}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 echo -e ""
 echo -e " ${YELLOW}S: Başlıkta RPC 'YANIT YOK' yazıyor.${NC}"
 echo -e " C: Servis durmuş olabilir. Menü 1 → 1 ile başlatın."
 echo -e " RPC'nin açık olduğunu kontrol edin (Menü 1 → R) AÇIK görünmeli)."
 echo -e " Secret ayarlıysa, tokensiz eski istemciler reddedilir."
 echo -e ""
 echo -e " ${YELLOW}S: İndirmeler başlamıyor / görev eklenemiyor.${NC}"
 echo -e " C: aria2'nin çalıştığından emin olun (Menü 1 → ÇALIŞIYOR)."
 echo -e " RPC'nin açık olduğunu doğrulayın (Menü 1 → R) AÇIK)."
 echo -e " Loglara bakın (Ana menü → 5) hata detayları için."
 echo -e ""
 echo -e " ${YELLOW}S: USB Menü 4'te görünmüyor.${NC}"
 echo -e " C: Terminalde 'ls /tmp/mnt/' çalıştırarak mount edildiğini doğrulayın."
 echo -e " USB'nin takılı ve router tarafından tanındığından emin olun."
 echo -e ""
 echo -e " ${YELLOW}S: Betiği nasıl güncellerim?${NC}"
 echo -e " C: Ana menü → U) Güncelleme Kontrolü → indir ve onayla."
 echo -e ""
 echo -e " ${YELLOW}S: Betiği her yerden nasıl çalıştırırım?${NC}"
 echo -e " C: İlk çalıştırmada kısayollar oluşturulur:"
 echo -e " aria2m / a2m / k2m / kam / aria2manager"
 echo -e ""
 echo -e " ${YELLOW}S: Telegram menüsü nasıl çalışır?${NC}"
 echo -e " C: Menü 6 → Telegram Bildirimleri:"
 echo -e " 1) Telegram AKTİF/PASİF: Hizmeti aç/kapat"
 echo -e " 2) Bot Token & Chat ID: Token ve Chat ID'yi birlikte girin"
 echo -e " 3) Bildirim Ayarları: Hangi olaylar için bildirim almak istiyorsanız seçin"
 echo -e " 4) Test Mesajı: Ayarların çalışıp çalışmadığını test edin"
 echo -e " 5) Curl Yükle: curl eksikse manuel olarak yükleyin"
 echo -e " Token ve Chat ID'yi birlikte girdikten sonra, hizmet otomatik başlatılır."
 echo -e ""
 echo -e " ${YELLOW}S: Tüm aria2 ayarlarını tek seferde nasıl yapılandırırım?${NC}"
 echo -e " C: Menü 1 → Ayarlar (seçenek 4) → C) Tam Config Sihirbazı"
 echo -e " Sihirbaz, 8 kategoride 51 aria2 seçeneğini tek tek sorar:"
 echo -e " Dosya/Dizin, Bağlantı/Hız, Zaman Aşımı/Yeniden Deneme, HTTP/FTP,"
 echo -e " RPC, BitTorrent, Güvenlik ve Log ayarları."
 echo -e " İstediğiniz zaman K ile kaydet ve çık, Q ile kaydetmeden çık."
 echo -e ""
 echo -e " ${YELLOW}S: Yedek & Geri Yükleme menüsü nasıl çalışır?${NC}"
 echo -e " C: Ana menü → B) Yedek & Geri Yükleme:"
 echo -e " 1) Temel Yedek: aria2.conf, telegram.conf ve dil tercihini yedekler."
 echo -e " 2) Tam Yedek: her şeyi yedekler — config, session, otomatik başlatma,"
 echo -e " tüm Telegram hookları ve AriaNg port ayarı. Sistemi eksiksiz geri getirir."
 echo -e " 3) Geri Yükle: tüm yedekleri isim, tür, tarih ve boyutuyla listeler."
 echo -e " Numara seçip onaylayın, sistem otomatik olarak eski haline döner."
 echo -e " Yedekler şu konuma kaydedilir: /opt/etc/aria2/backups/"
 echo -e " Dosya formatı: aria2manager_backup_YYYYAAGG_SSDD_basic/full.tar.gz"
 echo -e ""
 echo -e " ${YELLOW}S: Her şeyi temizce nasıl kaldırırım?${NC}"
 echo -e " C: Ana menü → K) Manager'ı Kaldır (betik + kısayollar silinir)"
 echo -e " Menü 1 → 9 (sadece aria2 kaldırılır, manager kalır)"
 fi
 _help_pause
}

# ============================================
# ANA MENÜ / MAIN MENU
# ============================================
create_shortcuts

if [ -f "$LOCK_FILE" ]; then
 LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null)
 echo -e "${YELLOW} ${L_LOCK_MSG}${NC}"
 if [ -n "$LOCK_PID" ]; then
 if kill -0 "$LOCK_PID" 2>/dev/null; then
 echo -e " ${CYAN}${L_LOCK_PID} ${YELLOW}${LOCK_PID}${NC}"
 else
 echo -e " ${CYAN}${L_LOCK_PID} ${YELLOW}${LOCK_PID}${NC} ${RED}${L_LOCK_PID_DEAD}${NC}"
 fi
 fi
 printf "${L_LOCK_Q}"; read answer
 if [ "$answer" = "$L_CONFIRM_YES" ] || [ "$answer" = "$L_CONFIRM_YES2" ] || [ -z "$answer" ]; then
 rm -f "$LOCK_FILE"; echo -e "${GREEN} ${L_LOCK_CLEARED}${NC}"
 else
 echo -e "${RED} ${L_LOCK_EXIT}${NC}"; exit 1
 fi
fi

# Mevcut PID'i lock dosyasına yaz
echo "$$" > "$LOCK_FILE"
# Ctrl+C (INT), kapanma (TERM/HUP) → sadece lock sil, aria2'ye dokunma
trap 'rm -f "$LOCK_FILE"; echo ""; exit 0' INT TERM HUP
trap 'rm -f "$LOCK_FILE"' EXIT

while true; do
 print_header
 echo -e "${CYAN}${BOLD} ${L_MAIN_MENU}${NC}"
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 echo -e " ${YELLOW}1)${NC} ${CYAN}${L_ARIA2_MGMT}${NC} ${YELLOW}${L_ARIA2_MGMT_SUB}${NC}"
 echo -e " ${YELLOW}2)${NC} ${GREEN}${L_ADD_DL}${NC} ${YELLOW}${L_ADD_DL_SUB}${NC}"
 echo -e " ${YELLOW}3)${NC} ${CYAN}${L_DOWNLOADS}${NC}"
 echo -e " ${YELLOW}4)${NC} ${L_SCAN_USB}"
 echo -e " ${YELLOW}5)${NC} ${CYAN}${L_VIEW_LOGS}${NC}"
 echo -e " ${YELLOW}6)${NC} ${CYAN}${L_TG_MENU}${NC}"
 echo -e " ${YELLOW}S)${NC} ${CYAN}${L_HEALTH_MENU}${NC}"
 echo -e " ${YELLOW}H)${NC} ${CYAN}${L_DIAG_MENU}${NC}"
 echo -e " ${YELLOW}M)${NC} ${CYAN}${L_HELP_MENU}${NC}"
 echo -e " ${YELLOW}B)${NC} ${GREEN}$(if [ "$LANG_SEL" = "en" ]; then echo "Backup & Restore"; elif [ "$LANG_SEL" = "ru" ]; then echo "Резервная копия и восстановление"; else echo "Yedek & Geri Yükleme"; fi)${NC}"
 echo -e " ${YELLOW}L)${NC} ${MAGENTA}${L_LANG_MENU}${NC}"
 echo -e " ${YELLOW}U)${NC} ${MAGENTA}${L_CHECK_UPDATE}${NC}"
 echo -e " ${YELLOW}K)${NC} ${RED}${BOLD}${L_UNINSTALL_MGR}${NC}"
 echo -e " ${YELLOW}0)${NC} ${L_EXIT}"
 echo -e "${DIM_CYAN}════════════════════════════════════════════════════${NC}"
 printf "${GREEN}${L_YOUR_CHOICE} [0-6, S, H, M, B, L, U, K]: ${NC}"; read choice
 case "$choice" in
 1) aria2_management_menu ;;
 2) add_download ;;
 3) list_downloads ;;
 4) scan_usb_menu ;;
 5)
 clear
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN} ARIA2 LOG - Press ${BOLD}q${NC}${CYAN} to exit${NC}"
 else
 echo -e "${CYAN} ARIA2 LOG - Çıkmak için ${BOLD}q${NC}${CYAN} tuşuna basın${NC}"
 fi
 echo -e "${DIM_CYAN}────────────────────────────────────────────────────${NC}"
 if [ -f "$ARIA2_LOG" ]; then tail -100 "$ARIA2_LOG" | less
 else echo -e "${RED} ${L_CONF_NOT_FOUND} $ARIA2_LOG${NC}"; sleep 3; fi
 ;;
 6) telegram_menu ;;
 s|S) health_menu ;;
 h|H) diag_menu ;;
 m|M) help_menu ;;
 b|B) backup_menu ;;
 l|L) language_menu ;;
 u|U) check_update ;;
 k|K) uninstall_manager ;;
 0)
 if [ "$LANG_SEL" = "en" ]; then
 echo -e "${CYAN} Exiting...${NC}"
 elif [ "$LANG_SEL" = "ru" ]; then
 echo -e "${CYAN} Выход...${NC}"
 else
 echo -e "${CYAN} Çıkılıyor...${NC}"
 fi
 sleep 1
 exit 0 ;;
 *) echo -e "${RED} ${L_INVALID}${NC}"; sleep 1 ;;
 esac
done
