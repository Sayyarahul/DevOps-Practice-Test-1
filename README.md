# 🧰 Bash Backup Automation Script (v2.0)

A simple yet powerful **backup automation system** written in Bash.
It supports **dry-run mode**, **log generation**, **checksum verification**, and **automatic cleanup** of old backups.

---

## 🚀 Features

✅ Dry-run mode (safe preview before running real backups)
✅ Auto-generated logs (`logs/backup_YYYY-MM-DD.log`)
✅ SHA256 checksum verification for data integrity
✅ Configurable retention policy (daily, weekly, monthly)
✅ Exclusion patterns (`.git`, `node_modules`, etc.)
✅ Works on Linux, macOS, and Git Bash for Windows

---

## 📦 Project Structure

```
Bash-practice/
├── backup.sh             # Main backup script
├── backup.config         # Configuration file
├── backups/              # Backup storage folder
├── logs/                 # Log files created here automatically
├── test_data/            # Example source data folder
└── README.md             # Documentation
```

---

## ⚙️ Configuration (`backup.config`)

Example:

```bash
# -------------------------------------
# Backup Script Configuration
# -------------------------------------

# Destination folder where backups will be stored
BACKUP_DESTINATION=/c/Users/Rahul\ Sayya/Bash-practice/backups

# Patterns to exclude (comma-separated)
EXCLUDE_PATTERNS=".git,node_modules,.cache"

# Retention policy
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3

# Command used for checksums
CHECKSUM_CMD=sha256sum
```

---

## 🧠 Usage

### 1️⃣ Run in **Dry Run Mode** (Test only)

```bash
./backup.sh --dry-run /c/Users/Rahul\ Sayya/Bash-practice/test_data
```

Output example:

```
[INFO] Dry run mode enabled
[INFO] Would backup folder: /c/Users/Rahul Sayya/Bash-practice/test_data
[INFO] Would save backup to: /c/Users/Rahul Sayya/Bash-practice/backups
[INFO] Would skip patterns: .git,node_modules,.cache
[INFO] Would keep daily=7 weekly=4 monthly=3
```

A dry run **does not create** any backup files — it only previews what will happen.

---

### 2️⃣ Run Real Backup

```bash
./backup.sh /c/Users/Rahul\ Sayya/Bash-practice/test_data
```

Expected output:

```
[INFO] Creating backup archive...
[INFO] Backup created: /c/Users/Rahul Sayya/Bash-practice/backups/backup-2025-11-03-1530.tar.gz
[INFO] Generating checksum...
[SUCCESS] Checksum verified successfully.
[INFO] Cleaning old backups...
[DONE] Backup process completed successfully.
```

---

### 3️⃣ Check Log Files

All backup logs are stored automatically in the `logs/` folder:

```bash
cat logs/backup_2025-11-03.log
```

---

## 🧹 Cleanup & Retention Policy

The script automatically removes backups older than **30 days**.
You can customize this in the script or config file as per your needs.

---

## 🧑‍💻 Contributing

Feel free to fork this repository and enhance the script — add email alerts, S3 uploads, or cron job scheduling!

---

## 🪪 License

This project is open-source and available under the **MIT License**.

---

**Author:** [Rahul Sayya](https://github.com/Sayyarahul)
**Version:** 2.0
**Repository:** [Sayyarahul/DevOps-Practice-Test-1](https://github.com/Sayyarahul/DevOps-Practice-Test-1)
![Dry run](docs/images/dry-run.png)
![Backup success](docs/images/backup-success.png)
## 📸 Screenshots

**Dry Run Mode**  
![Dry Run](docs/images/dry_run_155620.png)

**Real Backup Execution**  
![Real Backup](docs/images/real_backup_155640.png)

**Backups Folder**  
![Backups Folder](docs/images/backups_folder_155702.png)

**Logs Folder**  
![Logs Folder](docs/images/logs_folder_155712.png)

