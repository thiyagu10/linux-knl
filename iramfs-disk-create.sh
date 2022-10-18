##########################################################################################
#                          INITRAMFS - BUSYBOX-1.34.1 and QCOW2 DISK Creation
##########################################################################################

helpFunction()
{
   echo ""
   echo "Usage: $0 -d parameterA -v parameterB -r parameterC"
   echo -e "\t-d Enter the INITRAMFS Build Directory [e.g. RFS-BUILD]"
   echo -e "\t-v Enter the BusyBOX Version. [e.g. 1.34.1]"
   echo -e "\t-r Enter the Local Repo. [e.g. /opt/LXKNL-REPO]"
   exit 1 # Exit script after printing help
}
while getopts ":d:v:r:" flags
do
   case "$flags" in
      d )rfsbuilddir=${OPTARG};;
      v )bboxversion=${OPTARG};;
      r )localrepo=${OPTARG};;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done
# Print helpFunction in case parameters are empty
if [ -z "$rfsbuilddir" ] || [ -z "$bboxversion" ] || [ -z "$localrepo" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

NETWARE_BUILD=/opt/netware-1-x86-64
KNL_VER=6.0.2
RFSBUILD=$HOME/$rfsbuilddir
RFSOPT=RFS-OUT

sudo apt-get install libncurses5-dev -y
if [ -d "$NETWARE_BUILD" ]
then
    echo "Directory $NETWARE_BUILD exist. CONTINUE with this one"
else
   echo "Creating the XNETOS Directory"
   mkdir -pv $NETWARE_BUILD
fi

if [ -d "$localrepo" ]
then
    echo "Directory $localrepo exist. CONTINUE with this one"
else
    echo "Creating the Local Repo Directory"
    mkdir -pv $localrepo
fi

if [ -d "$rfsbuilddir" ]
then
    echo "Directory $rfsbuilddir Exist. Recreating it"
    rm -rf $RFSBUILD
    mkdir -pv $RFSBUILD/$RFSOPT
    echo "Base Dirtectories Created"
else
    mkdir -pv $RFSBUILD/$RFSOPT
    echo "Base Dirtectories Created"
fi
# Base Difrectories Created.

cd $RFSBUILD
if [ -f "$localrepo/busybox-${bboxversion}.tar.bz2" ]
then
    echo "busybox-${bboxversion}.tar.bz2 is found on $localrepo. Using it to Local Repo"
    cp $localrepo/busybox-${bboxversion}.tar.bz2 $RFSBUILD
else
    echo "busybox-${bboxversion}.tar.bz2 is not found on /opt/LXKNL-REPO. Downloading it from Cloud Repo: https://busybox.net"
    wget https://busybox.net/downloads/busybox-${bboxversion}.tar.bz2
    cp busybox-${bboxversion}.tar.bz2 $localrepo
fi

tar -xvf busybox-${bboxversion}.tar.bz2
cd busybox-${bboxversion}/
mkdir -pv $RFSBUILD/$RFSOPT/busybox-x86
make O=$RFSBUILD/$RFSOPT/busybox-x86 defconfig
make O=$RFSBUILD/$RFSOPT/busybox-x86 menuconfig

cd $RFSBUILD/$RFSOPT/busybox-x86
make -j $(nproc)
make install
mkdir -pv $RFSBUILD/$RFSOPT/initramfs/x86-busybox
cd $RFSBUILD/$RFSOPT/initramfs/x86-busybox
mkdir -pv {bin,boot,dev,sbin,etc/network,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root,var/{run,log},opt}
cp -av $RFSBUILD/$RFSOPT/busybox-x86/_install/*   $RFSBUILD/$RFSOPT/initramfs/x86-busybox
cp -av /dev/{null,console,tty,ttyS0,sda1}   $RFSBUILD/$RFSOPT/initramfs/x86-busybox/dev/

# Adding Init File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/init
#! /bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t ext4 NETWARE-1-0_x86-64 /
echo "NETWARE v1.0 is booted succesffully!!!"
exec /bin/sh
EOF
chmod +x $RFSBUILD/$RFSOPT/initramfs/x86-busybox/init

# Adding HOSTNAME File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/hostname
NETWARE-1-0
EOF

# Adding HOSTS File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/hosts
127.0.0.1       localhost
127.0.1.1       NETWARE-1-0
EOF

# Adding Network Interfaces File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

# Adding TimeZone File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/timezone
Asia/Kolkata
EOF

# Adding TimeZone File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/os-release
NAME="NETWARE"
ID=NETWARE
VERSION_ID=1.0
PRETTY_NAME="NETWARE v1.0"
VERSION_CODENAME=0x00000B85
EOF
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/fstab
LABEL=NETWARE-1-0_x86-64   /        ext4   defaults        0 1
EOF

cd $RFSBUILD/$RFSOPT/initramfs/x86-busybox/
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > $RFSBUILD/$RFSOPT/initramfs.cpio.gz
if [ -f "$RFSBUILD/$RFSOPT/initramfs.cpio.gz" ]
then
    echo "INITRAMFS is generated and readily available on $RFSBUILD/$RFSOPT/initramfs.cpio.gz"
    cp $RFSBUILD/$RFSOPT/initramfs.cpio.gz $NETWARE_BUILD/initramfs-${KNL_VER}-generic
else
    echo "PROBLEM in generating the INITRAMFS"
fi

sudo dd if=/dev/zero of=$NETWARE_BUILD/NETWARE-1-0_x86-64.img bs=1M count=256
sudo mkfs -t ext4 $NETWARE_BUILD/NETWARE-1-0_x86-64.img
sudo mkdir -p /mnt/VHD/
sudo mount -t auto -o loop $NETWARE_BUILD/NETWARE-1-0_x86-64.img /mnt/VHD/
sudo mkdir -p /mnt/VHD/boot
cp -rf $RFSBUILD/$RFSOPT/initramfs/x86-busybox/* /mnt/VHD/
cp $NETWARE_BUILD/initramfs-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/vmlinuz-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/config-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/System.map-${KNL_VER}-generic /mnt/VHD/boot/
sudo umount /mnt/VHD/
