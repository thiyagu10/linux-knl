sudo dd if=/dev/zero of=$LNXIMAGEOUT/NETWARE-1-0_x86-64.img bs=1M count=256
sudo mkfs -t ext4 $LNXIMAGEOUT/NETWARE-1-0_x86-64.img
sudo mkdir -p /mnt/VHD/
sudo mount -t auto -o loop $LNXIMAGEOUT/NETWARE-1-0_x86-64.img /mnt/VHD/
cp -rf $IRAMFSBUILD/final-ramvfs/* /mnt/VHD/
cp $LNXIMAGEOUT/initramfs-${KNL_VER}-generic /mnt/VHD/boot/
cp $LNXIMAGEOUT/vmlinuz-${KNL_VER}-generic /mnt/VHD/boot/
cp $LNXIMAGEOUT/config-${KNL_VER}-generic /mnt/VHD/boot/
cp $LNXIMAGEOUT/System.map-${KNL_VER}-generic /mnt/VHD/boot/
sudo umount /mnt/VHD/
