echo "Applying Adapative Brightness fix"
HEX_PATCH "$WORK_DIR/system/system/lib64/libsensorservice.so" \
    "0660009420008052" "0660009400008052"
echo "Adapative Brightness fix was applied successfully!"