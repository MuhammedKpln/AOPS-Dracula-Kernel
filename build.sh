#!/bin/bash
# Kernel Build Script v3.0
#
# Copyright (C) 2017 Michele Beccalossi <beccalossi.michele@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

KERNEL_NAME="Dracula_KERNEL"
KERNEL_VERSION="1.1"

if [ $1 == 1 ] || [ $1 == 3 ] ; then
	export MODEL=herolte
elif [ $1 == 2 ] || [ $1 == 4 ] ; then
	export MODEL=hero2lte
else
	echo ""
	echo "========================================================="
	echo "ERROR : UNKNOWN_INPUT"
	echo "========================================================="
	echo ""
	echo "Usage: build.sh [option]"
	echo ""
	echo "Currently available options are:"
	echo "1 - to build for herolte"
	echo "2 - to build for hero2lte"
	echo "3 - to clean the build environment and build for herolte"
	echo "4 - to clean the build environment and build for hero2lte"
	echo ""
	echo "========================================================="
	echo "ERROR : UNKNOWN_INPUT"
	echo "========================================================="
	echo ""
	exit 1
fi
export VARIANT=eur
export ARCH=arm64
export LOCALVERSION=-${KERNEL_NAME}-v${KERNEL_VERSION}
export BUILD_CROSS_COMPILE=/home/muhammed/Desktop/aarch64-uber-linux-android-6.3.1-20170616/bin/aarch64-linux-android-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
ZIPDIR=$RDIR/ramdisk/$MODEL

PAGE_SIZE=2048
DTB_PADDING=0

KERNEL_DEFCONFIG=dracula-$MODEL-d_defconfig

FUNC_CLEAN_DTB()
{
	echo ""
	echo "========================================================="
	echo "START : FUNC_CLEAN_DTB"
	echo "========================================================="
	echo ""

	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "No directory: "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "Delete files in: "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm -f $RDIR/arch/$ARCH/boot/dtb/*.dtb
	fi

	if [ -a $RDIR/arch/$ARCH/boot/dtb.img ] ; then
		echo "Delete dtb.img generated from previous build"
		rm $RDIR/arch/$ARCH/boot/dtb.img
	fi
	if [ -a $RDIR/arch/$ARCH/boot/Image ] ; then
		echo "Delete Image generated from previous build"
		rm $RDIR/arch/$ARCH/boot/Image
	fi

	echo ""
	echo "========================================================="
	echo "END   : FUNC_CLEAN_DTB"
	echo "========================================================="
	echo ""
}

FUNC_CLEAN_ENVIRONMENT()
{
	echo ""
	echo "========================================================="
	echo "START : FUNC_CLEAN_ENVIRONMENT"
	echo "========================================================="
	echo ""

	make mrproper

	echo ""
	echo "========================================================="
	echo "END   : FUNC_CLEAN_ENVIRONMENT"
	echo "========================================================="
	echo ""
}

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
	echo "========================================================="
	echo "START : FUNC_BUILD_DTIMAGE_TARGET"
	echo "========================================================="
	echo ""

	if [ $MODEL == herolte ] ; then
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
	elif [ $MODEL == hero2lte ] ; then
		DTSFILES="exynos8890-hero2lte_eur_open_00 exynos8890-hero2lte_eur_open_01
				exynos8890-hero2lte_eur_open_03 exynos8890-hero2lte_eur_open_04
				exynos8890-hero2lte_eur_open_08"
	fi

	mkdir -p $OUTDIR $DTBDIR

	cd $DTBDIR || {
		echo "Unable to change directory to $DTBDIR!"
		echo ""
		exit 1
	}

	rm -f ./*
	echo "Processing dts files..."
	echo ""
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo ""
	echo "Generating dtb.img..."
	echo ""
	$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE

	echo ""
	echo "========================================================="
	echo "END   : FUNC_BUILD_DTIMAGE_TARGET"
	echo "========================================================="
	echo ""
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "========================================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "========================================================="
	echo ""
	echo "Build common config:	"$KERNEL_DEFCONFIG""
	echo "Build model config:	"$MODEL""
	echo ""

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	echo ""
	echo "========================================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "========================================================="
	echo ""
}

FUNC_BUILD_ZIP()
{
	echo ""
	echo "========================================================="
	echo "START : FUNC_BUILD_ZIP"
	echo "========================================================="
	echo ""

	rm -f $ZIPDIR/zImage
	rm -f $ZIPDIR/dtb
	cp $RDIR/arch/$ARCH/boot/Image $ZIPDIR/zImage
	cp $RDIR/arch/$ARCH/boot/dtb.img $ZIPDIR/dtb

	if ! [ -d $RDIR/out ] ; then
		mkdir $RDIR/out
	fi
	cd $ZIPDIR
	rm -f ../../out/*-$MODEL.zip
	echo "Output: $KERNEL_NAME-v$KERNEL_VERSION-$MODEL.zip"
	echo ""
	zip -r9 ../../out/$KERNEL_NAME-v$KERNEL_VERSION-$MODEL.zip * -x README.md -x modules/\* -x patch/\*

	echo ""
	echo "========================================================="
	echo "END   : FUNC_BUILD_ZIP"
	echo "========================================================="
	echo ""
}

# MAIN FUNCTION
rm -f ./build.log
(
	START_TIME=`date +%s`

	FUNC_CLEAN_DTB
  if [ $1 == 3 ] || [ $1 == 4 ]; then
		FUNC_CLEAN_ENVIRONMENT
	fi
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTIMAGE_TARGET
	FUNC_BUILD_ZIP

	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time was $ELAPSED_TIME seconds."
	echo ""

) 2>&1 | tee -a ./build.log
