# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=Dracula Kernel @ xelisa
kernel.name=Feith1453
kernel.version=1.1
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=hero2lte
device.name2=hero2ltebmc
device.name3=hero2lteskt
device.name4=hero2ltelgt
device.name5=hero2ltektt
} # end properties

# shell variables
block=/dev/block/platform/155a0000.ufs/by-name/BOOT;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod 750 $ramdisk/init.services.rc
chmod 640 $ramdisk/fstab.samsungexynos8890
chmod 750 $ramdisk/init.services.rc
chmod 750 $ramdisk/sbin/kernelinit.sh
chmod 750 $ramdisk/sbin/resetprop
chmod 750 $ramdisk/sbin/sysinit.sh
chmod 750 $ramdisk/sbin/wakelock.sh
chmod 750 $ramdisk/sbin/spec.sh

## AnyKernel install
dump_boot;

# begin ramdisk changes

insert_line default.prop "ro.sys.sdcardfs=false" after "debug.atrace.tags.enableflags=0" "ro.sys.sdcardfs=false";

# init.samsungexynos8890.rc
insert_line init.samsungexynos8890.rc "import init.services.rc" after "import init.remove_recovery.rc" "import init.services.rc";

# end ramdisk changes

write_boot;

## end install

