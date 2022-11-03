sudo dd if=/dev/zero of=$NETWARE_BUILD/NETWARE-1-0_x86-64.img bs=1M count=256
sudo mkfs -t ext4 $NETWARE_BUILD/NETWARE-1-0_x86-64.img
sudo mkdir -p /mnt/VHD/
sudo mount -t auto -o loop $NETWARE_BUILD/NETWARE-1-0_x86-64.img /mnt/VHD/
cp -rf $RFSBUILD/$RFSOPT/initramfs/x86-busybox/* /mnt/VHD/
cp $NETWARE_BUILD/initramfs-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/vmlinuz-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/config-${KNL_VER}-generic /mnt/VHD/boot/
cp $NETWARE_BUILD/System.map-${KNL_VER}-generic /mnt/VHD/boot/
sudo umount /mnt/VHD/
