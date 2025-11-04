import pyautogui
import pygetwindow as gw
import subprocess
import time
import os
from datetime import datetime

# === Configuration ===
SAVE_DIR = "docs/images"
os.makedirs(SAVE_DIR, exist_ok=True)

# Try to detect the Git Bash or Command Prompt window
TERMINAL_TITLES = ["MINGW64", "Git Bash", "Command Prompt", "cmd.exe"]

def get_terminal_window():
    """Find the first active terminal window."""
    for title in TERMINAL_TITLES:
        wins = gw.getWindowsWithTitle(title)
        if wins:
            win = wins[0]
            if not win.isMinimized:
                print(f"[INFO] Found window: {win.title}")
                return win
    print("[WARN] Could not find terminal window — capturing full screen.")
    return None

def run_and_capture(command, name, delay=3):
    """Run a shell command and capture the terminal area."""
    print(f"\n[INFO] Running: {command}")
    subprocess.run(command, shell=True)
    time.sleep(delay)

    win = get_terminal_window()
    timestamp = datetime.now().strftime("%H%M%S")
    filename = f"{SAVE_DIR}/{name}_{timestamp}.png"

    if win:
        # Capture only the terminal window region
        x, y, w, h = win.left, win.top, win.width, win.height
        image = pyautogui.screenshot(region=(x, y, w, h))
    else:
        # Fallback: capture full screen
        image = pyautogui.screenshot()

    image.save(filename)
    print(f"[OK] Screenshot saved → {filename}")

# === Run Backup Commands and Capture Screens ===
run_and_capture('bash -c "clear; ./backup.sh --dry-run /c/Users/Rahul\\\\ Sayya/Bash-practice/test_data"', "dry_run", 3)
run_and_capture('bash -c "clear; ./backup.sh /c/Users/Rahul\\\\ Sayya/Bash-practice/test_data"', "real_backup", 4)
run_and_capture('bash -c "clear; ls -lh backups/"', "backups_folder", 2)
run_and_capture('bash -c "clear; ls -lh logs/"', "logs_folder", 2)

print("\n✅ All screenshots captured successfully!")
print(f"📁 Screenshots are saved in the '{SAVE_DIR}' directory.")


