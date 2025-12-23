#!/bin/bash
#
# Disk Expansion Debug Script
# Run this inside the VM to diagnose disk expansion issues
#

echo "========================================="
echo "DISK EXPANSION DEBUG INFORMATION"
echo "========================================="
echo ""

echo "1. Root filesystem mount:"
echo "-------------------------"
findmnt -n -o SOURCE /
echo ""

echo "2. Root device extraction:"
echo "-------------------------"
root_mount=$(findmnt -n -o SOURCE /)
echo "Root mount: $root_mount"
root_device=$(echo "$root_mount" | sed -E 's/p?[0-9]+$//')
echo "Root device: $root_device"
part_num=$(echo "$root_mount" | grep -o '[0-9]*$')
echo "Partition number: $part_num"
echo ""

echo "3. Block device info:"
echo "-------------------------"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""

echo "4. Disk size (raw bytes):"
echo "-------------------------"
if [ -n "$root_device" ] && [ -b "$root_device" ]; then
    disk_size=$(blockdev --getsize64 "$root_device" 2>/dev/null || echo "0")
    disk_size_gb=$((disk_size / 1024 / 1024 / 1024))
    echo "Total disk size: $disk_size bytes ($disk_size_gb GB)"
else
    echo "ERROR: Cannot read device $root_device"
fi
echo ""

echo "5. Partition table:"
echo "-------------------------"
if [ -n "$root_device" ] && [ -b "$root_device" ]; then
    parted -s "$root_device" unit B print 2>/dev/null || echo "parted command failed"
else
    echo "ERROR: Device not found"
fi
echo ""

echo "6. Partition end position:"
echo "-------------------------"
if [ -n "$root_device" ] && [ -b "$root_device" ] && [ -n "$part_num" ]; then
    part_end=$(parted -s "$root_device" unit B print 2>/dev/null | grep "^ $part_num" | awk '{print $3}' | sed 's/B//')
    if [ -n "$part_end" ]; then
        part_end_gb=$((part_end / 1024 / 1024 / 1024))
        echo "Partition $part_num ends at: $part_end bytes ($part_end_gb GB)"
    else
        echo "ERROR: Could not find partition $part_num in parted output"
        echo "Trying to show all partitions:"
        parted -s "$root_device" unit B print 2>/dev/null | grep "^ "
    fi
else
    echo "ERROR: Missing device or partition number"
fi
echo ""

echo "7. Unallocated space calculation:"
echo "-------------------------"
if [ -n "$disk_size" ] && [ -n "$part_end" ] && [ "$disk_size" != "0" ] && [ -n "$part_end" ]; then
    unallocated=$((disk_size - part_end))
    unallocated_gb=$((unallocated / 1024 / 1024 / 1024))
    unallocated_mb=$((unallocated / 1024 / 1024))
    echo "Unallocated: $unallocated bytes ($unallocated_gb GB / $unallocated_mb MB)"
    if [ $unallocated -gt 524288000 ]; then
        echo "STATUS: ✅ More than 500MB unallocated - expansion should work"
    else
        echo "STATUS: ❌ Less than 500MB unallocated - won't auto-expand"
    fi
else
    echo "ERROR: Cannot calculate unallocated space"
    echo "  disk_size: $disk_size"
    echo "  part_end: $part_end"
fi
echo ""

echo "8. Current disk usage:"
echo "-------------------------"
df -h /
echo ""

echo "========================================="
echo "DIAGNOSIS COMPLETE"
echo "========================================="
