#!/usr/bin/env bash

# ==============================================================================
# Auto YouTube Downloader Professional
# Version: 3.3.0
# Description: Cross-platform CLI tool for high-quality media downloads.
# Requirements: yt-dlp, ffmpeg, curl, python3
# ==============================================================================

set -euo pipefail

# --- Version ---
VERSION="3.3.0"

# --- Terminal Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# --- Global Variables ---
DOWNLOAD_DIR="$HOME/Downloads/YT_Downloads"
CONFIG_FILE="$HOME/.yt_downloader_config"
LOG_FILE="$DOWNLOAD_DIR/logs/yt_downloader.log"
TEMP_DIR="/tmp/yt_downloader"
MAX_RETRIES=3

# --- Required Dependencies ---
REQUIRED_PACKAGES=("yt-dlp" "ffmpeg" "curl" "python3")

# --- Associative Arrays ---
declare -A QUALITY_MAP
declare -a QUALITY_OPTIONS
declare -a VIDEO_FORMAT_OPTIONS
declare -a AUDIO_FORMAT_OPTIONS

# ==============================================================================
# Initialization
# ==============================================================================

initialize() {
    clear

    echo -e "${CYAN}Initializing Auto YouTube Downloader...${NC}"

    mkdir -p \
        "$DOWNLOAD_DIR/videos" \
        "$DOWNLOAD_DIR/audio" \
        "$DOWNLOAD_DIR/logs" \
        "$TEMP_DIR"

    init_maps
    load_config
    check_dependencies

    trap cleanup EXIT INT TERM
}

cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null || true
}

init_maps() {
    QUALITY_MAP["max"]="bestvideo+bestaudio/best"
    QUALITY_MAP["4k"]="bestvideo[height<=2160]+bestaudio/best"
    QUALITY_MAP["2k"]="bestvideo[height<=1440]+bestaudio/best"
    QUALITY_MAP["1080p"]="bestvideo[height<=1080]+bestaudio/best"
    QUALITY_MAP["720p"]="bestvideo[height<=720]+bestaudio/best"
    QUALITY_MAP["audio_only"]="bestaudio/best"

    QUALITY_OPTIONS=("max" "4k" "2k" "1080p" "720p")
    VIDEO_FORMAT_OPTIONS=("mp4" "mkv" "webm")
    AUDIO_FORMAT_OPTIONS=("mp3" "m4a" "flac" "wav")
}

# ==============================================================================
# Configuration
# ==============================================================================

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    else
        DEFAULT_QUALITY="1080p"
        DEFAULT_FORMAT="mp4"
        SAVE_HISTORY=true
        AUTO_UPDATE=true

        save_config
    fi
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
DEFAULT_QUALITY="$DEFAULT_QUALITY"
DEFAULT_FORMAT="$DEFAULT_FORMAT"
SAVE_HISTORY=$SAVE_HISTORY
AUTO_UPDATE=$AUTO_UPDATE
EOF
}

# ==============================================================================
# Dependency Check
# ==============================================================================

check_dependencies() {
    local missing=0

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$pkg" >/dev/null 2>&1; then
            echo -e "${RED}[ERROR] Missing required package: $pkg${NC}"
            missing=1
        fi
    done

    if [[ $missing -eq 1 ]]; then
        echo
        echo -e "${YELLOW}Install the missing packages using:${NC}"
        echo -e "  ${WHITE}Ubuntu/Debian:${NC} sudo apt install yt-dlp ffmpeg curl python3"
        echo -e "  ${WHITE}Arch Linux:${NC} sudo pacman -S yt-dlp ffmpeg curl python"
        echo -e "  ${WHITE}macOS:${NC} brew install yt-dlp ffmpeg curl python"
        echo
        exit 1
    fi
}

# ==============================================================================
# Banner
# ==============================================================================

