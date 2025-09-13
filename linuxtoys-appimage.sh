#!/bin/sh

set -ex

ARCH="$(uname -m)"
VERSION="$(cat ~/version)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export ADD_HOOKS="self-updater.bg.hook"
export ICON=/usr/share/icons/hicolor/scalable/apps/linuxtoys.svg
export DESKTOP=/usr/share/applications/LinuxToys.desktop
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=linuxtoys-"$VERSION"-anylinux-"$ARCH".AppImage
export DEPLOY_PYTHON=1
export DEPLOY_GTK=1
export GTK_VER=3
export PYTHON_VER=3.13
export PYTHON_PACKAGES="PyGObject"
export EXEC_WRAPPER=1

# Deploy dependencies
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/linuxtoys /usr/share/linuxtoys/run.py

echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env
echo 'LINUXTOYS_PROCESS_NAME=linuxtoys' >> ./AppDir/.env
sed -i 's|Exec=.*|Exec=run.py|g' ./AppDir/*.desktop
cp -rn ./AppDir/share/linuxtoys/* ./AppDir/bin
rm -rf ./AppDir/bin/linuxtoys ./AppDir/share/linuxtoys

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist
