#############################################################################################################
#				LINUX KENRLE 5.15.55 Compile on Ubuntu 20.04                     							#
#############################################################################################################

echo "Enter the Linux Kernel Build Directory [e.g. LXKNL-BUILD] "
read lxknlblddir

echo "Enter the Linux Kernel Output Directory  [e.g. LXKNL-OUT]"
read lxkoutdir

echo "Enter the Linux Kernel Version. [e.g. 5.15.55]"
read lxkversion

echo "Enter the Linux Kernel Local Repo. [e.g. /opt/LXKNL-REPO]"
read localrepo

KNLBLDDIR=$HOME/$lxknlblddir
KNLOUTDIR=$KNLBLDDIR/$lxkoutdir
LOCALREPODIR=$localrepo
KNL_VER=$lxkversion

sudo update -y
sudo apt-get install build-essential libncurses-dev libncurses5-dev linux-source libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y
mkdir -p $KNLBLDDIR
mkdir -p $KNLOUTDIR

cd $KNLBLDDIR
if [ -f "$LOCALREPODIR/linux-${KNL_VER}.tar.xz" ]
then
	echo "linux-${KNL_VER}.tar.xz archive is available on local repo"
	cp linux-${KNL_VER}.tar.xz $KNLBLDDIR
else
	echo "linux-${KNL_VER}.tar.xz archive is not available on local repo. Downloading it from https://www.kernel.org/"
	wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KNL_VER}.tar.xz
fi	
tar -xvf $KNLBLDDIR/linux-${KNL_VER}.tar.xz
cd $KNLBLDDIR/linux-${KNL_VER}/
make x86_64_defconfig
make -j $(nproc)

# x86_64 Image will be aviable on $KNLBLDDIR/linux-5.15.55/arch/x86/boot/bzImage
cp $KNLBLDDIR/linux-${KNL_VER}/arch/x86/boot/bzImage $KNLOUTDIR/vmlinuz-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/System.map $KNLOUTDIR/System.map-${KNL_VER}-generic
cp $KNLBLDDIR/linux-${KNL_VER}/.config $KNLOUTDIR/config-${KNL_VER}-generic

#############################################################################################################
