#!/bin/bash

# Copyright (©) 2003-2026 Teus Benschop.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# Exit script on error.
set -e


DEBIAN_SOURCE=$(dirname "$0")
cd "$DEBIAN_SOURCE"
DEBIAN_SOURCE=$(pwd)
echo Running script in "$DEBIAN_SOURCE".


# If the debian/README* or README.Debian files contain no useful content,
# they should be updated with something useful, or else be removed.


echo Remove unwanted files from the Debian packaging.
find . -name .DS_Store -delete
echo Remove macOS extended attributes fromm the packaging.
# The attributes would make their way into the tarball,
# get unpacked within Debian,
# and would cause lintian errors.
xattr -r -c ./*


echo Remove macOS extended attributes from the core cloud library.
CLOUD_SOURCE="../cloud"
pushd $CLOUD_SOURCE
CLOUD_SOURCE=$(pwd)
xattr -r -c ./*
echo Create a tarball of the core cloud library.
rm -f build/bibledit*gz
cmake --build build --target dist
popd


# Verified: At this stage the tarball does not contain extended attributes.


# The script unpacks the Bibledit Cloud tarball,
# modifies it, and repacks it into a Debian tarball.
# Reasons for doing so are among others:
# - The Debian builder would otherwise notice differences
#   between the supplied tarball and the modified source.
#   dpkg-source: error: aborting due to unexpected upstream changes
# - In this way it does not need to generate patches in the 'debian' folder.
# - Comply with the Debian Free Software Guidelines.


TMP_DEBIAN=/tmp/bibledit-debian
echo Unpack the tarball and source in working folder $TMP_DEBIAN.
rm -rf $TMP_DEBIAN
mkdir $TMP_DEBIAN
cd $TMP_DEBIAN
tar xf "$CLOUD_SOURCE"/build/bibledit*gz


OLD_TAR_DIR=$(ls)
NEW_TAR_DIR=${OLD_TAR_DIR/bibledit/bibledit-cloud}
echo Rename directory from "$OLD_TAR_DIR" to "$NEW_TAR_DIR"
mv "$OLD_TAR_DIR" "$NEW_TAR_DIR"
xattr -c "$NEW_TAR_DIR"


cd bibledit*


echo Remove some files from the core library
echo It does not use the "bibledit" shell script.
echo That script writes to the crontab.
echo Delete it so it cannot be used accidentally.
rm bibledit
rm valgrind
rm dev
echo No test data in the Debian tarball.
echo Some data gives a lintian warning like this:
echo W: bibledit-cloud-data: executable-not-elf-or-script usr/share/bibledit-cloud/unittests/..
echo There would be licensing issues to be fixed too.
rm -rf unittests/tests


echo Link with the system-provided MbedTLS library.
echo It is important to use the system-provided mbedtls library because it is a security library.
echo This way, Debian updates to mbedtls become available to Bibledit too.
echo Were the library embedded, this would not be the case.
echo Remove all mbedtls code entirely
echo There had been a case that building used the embedded *.h files, leading to segmentation faults.
echo For cleanness, remove the whole mbedtls directory, so all traces of it are gone completely.
rm -rf mbedtls*
rm -rf psa*
sed -i.bak '/mbedtls\//d' CMakeLists.txt
rm CMakeLists.txt.bak


echo Disable mach.h definitions.
echo On Debian hurd-i386 it has the header mach/mach.h.
echo But it does not have the 64 bits statistics definitions.
echo It fails to compile there.
sed -i.bak '/HAVE_MACH_MACH/d' CMakeLists.txt
rm CMakeLists.txt.bak


echo Change the executable name from "server" to "bibledit-cloud".
sed -i.bak 's/"server"/"bibledit-cloud"/g' CMakeLists.txt
rm CMakeLists.txt.bak


echo Change shared data from bibledit to bibledit-cloud.
sed -i.bak 's/share\/bibledit/share\/bibledit-cloud/g' CMakeLists.txt
rm CMakeLists.txt.bak


echo Remove bibledit man page.
rm man/bibledit.1
sed -i.bak '/bibledit.1/d' CMakeLists.txt
rm CMakeLists.txt.bak


echo Remove extra license files.
# Fix for the lintian warnings "extra-license-file".
find . -name COPYING -delete
find . -name LICENSE -delete


echo Remove extra font files.
# Fix for the lintian warning "duplicate-font-file".
rm fonts/SILEOT.ttf
rm fonts/Montserrat*.ttf


echo Remove GTK stuff
rm -rf gtk


echo Remove unwanted files.
find . -name .DS_Store -delete
echo Remove macOS extended attributes.
# The attributes would make their way into the tarball,
# get unpacked within Debian,
# and would cause build errors there.
xattr -r -c ./*



echo Create tarball from the source without extended attributes.
BIBLEDIT_nnn=$(basename $(pwd))
cd ..
xattr -r -c ./*
COPYFILE_DISABLE=1 tar --no-xattrs -czf "$BIBLEDIT_nnn".tar.gz "$BIBLEDIT_nnn"
xattr -c "$BIBLEDIT_nnn".tar.gz
rm -rf "$BIBLEDIT_nnn"


echo Copy the Debian tarball to the Desktop.
rm -f ~/Desktop/bibledit-*gz
cp $TMP_DEBIAN/*.gz ~/Desktop


source ~/scr/sid-ip
echo The IP address of the Debian machine is "$DEBIANSID".
echo Copy the Debian tarball to the Debian builder.
scp $TMP_DEBIAN/*.gz "$DEBIANSID":.


echo Ready creating bibledit-cloud tarball for Debian.
