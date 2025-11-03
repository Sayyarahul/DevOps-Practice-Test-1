#!/usr/bin/env bash
# ==========================================================
# Bash Backup Automation Script with Logging (v2.0)
# Author: Rahul Sayya
# ==========================================================

set -euo pipefail

# ----------------------------------------------------------
# Configuration
# ----------------------------------------------------------
CONFIG_FILE="./backup.config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found ($CONFIG_FILE)"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"

# ----------------------------------------------------------
# Logging Setup
# ----------------------------------------------------------
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +'%Y-%m-%d').log"

# Redirect stdout and stderr to both console and log
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================================="
echo "[INFO] Backup started at: $(date)"
echo "=========================================================="

# ----------------------------------------------------------
# Dry Run Mode
# ----------------------------------------------------------
if [[ "${1:-}" == "--dry-run" ]]; then
    SOURCE_DIR="${2:-}"
    echo "[INFO] Dry run mode enabled"
    echo "[INFO] Would backup folder: $SOURCE_DIR"
    echo "[INFO] Would save backup to: $BACKUP_DESTINATION"
    echo "[INFO] Would skip patterns: $EXCLUDE_PATTERNS"
    echo "[INFO] Would keep daily=$DAILY_KEEP weekly=$WEEKLY_KEEP monthly=$MONTHLY_KEEP"
    echo "[INFO] Logs are stored at: $LOG_FILE"
    echo "=========================================================="
    echo "[INFO] Dry run completed at: $(date)"
    echo "=========================================================="
    exit 0
fi

# ----------------------------------------------------------
# Validate Source Folder
# ----------------------------------------------------------
SOURCE_DIR="${1:-}"
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source folder not found ($SOURCE_DIR)"
    exit 1
fi

# ----------------------------------------------------------
# Create Backup
# ----------------------------------------------------------
mkdir -p "$BACKUP_DESTINATION"

BACKUP_NAME="backup-$(date +'%Y-%m-%d-%H%M').tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_NAME"

echo "[INFO] Creating backup archive..."
tar --exclude={${EXCLUDE_PATTERNS}} -czf "$BACKUP_PATH" "$SOURCE_DIR"
echo "[INFO] Backup created: $BACKUP_PATH"

# ----------------------------------------------------------
# Generate and Verify Checksum
# ----------------------------------------------------------
CHECKSUM_FILE="$BACKUP_PATH.sha256"
echo "[INFO] Generating checksum..."
$CHECKSUM_CMD "$BACKUP_PATH" > "$CHECKSUM_FILE"

echo "[INFO] Verifying backup integrity..."
$CHECKSUM_CMD -c "$CHECKSUM_FILE"
echo "[SUCCESS] Checksum verified successfully."

# ----------------------------------------------------------
# Cleanup Old Backups
# ----------------------------------------------------------
echo "[INFO] Cleaning old backups..."
find "$BACKUP_DESTINATION" -type f -name "backup-*.tar.gz" -mtime +30 -delete
echo "[INFO] Old backups cleaned."

# ----------------------------------------------------------
# Finish
# ----------------------------------------------------------
echo "[INFO] Backup completed successfully at: $(date)"
echo "[INFO] Log saved to: $LOG_FILE"
echo "=========================================================="



