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

echo Verify the bibledit_n.n.nnn-n_arch.deb

# Exit script on error.
set -e

DEB=$1
echo Checking package "$DEB"
if ! test -f "$DEB"; then
    echo The file does not exist
    exit
fi

# The minimum list of files that should be in the .deb package.
essential_files=(

usr/bin/bibledit
usr/share/applications/bibledit.desktop
usr/share/man/man1/bibledit.1.gz
usr/share/metainfo/bibledit.appdata.xml
usr/share/pixmaps/bbe48x48.xpm
usr/share/pixmaps/bbe512x512.png

)
echo Checking the package on ${#essential_files[@]} essential files

dpkg --contents "$DEB" > /tmp/files.txt

for file in "${essential_files[@]}"; do
  if ! grep -q "$file" /tmp/files.txt; then
     echo File "$file" does not exist in the package
  fi
done

echo Ready