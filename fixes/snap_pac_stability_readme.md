# 🛡️ Protecting Your Arch/Omarchy System with `snap-pac` + Snapper

Arch-based systems like **Omarchy** are powerful and flexible, but rolling updates can sometimes introduce breaking changes — especially to core packages, kernels, or graphics drivers.

`**snap-pac**` is a small but critical tool that helps make your system more **resilient** by integrating with **Snapper** to automatically take **Btrfs snapshots** before and after every package transaction.

With this setup, you have a built-in safety net: if an update goes wrong, you can quickly roll back to the last working system state.

---

## 🔍 How `snap-pac` Works

When you run any Pacman command that installs, upgrades, or removes packages — for example:

```bash
sudo pacman -Syu
```

`snap-pac` automatically:

1. **Creates a pre-transaction snapshot** — a read-only snapshot of your entire root subvolume (`/`) before any changes are applied.
2. **Runs your package operation** — installs, updates, or removes packages.
3. **Creates a post-transaction snapshot** — showing the state immediately after the changes.

These snapshots are managed by **Snapper**, and appear in your snapshot list:

```bash
sudo snapper -c root list
```

Example:

```
 # | Type  | Pre # | Date        | Description
---+-------+-------+-------------+-------------------------
 1 | pre   |       | 2025-08-10  | pacman -Syu
 2 | post  |     1 | 2025-08-10  | pacman -Syu
```

---

## 🛡 Why This Makes Your System Safer

- **Instant Rollback Point** — If an update breaks your desktop, drivers, or kernel, you can boot back into the *pre-update* snapshot.
- **Minimal Downtime** — Snapshots are instant (Btrfs copy-on-write) and don’t consume space until files change.
- **Automated Protection** — No need to remember to create backups before updates — it happens automatically.
- **Timeline Support** — Combined with `snapper-timeline.timer`, you also get hourly/daily snapshots outside of Pacman transactions.

---

## ⏪ How to Roll Back After a Bad Update

> **Scenario:** You run `sudo pacman -Syu`, reboot, and now your system won’t start Hyprland or even log in.

### 1. Identify the last good snapshot

Boot into a working environment (live USB or TTY) and run:

```bash
sudo snapper -c root list
```

Find the **pre-update snapshot** just before the problematic update.

### 2. Roll back to that snapshot

From the working environment:

```bash
sudo snapper -c root rollback <snapshot-ID>
```

This replaces your active root subvolume (`@`) with the contents of the chosen snapshot.

### 3. Reboot

```bash
sudo reboot
```

Your system will now boot as it was at the moment of that snapshot.

---

## ⚡ Tips for Best Results

- Keep `` installed and up to date.
- Ensure `` and `` are enabled:
  ```bash
  sudo systemctl enable --now snapper-timeline.timer
  sudo systemctl enable --now snapper-cleanup.timer
  ```
- Check snapshots periodically:
  ```bash
  sudo snapper -c root list
  ```
- Clean up old snapshots automatically with Snapper’s `NUMBER_LIMIT` and `TIMELINE_LIMIT_*` settings in `/etc/snapper/configs/root`.

---

## ✅ Summary

With `snap-pac` + Snapper + Btrfs, your Arch-based Omarchy system gains a **built-in time machine** for every system change. This makes updates far less risky — and gives you the confidence to update regularly without fear of unrecoverable breakage.

