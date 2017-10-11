#!/system/bin/sh


# UNOFFICAL DraculaKernel



if [ -e /su/xbin/busybox ]; then
	BB=/su/xbin/busybox;
else if [ -e /sbin/busybox ]; then
	BB=/sbin/busybox;
else
	BB=/system/xbin/busybox;
fi;
fi;


MTWEAKS_PATH=/data/.mtweaks


# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;


# cpu - little
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# cpu - big
echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# CPU freq. values
echo 2288000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq;
echo 416000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq;
echo 1586000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo 130000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;

# miscellaneous

# Set I/O Scheduler tweaks mmcblk0
#favoritus
	chmod 644 /sys/block/mmcblk0/queue/scheduler
	echo "zen" > /sys/block/mmcblk0/queue/scheduler
	echo "512" > /sys/block/mmcblk0/queue/read_ahead_kb
  chmod 644 /sys/block/mmcblk0/queue/iosched/writes_starved
	echo "4" > /sys/block/mmcblk0/queue/iosched/writes_starved
  chmod 644 /sys/block/mmcblk0/queue/iosched/fifo_batch
	echo "16" > /sys/block/mmcblk0/queue/iosched/fifo_batch
	echo "350" > /sys/block/mmcblk0/queue/iosched/sync_read_expire
	echo "550" > /sys/block/mmcblk0/queue/iosched/sync_write_expire
	echo "250" > /sys/block/mmcblk0/queue/iosched/async_read_expire
	echo "450" > /sys/block/mmcblk0/queue/iosched/async_write_expire
	echo "10" > /sys/block/mmcblk0/queue/iosched/sleep_latency_multiple

# Set I/O Scheduler tweaks sda
  chmod 644 /sys/block/sda/queue/scheduler
	echo "zen" > /sys/block/sda/queue/scheduler
	echo "256" > /sys/block/sda/queue/read_ahead_kb
        echo "5" > /sys/block/sda/bdi/min_ratio
        echo "2" > /sys/block/sda/queue/rq_affinity
	echo "0" > /sys/block/sda/queue/add_random
	echo "4" > /sys/block/sda/queue/iosched/writes_starved
	echo "16" > /sys/block/sda/queue/iosched/fifo_batch
	echo "350" > /sys/block/sda/queue/iosched/sync_read_expire
	echo "550" > /sys/block/sda/queue/iosched/sync_write_expire
	echo "250" > /sys/block/sda/queue/iosched/async_read_expire
	echo "450" > /sys/block/sda/queue/iosched/async_write_expire
	echo "10" > /sys/block/sda/queue/iosched/sleep_latency_multiple

# Set I/O Scheduler tweaks sdb
	chmod 644 /sys/block/sdb/queue/scheduler
  echo "zen" > /sys/block/sdb/queue/scheduler

# Set I/O Scheduler tweaks sdc
	chmod 644 /sys/block/sdc/queue/scheduler
	echo "zen" > /sys/block/sdc/queue/scheduler

# Set I/O Scheduler tweaks sdd
	chmod 644 /sys/block/sdd/queue/scheduler
	echo "zen" > /sys/block/sdd/queue/scheduler

# network
sysctl -w net.ipv4.tcp_congestion_control=westwoo

# TWEAKS
# morogoku

    # SD-Card Readhead
    echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb;

    # Internet Speed
    echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
    echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
    echo "1" > /proc/sys/net/ipv4/tcp_sack;
    echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
    echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
    echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes;
    echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl;
    echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout;
    echo "404480" > /proc/sys/net/core/wmem_max;
    echo "404480" > /proc/sys/net/core/rmem_max;
    echo "256960" > /proc/sys/net/core/rmem_default;
    echo "256960" > /proc/sys/net/core/wmem_default;
    echo "4096,16384,404480" > /proc/sys/net/ipv4/tcp_wmem;
    echo "4096,87380,404480" > /proc/sys/net/ipv4/tcp_rmem;


#-------------------------
# KERNEL INIT VALUES
#-------------------------
	
# Selinux
echo "0" > /sys/fs/selinux/enforce

# MTWEAKS


	# Make internal storage directory.
    if [ ! -d $MTWEAKS_PATH ]; then
	    $BB mkdir $MTWEAKS_PATH;
    fi;
	
	$BB chmod 0777 $MTWEAKS_PATH;
	$BB chown 0.0 $MTWEAKS_PATH;

	# Delete backup directory
	$BB rm -rf $MTWEAKS_PATH/bk;

    # Make backup directory.
	$BB mkdir $MTWEAKS_PATH/bk;
	$BB chmod 0777 $MTWEAKS_PATH/bk;
	$BB chown 0.0 $MTWEAKS_PATH/bk;

	# Save original voltages
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_volt_table > $MTWEAKS_PATH/bk/cpuCl1_stock_voltage
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster0_volt_table > $MTWEAKS_PATH/bk/cpuCl0_stock_voltage
	$BB cat /sys/devices/14ac0000.mali/volt_table > $MTWEAKS_PATH/bk/gpu_stock_voltage
	$BB chmod -R 755 $MTWEAKS_PATH/bk/*;



# APPLY PERMISSIONS


	# sqlite3
	$BB chown 0.0 /system/xbin/sqlite3;
	$BB chmod 755 /system/xbin/sqlite3;

#-------------------------

# Deep Sleep fix by @Chainfire from SuperSU
for i in `ls /sys/class/scsi_disk/`; do
cat /sys/class/scsi_disk/$i/write_protect 2>/dev/null | grep 1 >/dev/null
if [ $? -eq 0 ]; then
echo 'temporary none' > /sys/class/scsi_disk/$i/cache_type
fi
done


# Unmount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;

