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

echo Verify the bibledit-cloud-data_n.n.nnn-n_all.deb

# Exit script on error.
set -e

DEB=$1
echo Checking package "$DEB"
if ! test -f "$DEB"; then
    echo The file does not exist
    exit
fi

echo Gathering required files
../cloud/pkgdata/create.sh

# Copy list to /tmp
cp ../cloud/pkgdata/files.txt /tmp

# Remove files not required
sed -i.bak '/\/fonts/d' /tmp/files.txt

# Load the minimum list of files that should be in the .deb package.
essential_files=()
while IFS= read -r line; do
  essential_files+=("$line")
done < /tmp/files.txt
echo Checking the package on ${#essential_files[@]} essential files

dpkg --contents "$DEB" > /tmp/package.txt

for file in "${essential_files[@]}"; do
  if ! grep -q "$file" /tmp/package.txt; then
    echo File "$file" does not exist in the package
  fi
done

echo Ready