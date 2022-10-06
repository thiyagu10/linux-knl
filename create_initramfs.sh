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
                echo "InitRAMFS is generated and readily available on $RFSOPT/obj/initramfs.cpio.gz"
                cp $RFSOPT/obj/initramfs.cpio.gz        $XNETOS_BUILD/initramfs-${KNL_VER}-generic
        else
                echo "PROBLEM in generating the INITRAMFS"
        fi
else
        echo "Inupt the correct directory to continue the INITRAMFS BUILD> Please rerun the script"
fi
