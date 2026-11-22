#!@busybox@/bin/sh
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
@busybox@/bin/busybox mkdir -p /bin /sbin /usr/bin /usr/sbin /proc /sys /dev /ro-base /rw-overlay /newroot
@busybox@/bin/busybox --install -s /bin

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
if [ -c /dev/console ]; then
    exec </dev/console >/dev/console 2>&1
fi

# Defaults overridden by kernel cmdline
FC_BOOTSTRAP="0"
FC_IP=""
FC_GW="@gatewayAddress@"
FC_DNS="@primaryNameserver@"
FC_HOST="archbox"
FC_USER="@defaultUser@"
GUEST_UID="1000"
GUEST_GID="100"
FC_PUBKEY_B64=""

for arg in $(cat /proc/cmdline); do
    case "$arg" in
        fcbox.bootstrap=*) FC_BOOTSTRAP="${arg#fcbox.bootstrap=}" ;;
        fcbox.ip=*) FC_IP="${arg#fcbox.ip=}" ;;
        fcbox.gw=*) FC_GW="${arg#fcbox.gw=}" ;;
        fcbox.dns=*) FC_DNS="${arg#fcbox.dns=}" ;;
        fcbox.host=*) FC_HOST="${arg#fcbox.host=}" ;;
        fcbox.user=*) FC_USER="${arg#fcbox.user=}" ;;
        fcbox.uid=*) GUEST_UID="${arg#fcbox.uid=}" ;;
        fcbox.gid=*) GUEST_GID="${arg#fcbox.gid=}" ;;
        fcbox.pubkey=*) FC_PUBKEY_B64="${arg#fcbox.pubkey=}" ;;
    esac
done

for mod in virtio_pci virtio_mmio virtio_blk virtio_net virtio_rng ext4 overlay af_packet i8042 atkbd; do
    /bin/modprobe -q "$mod" 2>/dev/null || true
done

if [ "$FC_BOOTSTRAP" = "1" ]; then
    i=0
    while [ ! -b /dev/vda ]; do
        i=$((i + 1))
        if [ "$i" -ge 50 ]; then
            echo "fcbox-init: timed out waiting for /dev/vda" >&2
            exec reboot -f
        fi
        sleep 0.1
    done

    j=0
    while [ ! -e /sys/class/net/eth0 ]; do
        j=$((j + 1))
        if [ "$j" -ge 30 ]; then
            echo "fcbox-init: timed out waiting for eth0" >&2
            exec reboot -f
        fi
        sleep 0.1
    done

    mount -o rw -t ext4 /dev/vda /newroot

    ip link set lo up
    ip link set eth0 up
    ip addr add "$FC_IP" dev eth0
    ip route add default via "$FC_GW"

    mkdir -p /newroot/proc /newroot/sys /newroot/dev /newroot/run /newroot/tmp
    chmod 1777 /newroot/tmp
    mount -t proc proc /newroot/proc
    mount -t sysfs sysfs /newroot/sys
    mount -t devtmpfs devtmpfs /newroot/dev
    mkdir -p /newroot/dev/pts /newroot/dev/shm
    chmod 1777 /newroot/dev/shm
    mount -t devpts devpts /newroot/dev/pts
    mount -t tmpfs tmpfs /newroot/dev/shm
    ln -sf /proc/self/mounts /newroot/etc/mtab

    chroot /newroot /bin/bash /fcbox-setup.sh || true
    sync
    umount /newroot/dev/shm /newroot/dev/pts /newroot/dev /newroot/sys /newroot/proc /newroot || true
    sync
    exec reboot -f
fi

i=0
while [ ! -b /dev/vda ] || [ ! -b /dev/vdb ] || [ ! -b /dev/vdc ]; do
    i=$((i + 1))
    if [ "$i" -ge 50 ]; then
        echo "fcbox-init: timed out waiting for /dev/vd[a-c]" >&2
        exec /bin/sh
    fi
    sleep 0.1
done

# Firecracker exposes host (st_dev, st_rdev, st_ino) as virtio-blk serial rather than drive_id,
# so verify the base image's ext4 label before mounting /dev/vda.
VDA_BLKID="$(blkid /dev/vda 2>/dev/null || true)"
case "$VDA_BLKID" in
    *'LABEL="arch-base"'*) ;;
    *)
        echo "fcbox-init: /dev/vda does not have expected label arch-base (got: $VDA_BLKID)" >&2
        exec /bin/sh
        ;;
esac

mount -o ro,noload -t ext4 /dev/vda /ro-base
mount -o rw -t ext4 /dev/vdb /rw-overlay
mkdir -p /rw-overlay/upper /rw-overlay/work

mount -t overlay overlay \
    -o "lowerdir=/ro-base,upperdir=/rw-overlay/upper,workdir=/rw-overlay/work" \
    /newroot

mkdir -p "/newroot/home/$FC_USER"
mount -o rw -t ext4 /dev/vdc "/newroot/home/$FC_USER"
chown "$GUEST_UID:$GUEST_GID" "/newroot/home/$FC_USER"

# Ensure kernel modules matching the host-provided vmlinux are visible.
if [ -d /lib/modules ]; then
    mkdir -p /newroot/usr/lib/modules
    mount --bind /lib/modules /newroot/usr/lib/modules
fi

echo "$FC_HOST" > /newroot/etc/hostname
if [ ! -s /newroot/etc/machine-id ]; then
    tr -d '-' < /proc/sys/kernel/random/uuid > /newroot/etc/machine-id
fi
mkdir -p /newroot/etc/systemd/system
ln -sf /dev/null /newroot/etc/systemd/system/systemd-firstboot.service

mkdir -p /newroot/etc/systemd/network
if [ -n "$FC_IP" ]; then
    cat > /newroot/etc/systemd/network/20-fcbox.network <<EOF
[Match]
Type=ether

[Network]
Address=$FC_IP
Gateway=$FC_GW
DNS=$FC_DNS
EOF
fi

rm -f /newroot/etc/resolv.conf
printf 'nameserver %s\n' "$FC_DNS" > /newroot/etc/resolv.conf

if [ -f /newroot/etc/shadow ]; then
    sed -i "s|^$FC_USER:!:|${FC_USER}:*:|" /newroot/etc/shadow
fi

if [ -n "$FC_PUBKEY_B64" ]; then
    mkdir -p "/newroot/home/$FC_USER/.ssh"
    printf '%s\n' "$FC_PUBKEY_B64" | base64 -d > "/newroot/home/$FC_USER/.ssh/authorized_keys"
    chmod 700 "/newroot/home/$FC_USER/.ssh"
    chmod 600 "/newroot/home/$FC_USER/.ssh/authorized_keys"
    chown -R "$GUEST_UID:$GUEST_GID" "/newroot/home/$FC_USER/.ssh"
fi

mkdir -p /newroot/proc /newroot/sys /newroot/dev /newroot/run
mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /newroot/run
mount --move /proc /newroot/proc
mount --move /sys /newroot/sys
mount --move /dev /newroot/dev

exec switch_root /newroot /sbin/init
