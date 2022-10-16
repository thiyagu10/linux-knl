#! /bin/bash
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i '/PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo timedatectl set-timezone Asia/Kolkata
sudo apt update -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager vim  -y
sudo apt-get install build-essential libncurses5-dev libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y

cat - > /root/build-linuxkernel.sh <<'EOF'
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
KNLOUTDIR=$KNLBLDDIR/LXKNL-OUT
LOCALREPODIR=$localrepo
KNL_VER=$lxkversion
MAJOR_VER=6
LNXKNL_URL='https://cdn.kernel.org/pub/linux/kernel/v'$MAJOR_VER'.x/linux-'$KNL_VER'.tar.xz'
echo "Linux Kernel will be downloaded from $LNXKNL_URL"
sudo apt update -y
sudo apt-get install build-essential libncurses5-dev libssl-dev libelf-dev bison flex bc kmod cpio dwarves -y
sudo apt install wget htop qemu-system libvirt-clients libvirt-daemon-system virt-manager -y
mkdir -p $KNLBLDDIR
mkdir -p $KNLOUTDIR
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
EOF
chmod +x /root/build-linuxkernel.sh
####./build-linuxkernel.sh -d LXKNL-BUILD -v 6.0 -r /opt/LXKNL-REPO

cat - > /root/create_initramfs.sh <<'EOF'
##########################################################################################
#                          INITRAMFS - BUSYBOX-1.34.1
##########################################################################################

echo "Enter the INITRAMFS Build Directory [e.g. D10-BUILD] "
read rfsbuilddir

echo "Enter the INITRAMFS Output Directory  [e.g. D10-RFS]"
read rfsoptdir

echo "Enter the INITRAMFS BusyBOX version. [e.g. 1.34.1]"
read bboxversion

XNETOS_BUILD=/opt/XNETOS
KNL_VER=5.15.55

sudo apt-get install libncurses5-dev -y
if [ -d "$XNETOS_BUILD" ]
then
    echo "Directory exist. CONTINUE with this one"
else
   echo "Creating the XNETOS Directory"
   mkdir -pv $XNETOS_BUILD
fi
if [ -n "$rfsbuilddir" -a -n "$rfsoptdir" ]
then
    RFSBUILD=$HOME/$rfsbuilddir
    RFSOPT=$RFSBUILD/$rfsoptdir
    mkdir -p $RFSBUILD
    cd $RFSBUILD
    if [ -f "/opt/LXKNL-REPO/busybox-${bboxversion}.tar.bz2" ]
    then
        echo "busybox-${bboxversion}.tar.bz2 is found on /opt/LXKNL-REPO. Using it to Local Repo"
        cp /opt/LXKNL-REPO/busybox-${bboxversion}.tar.bz2 $RFSBUILD
    else
        echo "busybox-${bboxversion}.tar.bz2 is not found on /opt/LXKNL-REPO. Downloading it from Cloud Repo: https://busybox.net"
        wget https://busybox.net/downloads/busybox-${bboxversion}.tar.bz2
    fi
    tar -xvf busybox-${bboxversion}.tar.bz2
    cd busybox-${bboxversion}/
    mkdir -pv $RFSOPT/obj/busybox-x86
    make O=$RFSOPT/obj/busybox-x86 defconfig
    make O=$RFSOPT/obj/busybox-x86 menuconfig
    cd $RFSOPT/obj/busybox-x86
    make -j $(nproc)
    make install
    mkdir -pv $RFSOPT/initramfs/x86-busybox
    cd $RFSOPT/initramfs/x86-busybox
    mkdir -pv {bin,dev,sbin,etc/network,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root,var/{run,log},opt}
    cp -av $RFSOPT/obj/busybox-x86/_install/*   $RFSOPT/initramfs/x86-busybox
    cp -av /dev/{null,console,tty,ttyS0,sda1}   $RFSOPT/initramfs/x86-busybox/dev/
# Adding Init File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/init
#! /bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
echo "XNETOS v1.0 is booted succesffully!!!"
exec /bin/sh
EOF
        chmod +x $RFSOPT/initramfs/x86-busybox/init
# Adding HOSTNAME File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/etc/hostname
XNETOS-1.0
EOF

# Adding HOSTS File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/etc/hosts
127.0.0.1       localhost
127.0.1.1       XNETOS-1.0
EOF

# Adding Network Interfaces File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF

# Adding TimeZone File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/etc/timezone
Asia/Kolkata
EOF

# Adding TimeZone File
cat <<EOF | sudo tee $RFSOPT/initramfs/x86-busybox/etc/os-release
NAME="XNETOS"
ID=xnetos
VERSION_ID=1.0
PRETTY_NAME="XNETOS v1.0"
HOME_URL="https://www.xnetworks.com/xnetos"
BUG_REPORT_URL="https://www.xnetworks.com/xnetos/bugs"
PRIVACY_POLICY_URL="https://www.xnetworks.com/xnetos/legel/terms-and-conditions/privacy-policy"
VERSION_CODENAME=0x00000B85
EOF
        cd $RFSOPT/initramfs/x86-busybox/
        find . | cpio -H newc -o > ../initramfs.cpio
        cd ..
        cat initramfs.cpio | gzip > $RFSOPT/obj/initramfs.cpio.gz
        if [ -f "$RFSOPT/obj/initramfs.cpio.gz" ]
        then
                echo "INITRAMFS is generated and readily available on $RFSOPT/obj/initramfs.cpio.gz"
                cp $RFSOPT/obj/initramfs.cpio.gz        $XNETOS_BUILD/initramfs-${KNL_VER}-generic
        else
                echo "PROBLEM in generating the INITRAMFS"
        fi
else
        echo "Input the correct directory to continue the INITRAMFS BUILD. Please rerun the script"
fi
##########################################################################################
EOF
chmod +x /root/create_initramfs.sh
