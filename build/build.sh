#!/bin/bash -e

if [ $# -ne 1 ]; then
    echo "usage: $(basename $0) source" >&2
    exit 1
fi

SOURCE_DIR=$1
MOUNT_DIR=/mnt/

# Extract package name and version; <package name> (<version-revision>)
FIRST_LINE=$(head -n 1 ${MOUNT_DIR}/${SOURCE_DIR}/debian/changelog)
[[ ${FIRST_LINE} =~ ^(.+?)\ \(([^-]+)-(.+?)\) ]] || exit 1
PACKAGE=${BASH_REMATCH[1]}
VERSION=${BASH_REMATCH[2]}
REVISION=${BASH_REMATCH[3]}

PACKAGE_DIR=${PACKAGE}-${VERSION}

# Copy source directory
cp -pr ${MOUNT_DIR}/${SOURCE_DIR} ./${PACKAGE_DIR}/

# Remove unrelated files
rm -r ${PACKAGE_DIR}/build/

# Prepare source tar.gz
tar zcvf ${PACKAGE}_${VERSION}.orig.tar.gz \
    --exclude-vcs --owner=0 --group=0 ${PACKAGE_DIR}/

# Install build dependencies
cd ${PACKAGE_DIR}/
sudo apt-get update
mk-build-deps --install --remove --root-cmd=sudo --tool='apt-get -y'

# Build package
debuild -uc -us -I.git

# Copy generated deb files
cd ../
cp -p *.deb ${MOUNT_DIR}/

exit 0
