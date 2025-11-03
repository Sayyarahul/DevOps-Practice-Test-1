#!/bin/bash
# ==========================================
# 🔒 SMART BACKUP TOOL - Bash Version
# Author: Rahul Sayya
# ==========================================

# -----------------------------
# 1️⃣ Load Configuration
# -----------------------------
CONFIG_FILE=./backup.config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found ($CONFIG_FILE)"
    exit 1
fi
source "$CONFIG_FILE"

# -----------------------------
# 2️⃣ Lock File (Prevent Multiple Runs)
# -----------------------------
LOCK_FILE="/tmp/backup.lock"
if [ -f "$LOCK_FILE" ]; then
    echo "Error: Another backup is already running."
    exit 1
fi
touch "$LOCK_FILE"

# Make sure lock file is removed even if script exits unexpectedly
trap "rm -f $LOCK_FILE" EXIT

# -----------------------------
# 3️⃣ Dry Run Mode
# -----------------------------
if [[ "$1" == "--dry-run" ]]; then
    SOURCE_DIR="$2"
    echo "[INFO] Dry run mode enabled"
    echo "[INFO] Would backup folder: $SOURCE_DIR"
    echo "[INFO] Would save backup to: $BACKUP_DESTINATION"
    echo "[INFO] Would skip patterns: $EXCLUDE_PATTERNS"
    echo "[INFO] Would keep daily=$DAILY_KEEP weekly=$WEEKLY_KEEP monthly=$MONTHLY_KEEP"
    exit 0
fi

# -----------------------------
# 4️⃣ Input Validation
# -----------------------------
SOURCE_DIR="$1"
if [ -z "$SOURCE_DIR" ]; then
    echo "Usage: $0 [--dry-run] <source_folder>"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source folder not found ($SOURCE_DIR)"
    exit 1
fi

# -----------------------------
# 5️⃣ Prepare Backup Paths
# -----------------------------
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
BACKUP_FILE="$BACKUP_DESTINATION/$BACKUP_NAME"
CHECKSUM_FILE="$BACKUP_FILE.sha256"

mkdir -p "$BACKUP_DESTINATION"

# -----------------------------
# 6️⃣ Create Backup (Function)
# -----------------------------
create_backup() {
    echo "[INFO] Creating backup for: $SOURCE_DIR"
    local exclude_args=()
    IFS=',' read -ra patterns <<< "$EXCLUDE_PATTERNS"
    for pattern in "${patterns[@]}"; do
        exclude_args+=(--exclude="$pattern")
    done

    tar -czf "$BACKUP_FILE" "${exclude_args[@]}" "$SOURCE_DIR" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo "[ERROR] Backup creation failed."
        return 1
    fi

    echo "[SUCCESS] Backup created: $BACKUP_FILE"
}

# -----------------------------
# 7️⃣ Verify Backup Integrity
# -----------------------------
verify_backup() {
    echo "[INFO] Verifying backup integrity..."
    sha256sum "$BACKUP_FILE" > "$CHECKSUM_FILE"
    local verify_result
    verify_result=$(sha256sum -c "$CHECKSUM_FILE" 2>/dev/null)
    if echo "$verify_result" | grep -q "OK"; then
        echo "[SUCCESS] Checksum verified successfully."
    else
        echo "[ERROR] Checksum verification failed."
    fi
}

# -----------------------------
# 8️⃣ Delete Old Backups
# -----------------------------
delete_old_backups() {
    echo "[INFO] Cleaning old backups..."
    local files=($(ls -1t "$BACKUP_DESTINATION"/backup-*.tar.gz 2>/dev/null))

    # Keep only the latest N backups based on policy
    local keep=$((DAILY_KEEP + WEEKLY_KEEP + MONTHLY_KEEP))
    if [ ${#files[@]} -gt $keep ]; then
        for ((i=keep; i<${#files[@]}; i++)); do
            echo "[INFO] Deleting old backup: ${files[$i]}"
            rm -f "${files[$i]}" "${files[$i]}.sha256"
        done
    fi
}

# -----------------------------
# 9️⃣ Main Execution Flow
# -----------------------------
create_backup
verify_backup
delete_old_backups

echo "[DONE] Backup process completed successfully."


