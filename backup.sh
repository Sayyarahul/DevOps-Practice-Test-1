#!/usr/bin/env bash
# ==========================================================
# Bash Backup Automation Script (Automatic Cleanup Version)
# Author: Rahul Sayya
# Version: v4.0 (Auto Delete + Real-Time Log)
# ==========================================================

set -euo pipefail

# ----------------------------------------------------------
# Load Configuration
# ----------------------------------------------------------
CONFIG_FILE="./backup.config"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found ($CONFIG_FILE)"
    exit 1
fi
source "$CONFIG_FILE"

# ----------------------------------------------------------
# Logging Setup
# ----------------------------------------------------------
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +'%Y-%m-%d').log"
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
    echo "[INFO] Log file: $LOG_FILE"
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
# Prepare Destination
# ----------------------------------------------------------
mkdir -p "$BACKUP_DESTINATION"
cd "$BACKUP_DESTINATION"

# ----------------------------------------------------------
# Create Backup
# ----------------------------------------------------------
TIMESTAMP=$(date +'%Y-%m-%d-%H%M')
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_NAME"

echo "[INFO] Creating backup archive..."
tar --exclude={${EXCLUDE_PATTERNS}} -czf "$BACKUP_PATH" "$SOURCE_DIR"
echo "[SUCCESS] Backup created: $BACKUP_PATH"

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
# Automatic Cleanup (Daily, Weekly, Monthly)
# ----------------------------------------------------------
echo "[INFO] Applying automatic cleanup at $(date)..."

keep_latest() {
    local PATTERN=$1
    local KEEP=$2
    local LABEL=$3
    local COUNT
    COUNT=$(ls -tp $PATTERN 2>/dev/null | wc -l || true)

    if (( COUNT > KEEP )); then
        local DELETE_COUNT=$((COUNT - KEEP))
        echo "[INFO] Found $COUNT $LABEL backups. Keeping $KEEP, deleting $DELETE_COUNT older backups."
        ls -tp $PATTERN | tail -n +$((KEEP+1)) | while read -r file; do
            echo "[INFO] Deleting old $LABEL backup: $file"
            rm -f -- "$file"
        done
    else
        echo "[INFO] Found $COUNT $LABEL backups. Nothing to delete."
    fi
}

# Keep 7 daily backups
keep_latest "backup-*.tar.gz" "$DAILY_KEEP" "daily"
keep_latest "backup-*.tar.gz.sha256" "$DAILY_KEEP" "daily checksum"

# Keep 4 weekly backups
echo "[INFO] Checking weekly backups..."
find . -type f -name "backup-*.tar.gz" -printf "%T@ %p\n" | sort -nr | \
awk -v limit="$WEEKLY_KEEP" '
{
  cmd = "date -d @"$1" +%Y-%V"
  cmd | getline week
  close(cmd)
  if (!(week in seen) && (length(seen) < limit)) seen[week] = $2
  else print $2
}' | while read -r oldfile; do
    echo "[INFO] Deleting old weekly backup: $oldfile"
    rm -f -- "$oldfile"
done

# Keep 3 monthly backups
echo "[INFO] Checking monthly backups..."
find . -type f -name "backup-*.tar.gz" -printf "%T@ %p\n" | sort -nr | \
awk -v limit="$MONTHLY_KEEP" '
{
  cmd = "date -d @"$1" +%Y-%m"
  cmd | getline month
  close(cmd)
  if (!(month in seen) && (length(seen) < limit)) seen[month] = $2
  else print $2
}' | while read -r oldfile; do
    echo "[INFO] Deleting old monthly backup: $oldfile"
    rm -f -- "$oldfile"
done

echo "[INFO] Cleanup completed successfully at $(date)"
echo "[INFO] Retention policy applied successfully."

# ----------------------------------------------------------
# Finish
# ----------------------------------------------------------
echo "=========================================================="
echo "[SUCCESS] Backup process completed successfully at: $(date)"
echo "[INFO] Log saved to: $LOG_FILE"
echo "=========================================================="





