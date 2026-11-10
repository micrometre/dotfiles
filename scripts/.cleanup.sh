#!/usr/bin/env bash
####################################
#
# System Cleanup Script
# Clears cache and temporary files before backup
#
####################################

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_NAME="Pre-Backup Cleanup"
DRY_RUN=false
AUTO_CONFIRM=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<'EOF'
Usage: cleanup.sh [options]

Options:
  -y, --yes         Skip the confirmation prompt.
  -n, --dry-run     Show what would be removed without deleting anything.
  -h, --help        Show this help message.
EOF
}

log() {
    printf '%b\n' "$1"
}

log_info() {
    log "${BLUE}$1${NC}"
}

log_warn() {
    log "${YELLOW}$1${NC}"
}

log_error() {
    log "${RED}$1${NC}"
}

check_root() {
    if [[ ${EUID} -ne 0 ]]; then
        log_error "ERROR: This script must be run as root (use sudo)."
        exit 1
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -y|--yes)
                AUTO_CONFIRM=true
                ;;
            -n|--dry-run)
                DRY_RUN=true
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
}

display_header() {
    echo "========================================="
    echo "$SCRIPT_NAME"
    echo "========================================="
    echo "Hostname: $(hostname -s)"
    echo "Date: $(date)"
    echo "========================================="
    echo ""
}

disk_used_kib() {
    df -Pk / | awk 'NR==2 {print $3}'
}

humanize_size() {
    local size_bytes="${1:-0}"
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec-i --suffix=B "$size_bytes"
        return
    fi

    local size="$size_bytes"
    local unit="B"
    if (( size >= 1024 * 1024 * 1024 )); then
        size=$((size / 1024 / 1024 / 1024))
        unit="G"
    elif (( size >= 1024 * 1024 )); then
        size=$((size / 1024 / 1024))
        unit="M"
    elif (( size >= 1024 )); then
        size=$((size / 1024))
        unit="K"
    fi

    printf '%s%s' "$size" "$unit"
}

run_or_echo() {
    local description="$1"
    shift

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "[DRY RUN] $description"
        return 0
    fi

    "$@"
}

safe_remove_contents() {
    local path="$1"
    local label="$2"

    if [[ ! -d "$path" ]]; then
        return 0
    fi

    local size_kib
    size_kib=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "[DRY RUN] Would clear ${label} (${size_kib} KiB)"
        return 0
    fi

    log_info "Cleaning ${label} (${size_kib} KiB)"
    find "$path" -mindepth 1 -exec rm -rf -- {} + 2>/dev/null || true
}

calculate_before() {
    log_warn "Calculating current disk usage..."
    DISK_BEFORE=$(disk_used_kib)
    echo ""
}

clean_package_cache() {
    log_info "[1/9] Cleaning APT package cache..."
    if command -v apt-get >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == true ]]; then
            log_warn "[DRY RUN] Would run: apt-get clean && apt-get autoclean"
        else
            apt-get clean
            apt-get autoclean
        fi
    else
        log_warn "apt-get not found; skipping package cache cleanup."
    fi
    echo ""
}

