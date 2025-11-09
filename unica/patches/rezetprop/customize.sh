echo "- Setting up rezetprop.."

SECURITY_PATCH="$(GET_PROP "ro.build.version.security_patch")"

{
    echo "on property:service.bootanim.exit=1"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.flash.locked 1"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.vbmeta.device_state locked"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.verifiedbootstate green"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.veritymode enforcing"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.warranty_bit 0"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n sys.oem_unlock_allowed 0"
    echo "    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.vendor.build.security_patch "$SECURITY_PATCH
    echo ""
    echo "on property:sys.unica.vbmeta.digest=*"
    echo '    exec u:r:init:s0 root root -- /system/bin/rezetprop -n ro.boot.vbmeta.digest ${sys.unica.vbmeta.digest}'
    echo ""
} >> "$WORK_DIR/system/system/etc/init/hw/init.rc"

echo "- Succesfully finished rezetprop setup."

sed -i 's/${ro.boot.warranty_bit}/0/g' "$WORK_DIR/system/system/etc/init/init.rilcommon.rc"

echo "Setting up SEPolicy.."
LINES="$(sed -n "/^(allow init init_exec\b/=" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil")"
for l in $LINES; do
    sed -i "${l} s/)))/ execute_no_trans)))/" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
done
echo "- SEPolicy is set up."
