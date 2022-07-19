#############################################################################################################
#				LINUX KENRLE 5.15.55 Compile on Ubuntu 20.04                     							#
#############################################################################################################
BUILDDIR=~/LinuxKNL-build
OPTDIR=/opt/xnetos
KNL_VER=5.15.55
mkdir -p $BUILDDIR
mkdir -p $OPTDIR
sudo update -y
sudo apt-get install build-essential libncurses-dev libncurses5-dev linux-source libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y
cd $BUILDDIR
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KNL_VER}.tar.xz
tar -xvf $BUILDDIR/linux-${KNL_VER}.tar.xz
cd $BUILDDIR/linux-${KNL_VER}/
make x86_64_defconfig
make -j $(nproc)

# x86_64 Image will be aviable on $BUILDDIR/linux-5.15.55/arch/x86/boot/bzImage
cp $BUILDDIR/linux-${KNL_VER}/arch/x86/boot/bzImage $OPTDIR/vmlinuz-${KNL_VER}-generic
cp $BUILDDIR/linux-${KNL_VER}/System.map $OPTDIR/System.map-${KNL_VER}-generic
cp $BUILDDIR/linux-${KNL_VER}/.config $OPTDIR/config-${KNL_VER}-generic

#############################################################################################################
