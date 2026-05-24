#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Android-x86 + VNC Auto Installer${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root!${NC}"
  exit 1
fi

# Step 1: Download Android-x86
echo -e "${YELLOW}[1/5] Downloading Android-x86 9.0...${NC}"
wget -O /tmp/android.iso https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download

# Step 2: Install dependencies
echo -e "${YELLOW}[2/5] Installing dependencies...${NC}"
apt update && apt install -y grub2 xorriso wget

# Step 3: Format disk
echo -e "${YELLOW}[3/5] Formatting disk...${NC}"
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary ext4 1MiB 100%
mkfs.ext4 /dev/sda1

# Step 4: Install Android
echo -e "${YELLOW}[4/5] Installing Android to disk...${NC}"
mkdir -p /mnt/android
mount /dev/sda1 /mnt/android
mount -o loop /tmp/android.iso /mnt/iso
cp -r /mnt/iso/* /mnt/android/
umount /mnt/iso

# Install GRUB bootloader
grub-install --target=i386-pc /dev/sda
update-grub

# Step 5: Install VNC server
echo -e "${YELLOW}[5/5] Installing VNC server...${NC}"
apt install -y tightvncserver xfce4 xfce4-goodies

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}After reboot:${NC}"
echo -e "1. Type: ${GREEN}reboot${NC}"
echo -e "2. Wait 2-3 mins for Android to boot"
echo -e "3. Boot again to Rescue Mode"
echo -e "4. Run: ${GREEN}vncserver :1 -geometry 1280x720 -depth 24${NC}"
echo -e "5. Open RealVNC app → ${GREEN}[IP]:5901${NC}"
echo -e "6. Password: ${GREEN}12345678${NC}"
