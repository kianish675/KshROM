#!/usr/bin/env bash
#
# Copyright (C) 2023 Salvo Giangreco
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# shellcheck disable=SC2162

ROM_STATUS="UNOFFICIAL"

set -Eeuo pipefail

# [
GET_PROP()
{
    local PROP="$1"
    local FILE="$2"

    if [ ! -f "$FILE" ]; then
        echo "File not found: $FILE"
        exit 1
    fi

    grep "^$PROP=" "$FILE" | cut -d "=" -f2-
}

PRINT_HEADER()
{
    local ONEUI_VERSION
    local MAJOR
    local MINOR
    local PATCH

    ONEUI_VERSION="$(GET_PROP "ro.build.version.oneui" "$WORK_DIR/system/system/build.prop")"
    MAJOR=$(echo "scale=0; $ONEUI_VERSION / 10000" | bc -l)
    MINOR=$(echo "scale=0; $ONEUI_VERSION % 10000 / 100" | bc -l)
    PATCH=$(echo "scale=0; $ONEUI_VERSION % 100" | bc -l)
    if [[ "$PATCH" != "0" ]]; then
        ONEUI_VERSION="$MAJOR.$MINOR.$PATCH"
    else
        ONEUI_VERSION="$MAJOR.$MINOR"
    fi

    echo    'ui_print(" ");'
    echo    'ui_print("****************************************************");'
    echo -n 'ui_print("'
    echo -n "Welcome to KshROM Axion 1.6.5 for the Galaxy A70!"
    echo    '");'
    echo    'ui_print("KshROM Created by Kianish675 @XDAforums");'
    echo    'ui_print("Initial UN1CA build system coded by salvo_giangri @XDAforums");'
    echo    'ui_print("Special thanks to Tisenu100, ExtremeXT and other people!");'
    echo    'ui_print("****************************************************");'
    echo -n 'ui_print("'
    echo -n "One UI: $ONEUI_VERSION"
    echo    '");'
    echo -n 'ui_print("'
    echo -n "Source: samsung/a73xqxx/qssi:15/AP3A.240905.015.A2/A736BXXSAFYH2:user/release-keys"
    echo    '");'
    echo -n 'ui_print("'
    echo -n "Target: samsung/a70qxx/a70q:11/RP1A.200720.012/A705FNXXU5DXD2:user/release-keys"
    echo    '");'
    echo    'ui_print("****************************************************");'
    echo    'ui_print("After installation, it is highly recommended to FORMAT DATA as follows:");'
    echo    'ui_print("     Factory Reset -> Format Data");'
    echo    'ui_print("Hint: Found Bugs? Report bugs at t.me/kshrom");'
    echo    'ui_print(" ");'
    echo    'ui_print("If you decide to not format, unexpected issues may occur and no support will be given.");'
    echo    'ui_print(" ");'
    echo    'ui_print("Proceeding with install..");'
    echo    'ui_print("Checking device..");' 
    echo    'ui_print("   -> Galaxy A70");'
    echo    'ui_print("kianish is noob developer ez");'
} >> "$SCRIPT_FILE"

GET_SPARSE_IMG_SIZE()
{
    local FILE_INFO
    local BLOCKS
    local BLOCK_SIZE

    FILE_INFO=$(file -b "$1")
    if [ -z "$FILE_INFO" ] || [[ "$FILE_INFO" != "Android"* ]]; then
        exit 1
    fi

    BLOCKS=$(echo "$FILE_INFO" | grep -o "[[:digit:]]*" | sed "3p;d")
    BLOCK_SIZE=$(echo "$FILE_INFO" | grep -o "[[:digit:]]*" | sed "4p;d")

    echo "$BLOCKS * $BLOCK_SIZE" | bc -l
}

GENERATE_UPDATER_SCRIPT()
{
    local SCRIPT_FILE="$TMP_DIR/META-INF/com/google/android/updater-script"
    local PARTITION_COUNT=0
    local HAS_BOOT=false
    local HAS_SYSTEM=false
    local HAS_VENDOR=false
    local HAS_PRODUCT=false

# Normally not needed for a hardcoded install but just to be sure
    [ -f "$TMP_DIR/boot.img" ] && HAS_BOOT=true
    [ -f "$TMP_DIR/dtbo.img" ] && HAS_DTBO=true
    [ -f "$TMP_DIR/system.new.dat.br" ] && HAS_SYSTEM=true
    [ -f "$TMP_DIR/vendor.new.dat.br" ] && HAS_VENDOR=true
    [ -f "$TMP_DIR/product.new.dat.br" ] && HAS_PRODUCT=true
    
    {
        if $HAS_SYSTEM; then
            echo -e "\n# Patch partition system\n"
            echo    'ui_print("Patching system unconditionally..");'
            echo -n 'show_progress(0.500000, 0);'
            echo    'block_image_update("/dev/block/platform/soc/1d84000.ufshc/by-name/system", package_extract_file("system.transfer.list"), "system.new.dat.br", "system.patch.dat") ||'
            echo    '  abort("E1001: Failed to Update the system.");'
        fi
        if $HAS_VENDOR; then
            echo -e "\n# Patch partition vendor\n"
            echo    'ui_print("Patching vendor unconditionally..");'
            echo    'show_progress(0.100000, 0);'
            echo    'block_image_update("/dev/block/platform/soc/1d84000.ufshc/by-name/vendor", package_extract_file("vendor.transfer.list"), "vendor.new.dat.br", "vendor.patch.dat") ||'
            echo    '  abort("E2001: Failed to update the vendor.");'
        fi
        if $HAS_PRODUCT; then
            echo -e "\n# Patch partition product\n"
            echo    'ui_print("Patching product unconditionally..");'
            echo    'show_progress(0.100000, 0);'
            echo    'block_image_update("/dev/block/platform/soc/1d84000.ufshc/by-name/product", package_extract_file("product.transfer.list"), "vendor.new.dat.br", "product.patch.dat") ||'
            echo    '  abort("E2001: Failed to update product.");'
        fi
        if $HAS_DTBO; then
            echo    'ui_print("Completely Patching dtbo..");'
            echo -n 'package_extract_file("dtbo.img", "'
            echo    '/dev/block/bootdevice/by-name/dtbo");'
        fi
        if $HAS_BOOT; then
            echo    'ui_print("Installing boot image...");'
            echo -n 'package_extract_file("boot.img", "'
            echo    '/dev/block/bootdevice/by-name/boot");'
        fi

        echo    'set_progress(1.000000);'
        echo    'ui_print("****************************************");'
        echo    'ui_print(" ");'
    } >> "$SCRIPT_FILE"

    true
}