clean_old_kernels() {
    log_info "[2/9] Checking for old kernels..."
    local current_kernel current_kernels
    current_kernel=$(uname -r)
    echo "Current kernel: $current_kernel"

    if command -v dpkg >/dev/null 2>&1; then
        mapfile -t current_kernels < <(dpkg-query -W -f='${Package}\n' 'linux-image-*' 2>/dev/null || true)
        if [[ ${#current_kernels[@]} -eq 0 ]]; then
            echo "No installed Linux kernels detected."
        else
            for pkg in "${current_kernels[@]}"; do
                if [[ "$pkg" != "linux-image-$current_kernel" ]]; then
                    echo "$pkg"
                fi
            done
        fi
    else
        log_warn "dpkg not available; skipping kernel check."
    fi
    echo ""
}

clean_thumbnails() {
    log_info "[3/9] Cleaning thumbnail caches..."
    for user_home in /home/*; do
        if [[ -d "$user_home/.cache/thumbnails" ]]; then
            safe_remove_contents "$user_home/.cache/thumbnails" "thumbnails for $(basename "$user_home")"
        fi
    done

    if [[ -d "/root/.cache/thumbnails" ]]; then
        safe_remove_contents "/root/.cache/thumbnails" "thumbnails for root"
    fi
    echo ""
}

clean_user_cache() {
    log_info "[4/9] Cleaning user cache directories..."
    for user_home in /home/*; do
        if [[ -d "$user_home/.cache" ]]; then
            safe_remove_contents "$user_home/.cache" "cache for $(basename "$user_home")"
        fi
    done

    if [[ -d "/root/.cache" ]]; then
        safe_remove_contents "/root/.cache" "cache for root"
    fi
    echo ""
}

clean_trash() {
    log_info "[5/9] Cleaning user trash directories..."
    for user_home in /home/*; do
        local trash_path="$user_home/.local/share/Trash"
        if [[ -d "$trash_path" ]]; then
            local trash_size
            trash_size=$(du -sk "$trash_path" 2>/dev/null | awk '{print $1}')
            if [[ -n "$trash_size" && "$trash_size" != "0" ]]; then
                safe_remove_contents "$trash_path" "trash for $(basename "$user_home")"
            fi
        fi
    done
    echo ""
}

clean_tmp() {
    log_info "[6/9] Cleaning temporary files..."
    for target in /tmp /var/tmp; do
        if [[ -d "$target" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                log_warn "[DRY RUN] Would delete files older than 7 days and empty directories under $target"
            else
                find "$target" -type f -atime +7 -delete 2>/dev/null || true
                find "$target" -mindepth 1 -type d -empty -delete 2>/dev/null || true
            fi
        fi
    done
    echo ""
}

clean_system_cache() {
    log_info "[7/9] Cleaning system cache..."
    if [[ -d "/var/cache" ]]; then
        local cache_size
        cache_size=$(du -sk /var/cache 2>/dev/null | awk '{print $1}')
        echo "Current /var/cache size: ${cache_size} KiB"

        if [[ -d "/var/cache/apt/archives" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                log_warn "[DRY RUN] Would remove stale .deb packages from /var/cache/apt/archives"
            else
                rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb 2>/dev/null || true
                echo "✓ Cleaned APT archives"
            fi
        fi

        if [[ "$DRY_RUN" == true ]]; then
            log_warn "[DRY RUN] Would remove *.cache files under /var/cache"
        else
            find /var/cache -type f -name "*.cache" -delete 2>/dev/null || true
        fi
    fi
    echo ""
}

clean_old_logs() {
    log_info "[8/9] Cleaning old log files..."
    if [[ -d "/var/log" ]]; then
        local log_size
        log_size=$(du -sk /var/log 2>/dev/null | awk '{print $1}')
        echo "Current /var/log size: ${log_size} KiB"

        if [[ "$DRY_RUN" == true ]]; then
            log_warn "[DRY RUN] Would delete rotated logs older than 7 days and truncate large .log files under /var/log"
        else
            find /var/log -type f \( -name "*.gz" -o -name "*.1" -o -name "*.old" \) -mtime +7 -delete 2>/dev/null || true

            shopt -s nullglob
            for log in /var/log/*.log; do
                if [[ -f "$log" ]]; then
                    local size
                    size=$(stat -c%s "$log" 2>/dev/null || echo 0)
                    if (( size > 10485760 )); then
                        echo "Truncating large log: $(basename "$log") ($(humanize_size "$size"))"
                        tail -n 1000 "$log" > "$log.tmp"
                        mv "$log.tmp" "$log"
                    fi
                fi
            done
            shopt -u nullglob
        fi

        echo "✓ Old logs processed"
    fi
    echo ""
}

clean_journal() {
    log_info "[9/9] Cleaning systemd journal logs..."
    if command -v journalctl >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == true ]]; then
            log_warn "[DRY RUN] Would run journalctl --vacuum-time=7d"
        else
            local journal_size
            journal_size=$(journalctl --disk-usage 2>/dev/null | grep -Eo '[0-9]+(\.[0-9]+)?[KMGT]?' | tail -n 1 || true)
            echo "Current journal size: ${journal_size:-unknown}"
            journalctl --vacuum-time=7d 2>/dev/null || true
            local new_journal_size
            new_journal_size=$(journalctl --disk-usage 2>/dev/null | grep -Eo '[0-9]+(\.[0-9]+)?[KMGT]?' | tail -n 1 || true)
            echo "New journal size: ${new_journal_size:-unknown}"
        fi
    else
        log_warn "journalctl not found; skipping journal cleanup."
    fi
    echo ""
}

calculate_after() {
    log_warn "Calculating disk usage after cleanup..."
    DISK_AFTER=$(disk_used_kib)
    DISK_FREED=$((DISK_BEFORE - DISK_AFTER))
    DISK_FREED_MB=$((DISK_FREED / 1024))

    echo ""
    echo "========================================="
    echo "Cleanup Summary"
    echo "========================================="
    echo "Space freed: ${DISK_FREED_MB} MB"
    echo ""
    echo "Current disk usage:"
    df -h /
    echo "========================================="
}

main() {
    parse_args "$@"
    check_root
    display_header

    if [[ "$AUTO_CONFIRM" != true ]]; then
        read -r -p "This will clean cache, temporary files, and old logs. Continue? (y/n): " -n 1 REPLY
        echo
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Cleanup cancelled."
            exit 0
        fi
    fi

    echo ""
    START_TIME=$(date +%s)
    calculate_before

    clean_package_cache
    clean_old_kernels
    clean_thumbnails
    clean_user_cache
    clean_trash
    clean_tmp
    clean_system_cache
    clean_old_logs
    clean_journal

    calculate_after

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo ""
    echo "Cleanup completed in $DURATION seconds"
    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "This was a dry run; no files were deleted."
    else
        log_info "System is ready for backup!"
    fi
}

main "$@"
exit 0
