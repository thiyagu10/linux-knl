#############################################################################################################
#                               LINUX KERNEL 5.x or 6.x Compile on Ubuntu 20.04                                                                         #
#############################################################################################################

echo "Enter the Linux Kernel Build Directory [e.g. LXKNL-BUILD] "
read lxknlblddir

echo "Enter the Linux Kernel Version. [e.g. 5.15.55]"
read lxkversion

echo "Enter the Linux Kernel Local Repo. [e.g. /opt/LXKNL-REPO]"
read localrepo

KNLBLDDIR=$HOME/$lxknlblddir
KNLOUTDIR=$KNLBLDDIR/LXKNL-OUT
LOCALREPODIR=$localrepo
KNL_VER=$lxkversion
MAJOR_VER=$( echo "$KNL_VER" |cut -d\. -f1 )
LNXKNL_URL='https://cdn.kernel.org/pub/linux/kernel/v'$MAJOR_VER'.x/linux-'$KNL_VER'.tar.xz'
sudo apt update -y
sudo apt-get install build-essential libncurses-dev libncurses5-dev linux-source libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y
mkdir -p $KNLBLDDIR
mkdir -p $KNLOUTDIR

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
