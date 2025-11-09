{
mkdir $WORK_DIR/system/system/system_ext/apex
} || {
echo "/system/system_ext/apex: Already a folder"
}

echo "- Adding S23 FE (r11sxxx) lib/ blobs.."
ADD_TO_WORK_DIR "r11sxxx" "system" "system/lib" 0 0 644


echo "- Adding 32-bit support from S23 FE (r11sxxx) & S21 FE (r9qxxx)"
ADD_TO_WORK_DIR "r11sxxx" "system" "system/apex/com.android.runtime.apex" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "r11sxxx" "system" "system/apex/com.android.i18n.apex" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "r11sxxx" "system" "system/bin/bootstrap" 0 2000 751 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/bin/insthk" 0 2000 755 "u:object_r:insthk_exec:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/bin/remotedisplay" 0 2000 755 "u:object_r:remotedisplay_exec:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/lib" 0 0 755 "u:object_r:system_lib_file:s0"
ADD_TO_WORK_DIR "r9qxxx" "system" "system/system_ext/apex/com.android.vndk.v30.apex" 0 0 644 "u:object_r:system_file:s0"

echo "- Setting up symlinks.. "
ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker"
ln -sf "/apex/com.android.runtime/bin/linker" "$WORK_DIR/system/system/bin/linker_asan"
SET_METADATA "system" "system/bin/linker" 0 0 755 "u:object_r:system_file:s0"
SET_METADATA "system" "system/bin/linker_asan" 0 0 755 "u:object_r:system_file:s0"

ln -sf "/apex/com.android.runtime/lib/bionic/libc.so" "$WORK_DIR/system/system/lib/libc.so"
ln -sf "/apex/com.android.runtime/lib/bionic/libdl.so" "$WORK_DIR/system/system/lib/libdl.so"
ln -sf "/apex/com.android.runtime/lib/bionic/libdl_android.so" "$WORK_DIR/system/system/lib/libdl_android.so"
ln -sf "/apex/com.android.runtime/lib/bionic/libm.so" "$WORK_DIR/system/system/lib/libm.so"
SET_METADATA "system" "system/lib/libc.so" 0 0 644 "u:object_r:system_lib_file:s0"
SET_METADATA "system" "system/lib/libdl.so" 0 0 644 "u:object_r:system_lib_file:s0"
SET_METADATA "system" "system/lib/libdl_android.so" 0 0 644 "u:object_r:system_lib_file:s0"
SET_METADATA "system" "system/lib/libm.so" 0 0 644 "u:object_r:system_lib_file:s0"
echo - "Done setting up symlinks!"

echo "- Added 32-bit support."
