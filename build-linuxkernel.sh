#!/bin/bash
#############################################################################################################
#                               LINUX KERNEL 5.x or 6.x Compile on Ubuntu 20.04                             
#############################################################################################################
helpFunction()
{
   echo ""
   echo "Usage: $0 -d parameterA -v parameterB -r parameterC"
   echo -e "\t-d Enter the Linux Kernel Build Directory [e.g. LXKNL-BUILD]"
   echo -e "\t-v Enter the Linux Kernel Version. [e.g. 6.0]"
   echo -e "\t-r Enter the Linux Kernel Local Repo. [e.g. /opt/LXKNL-REPO]"
   exit 1 # Exit script after printing help
}
while getopts ":d:v:r:" flags
do
   case "$flags" in
      d )lxknlblddir=${OPTARG};;
      v )lxkversion=${OPTARG};;
      r )localrepo=${OPTARG};;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done
# Print helpFunction in case parameters are empty
if [ -z "$lxknlblddir" ] || [ -z "$lxkversion" ] || [ -z "$localrepo" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi
KNLBLDDIR=$HOME/$lxknlblddir
KNLOUTDIR=/opt/netware-1-x86-64
LOCALREPODIR=$localrepo
KNL_VER=$lxkversion
MAJOR_VER=6
LNXKNL_URL='https://cdn.kernel.org/pub/linux/kernel/v'$MAJOR_VER'.x/linux-'$KNL_VER'.tar.xz'
echo "Linux Kernel will be downloaded from $LNXKNL_URL"
sudo apt update -y
sudo apt-get install build-essential libncurses5-dev libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y
mkdir -pv $KNLBLDDIR
mkdir -pv $KNLOUTDIR
if [ -d $LOCALREPODIR ]
then
	echo "Local Repository directory exist"
else
	echo "Local Repository directory doesn't exist. Creating it"
	mkdir -p $LOCALREPODIR
fi
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
cp $KNLBLDDIR/linux-${KNL_VER}/arch/x86/boot/bzImage $KNLOUTDIR/vmlinuz-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/System.map $KNLOUTDIR/System.map-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/.config $KNLOUTDIR/config-${KNL_VER}-generic
#############################################################################################################
