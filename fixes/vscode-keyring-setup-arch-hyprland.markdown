# 🛠️ Fixing VS Code "OS Keyring Couldn't Be Identified" on Omarchy with Hyprland

Welcome to this guide! If you're using **Omarchy** (an Arch-based distro) with **Hyprland** as your window manager and logging in via TTY (no display manager), you might have seen Visual Studio Code (VS Code) complain about the "OS keyring couldn’t be identified" and suggest weaker encryption. 😕 No worries—this guide will walk you through fixing it step-by-step so VS Code can store credentials securely. Let’s get started! 🚀

## 📋 Prerequisites
- You're running **Omarchy** (or another Arch-based distro) with **Hyprland**.
- You log in via **TTY** and manually start Hyprland (no display manager like GDM or SDDM).
- You’ve installed **visual-studio-code-bin** from Chaotic-AUR.
- You have `sudo` privileges and basic familiarity with the terminal.

## 🛠️ Step-by-Step Fix

### 1. Install Required Packages 📦
First, we need to install the tools to manage a secure keyring: `gnome-keyring`, `libsecret`, and `seahorse`.

```bash
sudo pacman -S gnome-keyring libsecret seahorse
```

**Why?**
- `gnome-keyring`: Provides a secure storage system for passwords and credentials.
- `libsecret`: A library that lets apps like VS Code interact with the keyring.
- `seahorse`: A GUI tool to manage keyrings (optional but helpful for setting things up).

This ensures VS Code can use a keyring to store sensitive data securely.

### 2. Configure PAM for Automatic Keyring Unlocking 🔓
We’ll modify the system’s PAM (Pluggable Authentication Module) configuration to unlock the keyring automatically when you log in.

Edit the `/etc/pam.d/system-login` file with your preferred editor (e.g., `nano` or `vim`):

```bash
sudo nano /etc/pam.d/system-login
```

Add these lines in the appropriate sections:

```text
auth       optional  pam_gnome_keyring.so
session    optional  pam_gnome_keyring.so auto_start
```

- Add the `auth` line to the **auth** section (look for other `auth` lines).
- Add the `session` line to the **session** section (look for other `session` lines).

**Why?**
- `pam_gnome_keyring.so` in the `auth` section links your login password to the keyring.
- The `session` section with `auto_start` ensures the keyring is initialized and unlocked when you log in.
- This setup mimics how display managers (like GDM) handle keyring unlocking, which we need since we’re using TTY.

Save the file and exit (`Ctrl+O`, `Enter`, `Ctrl+X` for `nano`).

### 3. Create and Configure a Keyring with Seahorse 🐠
Now, we’ll use Seahorse to create a keyring named `Login` and set it as the default, with a password matching your Linux user password.

Run Seahorse:

```bash
seahorse
```

In the Seahorse GUI:
1. Click **File > New**.
2. Select **Password Keyring**.
3. Name it `Login` (case-sensitive, must be exact).
4. Set the password to **match your Linux login password**.
5. Right-click the new `Login` keyring and select **Set as default**.
6. Close Seahorse.

**Why?**
- VS Code expects a keyring named `Login` to store credentials securely.
- Setting the password to match your login password allows PAM to unlock it automatically.
- Making it the default ensures apps like VS Code use it without extra configuration.

### 4. Reboot the System 🔄
Reboot to apply the PAM changes and ensure the keyring is initialized properly.

```bash
reboot
```

**Why?**
- A reboot ensures the modified PAM configuration takes effect and the keyring is set up correctly for your session.

### 5. Verify the Keyring Setup ✅
After rebooting, let’s confirm the keyring is working and accessible.

Check if the `org.freedesktop.secrets` service is running on D-Bus:

```bash
busctl --user list | grep org.freedesktop.secrets
```

You should see output like:

```text
org.freedesktop.secrets ...
```

**Why?**
- VS Code uses the `org.freedesktop.secrets` D-Bus service (provided by `gnome-keyring`) to access the keyring.
- This confirms the keyring daemon is active.

Test storing and retrieving a secret with `secret-tool`:

```bash
secret-tool store --label="Test Secret" test key
```

Enter a value (e.g., `mysecret`). Then retrieve it:

```bash
secret-tool lookup test key
```

It should return `mysecret` without prompting for a password.

**Why?**
- `secret-tool` interacts with the keyring, simulating how VS Code stores credentials.
- No password prompt means the keyring is unlocked automatically, which is what we want.

### 6. Test VS Code 🎉
Launch VS Code:

```bash
code
```

Try a feature that uses credentials (e.g., signing into a GitHub account via the Git extension). The "OS keyring couldn’t be identified" popup should be gone, and credentials should save securely.

**Why?**
- If everything is set up correctly, VS Code will use the `Login` keyring via `libsecret` and `gnome-keyring`, storing credentials without issues.

## 🧠 How the Fix Works Under the Hood

Here’s a quick rundown of what’s happening:
- **Problem**: VS Code uses `libsecret` to store credentials in a keyring, but Hyprland on Omarchy (with TTY login) doesn’t set up a keyring by default, causing the error.
- **Solution Components**:
  - `gnome-keyring` provides a secure storage backend and the `org.freedesktop.secrets` D-Bus service.
  - `libsecret` is the library VS Code uses to communicate with the keyring.
  - `seahorse` helps us create a `Login` keyring, which VS Code expects.
  - PAM configuration (`pam_gnome_keyring.so`) unlocks the keyring automatically using your login password, mimicking display manager behavior.
- **Result**: When you log in via TTY and start Hyprland, the keyring is initialized and unlocked. VS Code can then use it to store credentials securely, eliminating the weaker encryption popup.

## 🎯 Troubleshooting
- **No `org.freedesktop.secrets` in D-Bus?** Ensure `gnome-keyring` is installed and the PAM configuration is correct. Check for typos in `/etc/pam.d/system-login`.
- **Still getting the popup?** Verify the keyring is named exactly `Login` (case-sensitive) and its password matches your login password.
- **Seahorse not launching?** Ensure you’re running it in a graphical session (after starting Hyprland).
- **Need help?** Check the Arch Wiki on [GNOME Keyring](https://wiki.archlinux.org/title/GNOME/Keyring) or ask in the Omarchy community.

Happy coding! 💻