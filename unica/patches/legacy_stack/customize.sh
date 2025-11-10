{
mkdir $WORK_DIR/system/system/system_ext/apex
} || {
echo "Apex folder already exists"
}

echo "Applying Legacy stack from S21 FE (r9qxxx)"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/apex/com.android.runtime.apex" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/apex/com.android.i18n.apex" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/bin/bootstrap" 0 2000 751 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/bin/insthk" 0 2000 755 "u:object_r:insthk_exec:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/bin/linker" 0 2000 755 "u:object_r:system_linker_exec:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/bin/linker_asan" 0 2000 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/bin/remotedisplay" 0 2000 755 "u:object_r:remotedisplay_exec:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/lib" 0 0 755 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "$SOURCE_EXTRA_FIRMWARES" "system" "system/system_ext/apex/com.android.vndk.v30.apex" 0 0 644 "u:object_r:system_file:s0"

# THIS IS A VERY DIRTY HACK TO APPLY SYSTEM_EXT 32-BIT STACK LIBRARIES TO OUR FIRMWARE
# Reason is the build system crumbles while attempting to add the files in
echo "Dirty adding system_ext from S21 FE (r9qxxx)"

MODEL=$(echo -n "$SOURCE_EXTRA_FIRMWARES" | cut -d "/" -f 1)
REGION=$(echo -n "$SOURCE_EXTRA_FIRMWARES" | cut -d "/" -f 2)

cp -a --preserve=all "$FW_DIR/${MODEL}_${REGION}/system/system/system_ext/lib" "$WORK_DIR/system/system/system_ext"
cat "$FW_DIR/${MODEL}_${REGION}/fs_config-system" | grep -F "system/system_ext/lib" >> "$WORK_DIR/configs/fs_config-system"
cat "$FW_DIR/${MODEL}_${REGION}/file_context-system" | grep -F "system/system_ext/lib" >> "$WORK_DIR/configs/file_context-system"
echo "system/system_ext/lib 0 0 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
echo "/system/system_ext/lib u:object_r:system_lib_file:s0" >> "$WORK_DIR/configs/file_context-system"

echo "Legacy stack was applied successfully!"