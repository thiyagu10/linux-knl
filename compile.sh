++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+              LINUX KERNEL COMPILING                                          +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y


wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.7.tar.xz
tar -xvf linux-5.15.7.tar.xz
sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev
sudo apt-get install build-essential linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison libncurses-dev
cd linux-5.15.7
make x86_64_defconfig
make -j $(nproc)
file vmlinux
ls -lh arch/x86/boot/bzImage

### Creating initram File System
mkinitramfs -o initrd.img
mkdir -p vfs
cd vfs
zcat initrd.img | cpio -idmv

### Creating Block Device with 256 MB and mount it on /mnt
dd if=/dev/zero of=hdadisk.img bs=4096 count=65536
mkfs.ext4 hdadisk.img
mount hdadisk.img /mnt -t ext4
mount -l

cp -rf /opt/ramhdd/vfs/* /mnt
mkdir /mnt/sys /mnt/proc /mnt/dev

### Create init file in sbin

umount /mnt
### Boot the created linux kernel and initramfs on HDD
qemu-system-x86_64  -nographic -no-reboot -kernel /opt/bzImage -m 256 -initrd /opt/ramhdd/initrd.img -hdd /opt/ramhdd/hdadisk.img -append "root=/dev/sda panic=10 console=ttyS0,115200"

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
