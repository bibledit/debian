#!/bin/bash

# Copyright (©) 2003-2025 Teus Benschop.

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


DEBIANSOURCE=`dirname $0`
cd $DEBIANSOURCE
DEBIANSOURCE=`pwd`
echo Running script from $DEBIANSOURCE


source ~/scr/sid-ip


echo Create a tarball for the Linux Client
../linux/tarball-macos.sh
echo A tarball was created at $DEBIANSID


echo Copying script to $DEBIANSID
scp tarball-client-sid.sh $DEBIANSID:.
ssh $DEBIANSID "./tarball-client-sid.sh"


echo Cleaning up
ssh $DEBIANSID "rm tarball-client-sid.sh"


echo Copying tarball back to Desktop
rm ~/Desktop/bibledit*tar.gz
scp "$DEBIANSID:bibledit-5*.tar.gz" ~/Desktop
echo Completed succesfully