GENERATE_BUILD_INFO()
{
    local BUILD_INFO_FILE="$TMP_DIR/build_info.txt"

    [ -f "$BUILD_INFO_FILE" ] && rm -f "$BUILD_INFO_FILE"
    touch "$BUILD_INFO_FILE"
    {
        echo "device=$TARGET_CODENAME"
        echo "version=$ROM_VERSION"
        echo "timestamp=$ROM_BUILD_TIMESTAMP"
        echo "security_patch_version=$(GET_PROP "ro.build.version.security_patch" "$WORK_DIR/system/system/build.prop")"
    } >> "$BUILD_INFO_FILE"

    true
}

FILE_NAME="KshROM_${ROM_STATUS}_${ROM_VERSION}_$(date +%Y%m%d)_${TARGET_CODENAME}"
CERT_NAME="aosp_testkey"
$ROM_IS_OFFICIAL && [ -f "$SRC_DIR/security/unica_ota.pk8" ] && CERT_NAME="unica_ota"
# ]

echo "Set up tmp dir"
mkdir -p "$TMP_DIR"
[ -d "$TMP_DIR/META-INF/com/google/android" ] && rm -rf "$TMP_DIR/META-INF/com/google/android"
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp --preserve=all "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

while read -r i; do
    PARTITION=$(basename "$i")
    [[ "$PARTITION" == "configs" ]] && continue
    [ -f "$TMP_DIR/$PARTITION.img" ] && rm -f "$TMP_DIR/$PARTITION.img"
    [ -f "$WORK_DIR/$PARTITION.img" ] && rm -f "$WORK_DIR/$PARTITION.img"

    echo "Building $PARTITION.img"
    bash "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM+sparse" "$WORK_DIR/$PARTITION" \
        "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION"
    mv "$WORK_DIR/$PARTITION.img" "$TMP_DIR/$PARTITION.img"
done <<< "$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d)"

echo "Copying prebuilt images"
lz4 -c -d $SRC_DIR/target/$TARGET_CODENAME/prebuilt_images/product.img.lz4 >> $TMP_DIR/product.img
lz4 -c -d -m $SRC_DIR/target/$TARGET_CODENAME/prebuilt_images/vendor/vendor.img.* >> $TMP_DIR/vendor.img

while read -r i; do
    PARTITION="$(basename "$i" | sed "s/.img//g")"

    if [ -f "$TMP_DIR/$PARTITION.new.dat" ] || [ -f "$TMP_DIR/$PARTITION.new.dat.br" ]; then
        rm -f "$TMP_DIR/$PARTITION.new.dat" \
            && rm -f "$TMP_DIR/$PARTITION.new.dat.br" \
            && rm -f "$TMP_DIR/$PARTITION.patch.dat" \
            && rm -f "$TMP_DIR/$PARTITION.transfer.list"
    fi

    echo "Converting $PARTITION.img to $PARTITION.new.dat"
    img2sdat -o "$TMP_DIR" "$i" > /dev/null 2>&1 \
        && rm "$i"
    echo "Compressing $PARTITION.new.dat"
    brotli --quality=6 --output="$TMP_DIR/$PARTITION.new.dat.br" "$TMP_DIR/$PARTITION.new.dat" \
        && rm "$TMP_DIR/$PARTITION.new.dat"
done <<< "$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type f -name "*.img")"

echo "Copying prebuilt kernel"
lz4 -d $SRC_DIR/target/$TARGET_CODENAME/prebuilt_images/boot.img.lz4 $TMP_DIR/boot.img
lz4 -d $SRC_DIR/target/$TARGET_CODENAME/prebuilt_images/dtbo.img.lz4 $TMP_DIR/dtbo.img

echo "Generating updater-script"
GENERATE_UPDATER_SCRIPT

echo "Generate build_info.txt"
GENERATE_BUILD_INFO

echo "Creating zip"
[ -f "$OUT_DIR/rom.zip" ] && rm -f "$OUT_DIR/rom.zip"
cd "$TMP_DIR" ; zip -rq ../rom.zip ./* ; cd - &> /dev/null

echo "Signing zip"
[ -f "$OUT_DIR/$FILE_NAME-sign.zip" ] && rm -f "$OUT_DIR/$FILE_NAME-sign.zip"
signapk -w \
    "$SRC_DIR/security/$CERT_NAME.x509.pem" "$SRC_DIR/security/$CERT_NAME.pk8" \
    "$OUT_DIR/rom.zip" "$OUT_DIR/$FILE_NAME-sign.zip" \
    && rm -f "$OUT_DIR/rom.zip"

echo "Deleting tmp dir"
rm -rf "$TMP_DIR"

exit 0