show_banner() {
    clear

    echo -e "${CYAN}"
    echo "    __  ______  __  __________  ______  ______ "
    echo "    \ \/ / __ \/ / / /_  __/ / / / __ )/ ____/ "
    echo "     \  / / / / / / / / / / / / / __  / __/    "
    echo "     / / /_/ / /_/ / / / / /_/ / /_/ / /___    "
    echo "    /_/\____/\____/ /_/  \____/_____/_____/    "
    echo "       ____  ______ _      狂  __    ____  ___    ____  __________ "
    echo "      / __ \/ __ \ | /| / / | / /   / __ \/   |  / __ \/ ____/ __ \ "
    echo "     / / / / / / / |/ |/ /| |/ /   / / / / /| | / / / / __/ / /_/ / "
    echo "    / /_/ / /_/ /|  /|  / |  /   / /_/ / ___ |/ /_/ / /___/ _, _/  "
    echo "   /_____/\____/ |_/ |_/  |_/   /_____/_/  |_/_____/_____/_/ |_|   "
    echo -e "${NC}"
    echo -e "   ${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${BLUE}System:${NC} v$VERSION  ${WHITE}|${NC}  ${BLUE}Engine:${NC} ${GREEN}yt-dlp${NC}  ${WHITE}|${NC}  ${BLUE}OS:${NC} Windows/Linux"
    echo -e "    ${BLUE}Storage:${NC} ${CYAN}$DOWNLOAD_DIR${NC}"
    echo -e "   ${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ==============================================================================
# Utility Functions
# ==============================================================================

pause_screen() {
    echo
    read -rp "Press Enter to continue..."
}

log_message() {
    local message="$1"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

# ==============================================================================
# Download Functions
# ==============================================================================

download_media() {
    local media_type="$1"

    echo -e "${GREEN}--- ${media_type} Download ---${NC}"
    echo

    read -rp "Enter the URL: " url

    if [[ -z "${url:-}" ]]; then
        echo -e "${RED}No URL provided.${NC}"
        pause_screen
        return
    fi

    local quality="max"
    local format="mp4"

    if [[ "$media_type" == "Video" ]]; then
        echo
        echo "Select video quality:"
        select quality in "${QUALITY_OPTIONS[@]}"; do
            [[ -n "${quality:-}" ]] && break
            echo "Invalid selection."
        done

        echo
        echo "Select video format:"
        select format in "${VIDEO_FORMAT_OPTIONS[@]}"; do
            [[ -n "${format:-}" ]] && break
            echo "Invalid selection."
        done
    else
        quality="audio_only"

        echo
        echo "Select audio format:"
        select format in "${AUDIO_FORMAT_OPTIONS[@]}"; do
            [[ -n "${format:-}" ]] && break
            echo "Invalid selection."
        done
    fi

    execute_engine "$url" "$quality" "$format" "$media_type"
}

execute_engine() {
    local url="$1"
    local quality="$2"
    local format="$3"
    local media_type="$4"

    local output_subfolder
    local retries=0

    if [[ "$media_type" == "Video" ]]; then
        output_subfolder="videos"
    else
        output_subfolder="audio"
    fi

    echo
    echo -e "${YELLOW}Starting download...${NC}"
    echo

    while [[ $retries -lt $MAX_RETRIES ]]; do
        if [[ "$media_type" == "Video" ]]; then
            yt-dlp \
                -f "${QUALITY_MAP[$quality]}" \
                --merge-output-format "$format" \
                --no-mtime \
                --add-metadata \
                --embed-thumbnail \
                --console-title \
                -o "$DOWNLOAD_DIR/$output_subfolder/%(title)s.%(ext)s" \
                "$url"

        else
            yt-dlp \
                -x \
                --audio-format "$format" \
                --audio-quality 0 \
                --no-mtime \
                --add-metadata \
                --embed-thumbnail \
                --console-title \
                -o "$DOWNLOAD_DIR/$output_subfolder/%(title)s.%(ext)s" \
                "$url"
        fi

        if [[ $? -eq 0 ]]; then
            echo
            echo -e "${GREEN}Download completed successfully.${NC}"

            log_message "$media_type downloaded successfully: $url"

            if [[ "$SAVE_HISTORY" == true ]]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') | $media_type | $url" \
                    >> "$DOWNLOAD_DIR/history.log"
            fi

            pause_screen
            return
        fi

        retries=$((retries + 1))

        echo -e "${YELLOW}Retrying download (${retries}/${MAX_RETRIES})...${NC}"
        sleep 2
    done

    echo
    echo -e "${RED}Download failed after $MAX_RETRIES attempts.${NC}"

    log_message "Download failed: $url"

    pause_screen
}

# ==============================================================================
# Engine Update
# ==============================================================================

update_engine() {
    echo
    echo -e "${CYAN}Updating yt-dlp...${NC}"
    echo

    if yt-dlp -U; then
        echo
        echo -e "${GREEN}yt-dlp updated successfully.${NC}"
    else
        echo
        echo -e "${RED}Failed to update yt-dlp.${NC}"
    fi

    pause_screen
}

# ==============================================================================
# History Viewer
# ==============================================================================

view_history() {
    local history_file="$DOWNLOAD_DIR/history.log"

    echo

    if [[ -f "$history_file" ]]; then
        less "$history_file"
    else
        echo -e "${YELLOW}No download history found.${NC}"
        pause_screen
    fi
}

# ==============================================================================
# Main Menu
# ==============================================================================

main_menu() {
    while true; do
        show_banner

        echo -e "1) ${WHITE}Download Video${NC}"
        echo -e "2) ${WHITE}Download Audio${NC}"
        echo -e "3) ${WHITE}Update yt-dlp${NC}"
        echo -e "4) ${WHITE}View Download History${NC}"
        echo -e "5) ${RED}Exit${NC}"
        echo

        read -rp "Select an option: " choice

        case "$choice" in
            1)
                download_media "Video"
                ;;
            2)
                download_media "Audio"
                ;;
            3)
                update_engine
                ;;
            4)
                view_history
                ;;
            5)
                echo -e "${GREEN}Goodbye.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option.${NC}"
                sleep 1
                ;;
        esac
    done
}

# ==============================================================================
# Entry Point
# ==============================================================================

initialize
main_menu