#!/system/bin/sh

# Set first parameter to profile
profile=$1
SPECTRUM_PROF=/data/media/0/Spectrum/profiles
SPECTRUM_PATH=/data/media/0/Spectrum

# Function to apply ramdisk style settings
function write() {
    echo -n $2 > $1
}

# Load profile data
source /data/media/0/Spectrum/profiles/${profile}.profile;


#-------------------------
# SPECTRUM FILES
#-------------------------


	# Check if spectrum profile directory is exist
    if [ ! -d $SPECTRUM_PATH ]; then
	$BB mkdir $SPECTRUM_PATH
	$BB cd $SPECTRUM_PATH
	$BB mkdir $SPECTRUM_PATH/profiles/
	$BB cp -i /res/spec/balance.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/battery.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/gaming.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/performance.profile $SPECTRUM_PROF
    else
	# If it exist, remove all files then copy spectrum profiles.
	$BB mkdir $SPECTRUM_PATH
	$BB cd $SPECTRUM_PATH
	$BB mkdir $SPECTRUM_PATH/profiles/
	$BB cp -i /res/spec/balance.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/battery.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/gaming.profile $SPECTRUM_PROF
	$BB cp -i /res/spec/performance.profile $SPECTRUM_PROF	


    fi;
