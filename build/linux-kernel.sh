#!/bin/bash
#############################################################################################################
#                               LINUX KERNEL 5.x or 6.x Compile on Ubuntu 20.04
#############################################################################################################

export KNLBLDDIR=$HOME/$LNXKNLBUILD
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
tar -xf $KNLBLDDIR/linux-${KNL_VER}.tar.xz
cd $KNLBLDDIR/linux-${KNL_VER}/
make x86_64_defconfig
make -j $(nproc)
# x86_64 Image will be aviable on $KNLBLDDIR/linux-{x.y.z}/arch/x86/boot/bzImage
cp $KNLBLDDIR/linux-${KNL_VER}/arch/x86/boot/bzImage $LNXIMAGEOUT/vmlinuz-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/System.map $LNXIMAGEOUT/System.map-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/.config $LNXIMAGEOUT/config-${KNL_VER}-generic
