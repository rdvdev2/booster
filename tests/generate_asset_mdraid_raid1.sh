trap 'rm $OUTPUT' ERR
trap 'sudo umount $dir; rm -r $dir; sudo mdadm --stop /dev/md/BoosterTestArray1; sudo losetup -d $lodev' EXIT

truncate --size 60M $OUTPUT
lodev=$(sudo losetup -f --show $OUTPUT)
# create 5 partitions each 10 megabytes
sudo fdisk $lodev <<<"g
n


+10M
t

29
n


+10M
t

29
n


+10M
t

29
n


+10M
t

29
n


+10M
t

29
w
" || true # adding 'true' here to workaround 'Re-reading the partition table failed.: Invalid argument' error

sudo partprobe $lodev

echo "DEVICE partitions\n" >> $OUTPUT.array

sudo mdadm --create --verbose --metadata=default --level=raid1 --raid-devices=5 /dev/md/BoosterTestArray1 ${lodev}p2 ${lodev}p4 ${lodev}p5 ${lodev}p1 ${lodev}p3
sudo mdadm --detail --scan | tee -a $OUTPUT.array

sudo mkfs.ext4 -U $FS_UUID -L $FS_LABEL /dev/md/BoosterTestArray1
dir=$(mktemp -d)
sudo mount /dev/md/BoosterTestArray1 $dir

sudo chown $USER $dir
mkdir $dir/sbin
cp assets/init $dir/sbin/init
