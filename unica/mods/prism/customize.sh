echo "Settling up configuration"
IFS=':' read -a SOURCE_EXTRA_FIRMWARES <<< "$SOURCE_FIRMWARE"
MODEL=$(echo -n "${SOURCE_FIRMWARE[0]}" | cut -d "/" -f 1)
REGION=$(echo -n "${SOURCE_FIRMWARE[0]}" | cut -d "/" -f 2)

echo "Setting up prism"

echo "Debloating prism"
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/app
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/HWRDB
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/lost+found
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/media
rm -rf $FW_DIR/${MODEL}_${REGION}/prism/priv-app

echo "Settling up a prism symlink"
rm -rf $WORK_DIR/system/prism
ln -s /system/prism $WORK_DIR/system/prism

SET_METADATA "system" "system/prism" 0 0 755 "u:object_r:system_file:s0"

# Intentionally break the source firmwares file contexts to make our life easier
{
    sed "s/^\/prism/\/system\/prism/g" "$FW_DIR/${MODEL}_${REGION}/file_context-prism"
} >> "$FW_DIR/${MODEL}_${REGION}/file_context-system"

{
    sed "1d" "$FW_DIR/${MODEL}_${REGION}/fs_config-prism" | sed "s/^prism/system\/prism/g"
} >> "$FW_DIR/${MODEL}_${REGION}/fs_config-system"

cat "$FW_DIR/${MODEL}_${REGION}/fs_config-system" | grep -F "system/prism" >> "$WORK_DIR/configs/fs_config-system"
cat "$FW_DIR/${MODEL}_${REGION}/file_context-system" | grep -F "system/prism" >> "$WORK_DIR/configs/file_context-system"

echo "Installing prism"
cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/prism" "$WORK_DIR/system/system"

echo "Setting up optics"

rm -rf $FW_DIR/${MODEL}_${REGION}/optics/lost+found

echo "Settling up an optics symlink"
rm -rf $WORK_DIR/system/optics
ln -s /system/optics $WORK_DIR/system/optics

SET_METADATA "system" "system/optics" 0 0 755 "u:object_r:system_file:s0"

# Intentionally break the source firmwares file contexts to make our life easier
{
    sed "s/^\/optics/\/system\/optics/g" "$FW_DIR/${MODEL}_${REGION}/file_context-optics"
} >> "$FW_DIR/${MODEL}_${REGION}/file_context-system"

{
    sed "1d" "$FW_DIR/${MODEL}_${REGION}/fs_config-optics" | sed "s/^optics/system\/optics/g"
} >> "$FW_DIR/${MODEL}_${REGION}/fs_config-system"

cat "$FW_DIR/${MODEL}_${REGION}/fs_config-system" | grep -F "system/optics" >> "$WORK_DIR/configs/fs_config-system"
cat "$FW_DIR/${MODEL}_${REGION}/file_context-system" | grep -F "system/optics" >> "$WORK_DIR/configs/file_context-system"

echo "Installing optics"
cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/optics" "$WORK_DIR/system/system"

echo "CSC was adapted successfully!"