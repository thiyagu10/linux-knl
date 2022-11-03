#! /bin/bash
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i '/PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo timedatectl set-timezone Asia/Kolkata
sudo apt update -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager vim  -y
sudo apt-get install build-essential libncurses5-dev libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y

cat - > /root/build-linuxkernel.sh <<'BUILD_BLOCK'
#!/bin/bash
#############################################################################################################
#                               LINUX KERNEL 5.x or 6.x Compile on Ubuntu 20.04
#############################################################################################################

export LOCALREPODIR="/opt/LNXKNL-REPO"
export LNXIMAGEOUT="/opt/netware-1-x86-64"
export LNXKNLBUILD="LNXKNL-BUILD"
export KNL_VER="6.0.6"

export KNLBLDDIR=$HOME/$LNXKNLBUILD
export KNLOUTDIR=$KNLBLDDIR/LNXKNL-TEMP
export MAJOR_VER=$(echo $KNL_VER | cut -d. -f1)
export LNXKNL_URL=https://cdn.kernel.org/pub/linux/kernel/v$MAJOR_VER.x/linux-$KNL_VER.tar.xz

sudo apt update -y
sudo apt install build-essential libncurses5-dev libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y

if [ -d $LOCALREPODIR ]
then
        echo "Local Repository directory exist"
else
        echo "Local Repository directory doesn't exist. Creating it"
        mkdir -pv $LOCALREPODIR
fi

if [ -d $LNXIMAGEOUT ]
then
        echo "Final Bootable Image Directory exist"
else
        echo "Final Bootable Image Directory doesn't exist. Creating it"
        mkdir -pv $LNXIMAGEOUT
fi

mkdir -pv $KNLBLDDIR
mkdir -pv $KNLOUTDIR
cd $KNLBLDDIR

if [ -f "$LOCALREPODIR/linux-${KNL_VER}.tar.xz" ]
then
        echo "linux-${KNL_VER}.tar.xz archive is available on local repo"
        cp $LOCALREPODIR/linux-${KNL_VER}.tar.xz $KNLBLDDIR
else
        echo "linux-${KNL_VER}.tar.xz archive is not available on local repository. Downloading it from https://www.kernel.org/"
        wget $LNXKNL_URL
        cp linux-${KNL_VER}.tar.xz $LOCALREPODIR
fi

tar -xvf $KNLBLDDIR/linux-${KNL_VER}.tar.xz
cd $KNLBLDDIR/linux-${KNL_VER}/
make x86_64_defconfig
make -j $(nproc)

# x86_64 Image will be aviable on $KNLBLDDIR/linux-{x.y.z}/arch/x86/boot/bzImage
cp $KNLBLDDIR/linux-${KNL_VER}/arch/x86/boot/bzImage $LNXIMAGEOUT/vmlinuz-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/System.map $LNXIMAGEOUT/System.map-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/.config $LNXIMAGEOUT/config-${KNL_VER}-generic

##########################################################################################
#                          INITRAMFS - BUSYBOX-1.34.1
##########################################################################################

export IRAMFSBUILD="RFS-BUILD"
export IRAMFSOUT="RFS-OUT"

export RFSBUILD=$HOME/$IRAMFSBUILD
export BBOX_VER=1.34.1

if [ -d "$LNXIMAGEOUT" ]
then
    echo "Directory $LNXIMAGEOUT exist. CONTINUE with this one"
else
   echo "Creating the XNETOS Directory"
   mkdir -pv $LNXIMAGEOUT
fi

if [ -d "$LOCALREPODIR" ]
then
    echo "Directory $LOCALREPODIR exist. CONTINUE with this one"
else
    echo "Creating the Local Repo Directory"
    mkdir -pv $LOCALREPODIR
fi

if [ -d "$RFSBUILD" ]
then
    echo "Directory $rfsbuilddir Exist. Recreating it"
    rm -rf $RFSBUILD
    mkdir -pv $RFSBUILD/$RFSOPT
    echo "Base Dirtectories Created"
else
    mkdir -pv $RFSBUILD/$RFSOPT
    echo "Base Dirtectories Created"
fi
# Base Directories Created.

cd $RFSBUILD
if [ -f "$LOCALREPODIR/busybox-${BBOX_VER}.tar.bz2" ]
then
    echo "busybox-${BBOX_VER}.tar.bz2 is found on $LOCALREPODIR. Using it to Local Repo"
    cp $LOCALREPODIR/busybox-${BBOX_VER}.tar.bz2 $RFSBUILD
else
    echo "busybox-${BBOX_VER}.tar.bz2 is not found on $LOCALREPODIR. Downloading it from Cloud Repo: https://busybox.net"
    wget https://busybox.net/downloads/busybox-${BBOX_VER}.tar.bz2
    cp busybox-${BBOX_VER}.tar.bz2 $LOCALREPODIR
fi

tar -xvf busybox-${BBOX_VER}.tar.bz2
cd busybox-${BBOX_VER}/
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
    cp $RFSBUILD/$RFSOPT/initramfs.cpio.gz $LNXIMAGEOUT/initramfs-${KNL_VER}-generic
else
    echo "PROBLEM in generating the INITRAMFS"
fi

#############################################################################################################
BUILD_BLOCK
chmod +x /root/build-linuxkernel.sh
