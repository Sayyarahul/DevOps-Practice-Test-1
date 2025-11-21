#  Automated Backup System (Bash Project)

A fully automated and configurable backup system written in **Bash**, designed to create secure backups, verify integrity, rotate old backups, restore data, and prevent accidental double runs.  
This project follows all requirements of the *Bash Scripting Project: Automated Backup System*.

---

#  1. Project Overview

This script automatically:

✔ Creates compressed backups (`.tar.gz`)  
✔ Generates checksum (`.sha256`)  
✔ Verifies backup integrity  
✔ Restores backups (using `--restore`)  
✔ Runs in dry-run mode (safe preview)  
✔ Deletes older backups using retention rules  
✔ Prevents double executions using a lock file  
✔ Stores logs for every backup job  

This makes backup management safe, simple, and reliable for DevOps / SysAdmin environments.

---

#  2. Project Structure

```
Bash-practice/
│── backup.sh            # Main script
│── backup.config        # User configuration file
│── backups/             # Generated backup files
│── logs/                # Auto-generated log files
│── test_data/           # Test folder for backups
└── restored_files/      # Example restore location
```

---

#  3. Configuration (backup.config)

Your script reads user settings from this file:

```bash
BACKUP_DESTINATION=/c/Users/Rahul\ Sayya/Bash-practice/backups
EXCLUDE_PATTERNS=".git,node_modules,.cache"
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3
CHECKSUM_CMD=sha256sum
```

Users can fully customize:

- Backup location  
- Excluded folders  
- Retention policy  
- Checksum command  

---

#  4. How to Use the Script

###  1. Make the script executable

```bash
chmod +x backup.sh
```

---

###  2. Run in **Dry Run Mode**

Shows what the script *would* do:

```bash
./backup.sh --dry-run /c/Users/Rahul\ Sayya/Bash-practice/test_data
```

Example output:

```
[INFO] Dry run mode enabled
[INFO] Would backup folder: test_data
[INFO] Would skip: .git,node_modules,.cache
```

---

###  3. Create a Real Backup

```bash
./backup.sh /c/Users/Rahul\ Sayya/Bash-practice/test_data
```

Expected output:

```
[INFO] Creating backup...
[SUCCESS] Backup created: backup-2025-11-21-1129.tar.gz
[SUCCESS] Checksum verified
```

---

###  4. Restore From a Backup

```bash
./backup.sh --restore backups/backup-2025-11-21-1129.tar.gz --to ./restored_files
```

Output:

```
[SUCCESS] Restore completed successfully!
```

---

###  5. List All Backups (if implemented)

```bash
./backup.sh --list
```

---

#  5. How It Works

###  A. Backup Creation

- Uses `tar -czf` to compress the source folder into `.tar.gz`
- Skips excluded patterns
- Names backups using timestamp:

```
backup-YYYY-MM-DD-HHMM.tar.gz
```

---

###  B. Integrity Verification

After creation:

```bash
sha256sum backup.tar.gz > backup.tar.gz.sha256
sha256sum -c backup.tar.gz.sha256
```

Ensures no corruption.

---

###  C. Retention Policy (Auto-Delete Old Backups)

Your script keeps:

- **7 daily backups**  
- **4 weekly backups**  
- **3 monthly backups**

Everything older is automatically removed.

---

###  D. Lock File Protection

Prevents accidental double-run:

```
/tmp/backup.lock
```

If lock exists → script exits.

---

#  6. Design Decisions

| Feature | Why it’s used |
|--------|----------------|
| `.tar.gz` format | Fast, universal, efficient |
| SHA256 checksum | Strong integrity check |
| Config file | Users can customize without editing script |
| Logging | Audit trail for backup jobs |
| Lock file | Prevents duplicate runs and corrupted backups |
| Test extraction | Validates backup contents |

---

#  7. Testing

###  Backup creation test

```bash
./backup.sh test_data/
```

###  Simulated multiple backups  
Create backups at different times → verify cleanup runs correctly.

###  Dry run tests  
Ensures nothing is created.

###  Error handling

```bash
./backup.sh /does/not/exist
```

Expected:

```
Error: Source folder not found
```

###  Restore test

```bash
./backup.sh --restore backups/backup-time.tar.gz --to restored_files
```

---

#  8. Known Limitations

- Incremental backups not included (bonus feature)
- Email notifications not added
- Disk space check not implemented
- Listing backups (`--list`) optional

---

#  9. Example Log Output

```
[2025-11-21 11:29:47] INFO: Creating backup: backup-2025-11-21-1129.tar.gz
[2025-11-21 11:29:47] SUCCESS: Backup created
[2025-11-21 11:29:47] INFO: Checksum verified
[2025-11-21 11:29:47] INFO: Cleanup completed
```

---

#  10. Author

**Name:** Rahul Sayya  
**GitHub:** https://github.com/Sayyarahul  
**Year:** 2025  
**Project Version:** 4.0  

---

# 11. How to Push to GitHub

Inside your project folder:

```bash
git init
git add .
git commit -m "Initial commit - Backup automation system"
git branch -M main
git remote add origin https://github.com/Sayyarahul/DevOps-Practice-Test-1.git
git push -u origin main
```

---

# Project Completed Successfully!

Your script includes:

✔ Backup creation  
✔ Checksum generation  
✔ Checksum verification  
✔ Restoration  
✔ Rotation policy  
✔ Logging  
✔ Dry run mode  
✔ Lock file protection  



