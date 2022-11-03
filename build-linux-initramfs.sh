##########################################################################################
#                          INITRAMFS - BUSYBOX-1.34.1
##########################################################################################

export RFSBUILD=$HOME/$IRAMFSBUILD
if [ -d "$LNXIMAGEOUT" ]
then
    echo "Directory $LNXIMAGEOUT exist. CONTINUE with this one"
else
   echo "Creating the NETWARE OS Directory"
   mkdir -pv $LNXIMAGEOUT
fi
if [ -d "$LOCALREPODIR" ]
then
    echo "Directory $LOCALREPODIR exist. CONTINUE with this one"
else
    echo "Creating the Local Repo Directory"
    mkdir -pv $LOCALREPODIR
fi

echo "Creating the initramfs build directory"
rm -rf $RFSBUILD
mkdir -pv $RFSBUILD
echo "Base Dirtectories Created"

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
tar -xf busybox-${BBOX_VER}.tar.bz2
cd busybox-${BBOX_VER}/
mkdir -pv $RFSBUILD/bbox-x86-64
make O=$RFSBUILD/bbox-x86-64 defconfig
sudo sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' $RFSBUILD/bbox-x86-64/.config
#make O=$RFSBUILD/bbox-x86-64 menuconfig
cd $RFSBUILD/bbox-x86-64
make -j $(nproc)
make install
mkdir -pv $RFSBUILD/final-ramvfs
cd $RFSBUILD/final-ramvfs
mkdir -pv {bin,boot,dev,sbin,etc/network,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root,var/{run,log},opt}
cp -av $RFSBUILD/bbox-x86-64/_install/*   $RFSBUILD/final-ramvfs
cp -av /dev/{null,console,tty,ttyS0,sda1}   $RFSBUILD/final-ramvfs/dev/

# Adding Init File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/init
#! /bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t ext4 NETWARE-1-0_x86-64 /
echo "NETWARE v1.0 is booted succesffully!!!"
exec /bin/sh
EOF
chmod +x $RFSBUILD/final-ramvfs/init
# Adding HOSTNAME File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/hostname
NETWARE-1-0
EOF
# Adding HOSTS File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/hosts
127.0.0.1       localhost
127.0.1.1       NETWARE-1-0
EOF
# Adding Network Interfaces File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/network/interfaces
auto eth0
iface eth0 inet dhcp
EOF
# Adding TimeZone File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/timezone
Asia/Kolkata
EOF
# Adding TimeZone File
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/os-release
NAME="NETWARE"
ID=NETWARE
VERSION_ID=1.0
PRETTY_NAME="NETWARE v1.0"
VERSION_CODENAME=0x00000B85
EOF
cat <<EOF | sudo tee $RFSBUILD/final-ramvfs/etc/fstab
LABEL=NETWARE-1-0_x86-64   /        ext4   defaults        0 1
EOF
cd $RFSBUILD/final-ramvfs
find . | cpio -H newc -o > ../initramfs.cpio
cd ..
cat initramfs.cpio | gzip > $RFSBUILD/initramfs.cpio.gz
if [ -f "$RFSBUILD/initramfs.cpio.gz" ]
then
    echo "INITRAMFS is generated and readily available on $RFSBUILD/initramfs.cpio.gz"
    cp $RFSBUILD/initramfs.cpio.gz $LNXIMAGEOUT/initramfs-${KNL_VER}-generic
else
    echo "PROBLEM in generating the INITRAMFS"
fi
#############################################################################################################
