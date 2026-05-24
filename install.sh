#!/bin/bash
# Android-x86 Auto Installer
# Gaya ng bin456 style!

ISO_URL="https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download"
DISK="/dev/sda"

echo "📥 Downloading Android-x86 ISO..."
wget -O /tmp/android.iso $ISO_URL

echo "💾 Preparing disk..."
# I-unmount muna lahat
umount /dev/sda1 /dev/sda14 /dev/sda15 /dev/sda16 2>/dev/null
swapoff /dev/sda15 2>/dev/null

# I-delete lahat ng partitions
for i in 1 14 15 16; do
    echo -e "d\n$i\n" | fdisk $DISK 2>/dev/null
done
echo -e "d\nw\n" | fdisk $DISK 2>/dev/null

# Gumawa ng bagong partition
echo -e "n\np\n1\n\n\n\na\nw\n" | fdisk $DISK

echo "🔨 Formatting..."
mkfs.ext4 -F ${DISK}1

echo "📂 Installing Android..."
mkdir -p /mnt/iso /mnt/target
mount -o loop /tmp/android.iso /mnt/iso
mount ${DISK}1 /mnt/target
cp -r /mnt/iso/* /mnt/target/

echo "🔧 Installing GRUB..."
mount --bind /dev /mnt/target/dev
mount --bind /proc /mnt/target/proc
mount --bind /sys /mnt/target/sys
chroot /mnt/target /bin/bash -c "grub-install $DISK && update-grub"

echo "🧹 Cleaning up..."
umount /mnt/target/dev /mnt/target/proc /mnt/target/sys /mnt/target /mnt/iso

echo "✅ Android-x86 installed! Rebooting..."
reboot
