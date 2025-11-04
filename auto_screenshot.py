import pyautogui
import pygetwindow as gw
import subprocess
import time
import os
from datetime import datetime
from PIL import Image, ImageDraw, ImageFont

# === Configuration ===
SAVE_DIR = "docs/images"
os.makedirs(SAVE_DIR, exist_ok=True)

TERMINAL_TITLES = ["MINGW64", "Git Bash", "Command Prompt", "cmd.exe"]

def get_terminal_window():
    """Find the first visible terminal window."""
    for title in TERMINAL_TITLES:
        wins = gw.getWindowsWithTitle(title)
        if wins:
            win = wins[0]
            if not win.isMinimized:
                print(f"[INFO] Found window: {win.title}")
                return win
    print("[WARN] No terminal window detected — capturing full screen.")
    return None

def add_overlay(image_path, label_text):
    """Add timestamp and label overlay to screenshot."""
    image = Image.open(image_path)
    draw = ImageDraw.Draw(image)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    try:
        font = ImageFont.truetype("arial.ttf", 22)
    except:
        font = ImageFont.load_default()

    # Colors
    bg_color = (0, 0, 0, 160)  # semi-transparent black
    text_color = (255, 255, 0)  # yellow text
    label_color = (0, 200, 255)  # cyan label

    # Create text strings
    time_text = f"{timestamp}"
    label = f"Action: {label_text}"

    # Create background rectangle
    draw.rectangle([(10, 10), (500, 80)], fill=bg_color)

    # Draw timestamp and label
    draw.text((20, 20), time_text, font=font, fill=text_color)
    draw.text((20, 50), label, font=font, fill=label_color)

    image.save(image_path)
    print(f"[INFO] Overlay added → {image_path}")

def run_and_capture(command, name, label, delay=3):
    """Run shell command and capture terminal region."""
    print(f"\n[INFO] Running: {label}")
    subprocess.run(command, shell=True)
    time.sleep(delay)

    win = get_terminal_window()
    timestamp = datetime.now().strftime("%H%M%S")
    filename = f"{SAVE_DIR}/{name}_{timestamp}.png"

    if win:
        region = (win.left, win.top, win.width, win.height)
        image = pyautogui.screenshot(region=region)
    else:
        image = pyautogui.screenshot()

    image.save(filename)
    add_overlay(filename, label)
    print(f"[OK] Screenshot saved → {filename}")

# === Run and Capture Screens ===
run_and_capture(
    'bash -c "clear; ./backup.sh --dry-run /c/Users/Rahul\\\\ Sayya/Bash-practice/test_data"',
    "dry_run",
    "Dry Run Mode",
    3
)

run_and_capture(
    'bash -c "clear; ./backup.sh /c/Users/Rahul\\\\ Sayya/Bash-practice/test_data"',
    "real_backup",
    "Real Backup Execution",
    4
)

run_and_capture(
    'bash -c "clear; ls -lh backups/"',
    "backups_folder",
    "Backups Folder Listing",
    2
)

run_and_capture(
    'bash -c "clear; ls -lh logs/"',
    "logs_folder",
    "Logs Folder View",
    2
)

print("\n✅ All screenshots captured with timestamp and labels successfully!")




