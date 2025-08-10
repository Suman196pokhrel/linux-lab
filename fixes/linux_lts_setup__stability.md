# 🌟 Switching to LTS Kernel on Arch/Omarchy

> **Why LTS?**\
> The **Linux LTS (Long-Term Support)** kernel offers rock-solid stability, fewer regressions, and consistent performance over time — ideal for a reliable daily driver.

---

## 🎯 Benefits of LTS

- 🛡 **Stability** — less churn than mainline; fewer breaking changes.
- 📅 **Predictable updates** — slower-moving, well-tested patches.
- 🔧 **Compatibility** — fewer driver/module breakages.
- 🔒 **Security** — critical patches without risky experimental features.

---

## 📦 Step 1: Install the LTS Kernel

```bash
sudo pacman -S linux-lts linux-lts-headers
```

💡 *Keep your mainline kernel installed as a fallback for hardware testing.*

---

## 📝 Step 2: Create a systemd-boot Entry for LTS

List boot entries:

```bash
ls /boot/loader/entries
```

Identify your main entry (e.g., `arch.conf` or `*_linux.conf`).

Copy it:

```bash
sudo cp /boot/loader/entries/<main_entry_file> /boot/loader/entries/arch-lts.conf
```

Edit:

```bash
sudo nano /boot/loader/entries/arch-lts.conf
```

**Changes:**

- ✏ **title** → `Arch Linux (LTS)`
- 🖥 **linux** → `/vmlinuz-linux-lts`
- 📦 **initramfs** → `/initramfs-linux-lts.img`
- 🔑 Keep your `cryptdevice`, `root`, and `rootflags` options unchanged.
- ⚡ Keep microcode line (e.g., `/amd-ucode.img` or `/intel-ucode.img`) **above** initramfs.

---

## ⚙ Step 3: Make LTS the Default Kernel

Edit loader config:

```bash
sudo nano /boot/loader/loader.conf
```

Add or update:

```
default arch-lts.conf
```

Update systemd-boot:

```bash
sudo bootctl update
```

---

## 🔄 Step 4: Reboot & Verify

Reboot, then run:

```bash
uname -r
```

You should see something like:

```
6.x.x-lts
```

Check bootloader default:

```bash
bootctl list
```

The LTS entry should have a `*`.

---

## 💡 Pro Tips

- 🖥 Keep **two kernels**: LTS (default) + mainline (optional) for testing.
- 🔄 Create a fallback LTS entry by copying `arch-lts.conf` → `arch-lts-fallback.conf` and setting initramfs to `/initramfs-linux-lts-fallback.img`.
- 🛡 Pair LTS with **snap-pac + Snapper** for maximum stability *and* rollback protection.

✅ *Enjoy a stable Arch system while keeping the option to explore new features on mainline.*

