#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main()
{
	# Copy smolsynth3 files to root.
	# We should probably do this in a more secure way, but this is fine for now as proof-of-concept.
	cp -r /tmp/overlay/smolsynth3 /

	# Get required smolsynth3 libs.
	apt-get update
	apt-get -y install libsndfile1 libportaudio2 libportmidi0

	# Compile and activate device tree overlays.
	for dts in /tmp/overlay/dts/*
	do
		armbian-add-overlay $dts
		if [ $? -ne 0 ]
		then
			exit 1
		fi
	done

	# Generate US locale here so we don't worry about it on first boot.
	locale-gen en_US.UTF-8

	# Set high verbosity by default so we can more easily debug device driver issues.
	sed -i 's/verbosity=1/verbosity=7/' /boot/armbianEnv.txt
}

Main "$@"
