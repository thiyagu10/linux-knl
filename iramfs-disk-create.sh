##########################################################################################
#                          INITRAMFS - BUSYBOX-1.34.1 and DISK Creation
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

L17NETOS_BUILD=/opt/l17-netos
KNL_VER=6.0.2
RFSBUILD=$HOME/$rfsbuilddir
RFSOPT=RFS-OUT

#echo "$rfsbuilddir      $bboxversion    $localrepo      $L17NETOS_BUILD $KNL_VER        $RFSBUILD       $RFSOPT"

sudo apt-get install libncurses5-dev -y
if [ -d "$L17NETOS_BUILD" ]
then
    echo "Directory $L17NETOS_BUILD exist. CONTINUE with this one"
else
   echo "Creating the XNETOS Directory"
   mkdir -pv $L17NETOS_BUILD
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
mkdir -pv {bin,dev,sbin,etc/network,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root,var/{run,log},opt}
cp -av $RFSBUILD/$RFSOPT/busybox-x86/_install/*   $RFSBUILD/$RFSOPT/initramfs/x86-busybox
cp -av /dev/{null,console,tty,ttyS0,sda1}   $RFSBUILD/$RFSOPT/initramfs/x86-busybox/dev/
# Adding Init File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/init
#! /bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
echo "L17NETOS v1.0 is booted succesffully!!!"
exec /bin/sh
EOF
chmod +x $RFSBUILD/$RFSOPT/initramfs/x86-busybox/init
# Adding HOSTNAME File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/hostname
L17NETOS-1-0
EOF

# Adding HOSTS File
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/hosts
127.0.0.1       localhost
127.0.1.1       L17NETOS-1-0
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
NAME="L17NETOS"
ID=l17netos
VERSION_ID=1.0
PRETTY_NAME="L17NETOS v1.0"
HOME_URL="https://www.b35networks.com/l17netos"
BUG_REPORT_URL="https://www.b35networks.com/l17netos/bugs"
PRIVACY_POLICY_URL="https://www.b85networks.com/xnetos/legel/terms-and-conditions/privacy-policy"
VERSION_CODENAME=0x00000B85
EOF
cat <<EOF | sudo tee $RFSBUILD/$RFSOPT/initramfs/x86-busybox/etc/fstab
LABEL=l17nos-disk01   /        ext4   defaults        0 1
EOF

cd $RFSBUILD/$RFSOPT/initramfs/x86-busybox/
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > $RFSBUILD/$RFSOPT/initramfs.cpio.gz
if [ -f "$RFSBUILD/$RFSOPT/initramfs.cpio.gz" ]
then
    echo "INITRAMFS is generated and readily available on $RFSBUILD/$RFSOPT/initramfs.cpio.gz"
    cp $RFSBUILD/$RFSOPT/initramfs.cpio.gz $L17NETOS_BUILD/initramfs-${KNL_VER}-generic
else
    echo "PROBLEM in generating the INITRAMFS"
fi

sudo dd if=/dev/zero of=$L17NETOS_BUILD/l17nos-disk01.img bs=1M count=512
sudo mkfs -t ext4 $L17NETOS_BUILD/l17nos-disk01.img
sudo mkdir -p /mnt/VHD/
sudo mount -t auto -o loop $L17NETOS_BUILD/l17nos-disk01.img /mnt/VHD/
cp -rf $RFSBUILD/$RFSOPT/initramfs/x86-busybox/* /mnt/VHD/
sudo umount /mnt/VHD/
