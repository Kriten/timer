# Task Timer

A PowerShell GUI app for tracking time across multiple tasks. Features a dark-themed interface with per-task start/stop/reset controls and a running total.

## Screenshot / Layout

```
┌─────────────────────────────────────────────────────┐
│  TASK TIMER                                         │
│  ┌──────────────────────────────────────────────┐   │
│  │ Task 1              00:12:34   [Start] [Reset]│   │
│  ├──────────────────────────────────────────────┤   │
│  │ Task 2              00:00:00   [Start] [Reset]│   │
│  ├──────────────────────────────────────────────┤   │
│  │ Task 3              00:00:00   [Start] [Reset]│   │
│  ├──────────────────────────────────────────────┤   │
│  │ Task 4              00:00:00   [Start] [Reset]│   │
│  ├──────────────────────────────────────────────┤   │
│  │ Task 5              00:00:00   [Start] [Reset]│   │
│  └──────────────────────────────────────────────┘   │
│  Total: 00:12:34              [Stop All] [Reset All] │
└─────────────────────────────────────────────────────┘
```

## Features

- 5 named task rows, each with an independent timer (HH:MM:SS)
- Only one task runs at a time — starting a new task auto-stops the current one
- Running task row highlights green
- Double-click a task name to rename it; confirm with **Enter**, cancel with **Escape**
- **Stop All** — stops all running timers at once
- **Reset All** — resets all timers (with confirmation dialog)
- Live total across all tasks
- Fixed-size dark-themed window (no resize/maximize)

## Requirements

- **Windows** — the app uses Windows Forms (`System.Windows.Forms`), which requires a Windows environment
- **PowerShell** 5.1+ (included with Windows 10/11) or PowerShell 7+

## Running

```powershell
powershell -ExecutionPolicy Bypass -File TaskTimer.ps1
```

Or from within a PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\TaskTimer.ps1
```

---

## Installing PowerShell on Ubuntu / Debian

> **Note:** The Task Timer GUI requires Windows. These instructions are for setting up PowerShell on Ubuntu/Debian for scripting or development purposes.

### Ubuntu

```bash
# 1. Install prerequisites
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

# 2. Download the Microsoft package repository config
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

# 3. Register the repository
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# 4. Install PowerShell
sudo apt-get update
sudo apt-get install -y powershell
```

### Debian

```bash
# 1. Install prerequisites
sudo apt-get update
sudo apt-get install -y curl gnupg apt-transport-https

# 2. Import Microsoft's GPG key
curl https://packages.microsoft.com/keys/microsoft.asc | \
  sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg

# 3. Add the Microsoft repository
# Replace "bookworm" with your Debian codename (bookworm, bullseye, buster, etc.)
DEBIAN_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-${DEBIAN_CODENAME}-prod ${DEBIAN_CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/microsoft.list

# 4. Install PowerShell
sudo apt-get update
sudo apt-get install -y powershell
```

### Verify the installation

```bash
pwsh --version
```

### Launch PowerShell

```bash
pwsh
```
