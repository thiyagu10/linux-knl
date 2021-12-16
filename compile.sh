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

qemu-system-x86_64  -nographic -no-reboot -kernel arch/x86/boot/bzImage -initrd vmlinux -append "panic=10 console=ttyS0,115200"

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
