#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Bash Automated Backup System - v5.0 (Full Features)
# Author: Rahul Sayya
# ==========================================================

LOCK_FILE="/tmp/backup.lock"

# Lock File Protection
if [[ -f "$LOCK_FILE" ]]; then
    echo "[ERROR] Another backup is already running!"
    exit 1
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

# Load Config
CONFIG_FILE="./backup.config"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[ERROR] Missing config file: backup.config"
    exit 1
fi
source "$CONFIG_FILE"

# Log Setup
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +'%Y-%m-%d').log"
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1: $2" | tee -a "$LOG_FILE"
}

log "INFO" "Backup script started"

# ==========================================================
# Command: --list
# ==========================================================
if [[ "${1:-}" == "--list" ]]; then
    log "INFO" "Listing available backups..."
    ls -lh "$BACKUP_DESTINATION"
    exit 0
fi

# ==========================================================
# Command: --restore
# ==========================================================
if [[ "${1:-}" == "--restore" ]]; then
    BACKUP_FILE="$2"
    if [[ "${3:-}" != "--to" ]]; then
        echo "[ERROR] Usage: ./backup.sh --restore <file> --to <folder>"
        exit 1
    fi
    RESTORE_PATH="$4"

    restore_backup() {
        local backup_file="$1"
        local restore_dest="$2"

        log "INFO" "Restore requested. Backup: $backup_file → Destination: $restore_dest"

        # Check backup exists
        if [[ ! -f "$backup_file" ]]; then
            log "ERROR" "Backup file not found ($backup_file)"
            echo "[ERROR] Backup file not found ($backup_file)"
            exit 1
        fi

        # Create restore directory
        if [[ ! -d "$restore_dest" ]]; then
            log "INFO" "Restore directory missing. Creating it..."
            mkdir -p "$restore_dest" 2>/dev/null || {
                echo "[ERROR] Permission denied creating restore directory"
                exit 1
            }
        fi

        # Verify checksum
        if [[ -f "${backup_file}.sha256" ]]; then
            log "INFO" "Verifying checksum..."
            if ! sha256sum -c "${backup_file}.sha256" >/dev/null 2>&1; then
                log "ERROR" "Checksum verification failed!"
                exit 1
            fi
            log "SUCCESS" "Checksum OK"
        fi

        # Extract backup
        log "INFO" "Extracting backup..."
        if ! tar -xzf "$backup_file" -C "$restore_dest"; then
            log "ERROR" "Restore failed!"
            exit 1
        fi

        log "SUCCESS" "Restore completed successfully!"
        echo "[SUCCESS] Restore completed!"
    }

    restore_backup "$BACKUP_FILE" "$RESTORE_PATH"
    exit 0
fi

# ==========================================================
# Command: --dry-run
# ==========================================================
if [[ "${1:-}" == "--dry-run" ]]; then
    SOURCE_DIR="$2"
    log "INFO" "Dry Run Mode Enabled"
    log "INFO" "Would backup: $SOURCE_DIR"
    log "INFO" "Would save to: $BACKUP_DESTINATION"
    log "INFO" "Excluding: $EXCLUDE_PATTERNS"
    log "INFO" "Retention: daily=$DAILY_KEEP weekly=$WEEKLY_KEEP monthly=$MONTHLY_KEEP"
    exit 0
fi

# ==========================================================
# Regular Backup Mode
# ==========================================================
SOURCE_DIR="${1:-}"

if [[ ! -d "$SOURCE_DIR" ]]; then
    log "ERROR" "Source folder not found ($SOURCE_DIR)"
    echo "[ERROR] Source folder not found ($SOURCE_DIR)"
    exit 1
fi

mkdir -p "$BACKUP_DESTINATION"
TIMESTAMP=$(date +'%Y-%m-%d-%H%M')
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_FILE"

log "INFO" "Creating backup: $BACKUP_PATH"

tar --exclude={${EXCLUDE_PATTERNS}} -czf "$BACKUP_PATH" "$SOURCE_DIR"
log "SUCCESS" "Backup created: $BACKUP_PATH"

# Checksum
log "INFO" "Generating checksum..."
sha256sum "$BACKUP_PATH" > "${BACKUP_PATH}.sha256"

log "INFO" "Verifying checksum..."
sha256sum -c "${BACKUP_PATH}.sha256"

# Verify extraction
log "INFO" "Testing extraction..."
TEMP_DIR="/tmp/test_extract_$$"
mkdir "$TEMP_DIR"
tar -xzf "$BACKUP_PATH" -C "$TEMP_DIR"
rm -rf "$TEMP_DIR"
log "SUCCESS" "Extraction test passed!"

# ==========================================================
# Cleanup (Daily, Weekly, Monthly)
# ==========================================================
log "INFO" "Cleaning old backups..."

delete_old() {
    PATTERN="$1"
    KEEP="$2"
    LABEL="$3"

    FILES=($(ls -1t $PATTERN 2>/dev/null))
    COUNT=${#FILES[@]}

    if (( COUNT > KEEP )); then
        for ((i=KEEP; i<COUNT; i++)); do
            log "INFO" "Deleting old $LABEL backup: ${FILES[$i]}"
            rm -f "${FILES[$i]}"
        done
    fi
}

cd "$BACKUP_DESTINATION"
delete_old "backup-*.tar.gz" "$DAILY_KEEP" "daily"
delete_old "backup-*.sha256" "$DAILY_KEEP" "daily checksum"

log "SUCCESS" "Backup completed!"
log "INFO" "Logs saved to $LOG_FILE"

exit 0





