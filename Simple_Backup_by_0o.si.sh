#!/bin/bash

# Function to list available partitions
list_partitions() {
  echo " "
  echo "Available partitions:"
  echo " "
  lsblk -o NAME,FSTYPE,SIZE,LABEL,UUID,MOUNTPOINT | grep -v "loop"
}

# Function to list available image files
list_image_files() {
  echo " "
  echo "Available image files:"
  echo " "
  find "$image_folder" -type f -name "*.iso" -o -name "*.iso.gz"
}

host_name=$(hostname)
echo " "
echo "                 << SIMPLE_BACKUP_v1.00 by 0o.SI  >>"
echo " "
echo " "
read -p "Please Enter b for Backup or r for Restoring: " choice

# Backup option
if [ "$choice" == "b" ]; then
  list_partitions
  echo " "
  read -p "Enter the name of the partition to backup (e.g. sda1): " source_partition
  if ! lsblk | grep -q "$source_partition"; then
    echo "Invalid partition name. Please try again."
    exit 1
  fi
  echo " "
  read -p "Enter the name of the partition where to store the backup file (e.g. sda2 or mmcblk0p1): " destination_partition
  if ! lsblk | grep -q "$destination_partition"; then
    echo "Invalid partition name. Please try again."
    exit 1
  fi
  echo " "
# Create a temporary mount point
tmp_mount_point="/mnt/tmp"

# Mount the destination partition at the temporary mount point
sudo mkdir -p "$tmp_mount_point"
sudo mount /dev/$destination_partition "$tmp_mount_point"

# Create the /Backup directory at the root of the partition
backup_folder="$tmp_mount_point/Backup/$host_name"
if [ ! -d "$tmp_mount_point/Backup" ]; then
  sudo mkdir -p "$tmp_mount_point/Backup"
fi
if [ ! -d "$backup_folder" ]; then
  sudo mkdir -p "$backup_folder"
fi
  
  read -p "Do you want to compress the image file with gzip? (y/n): " compress
  timestamp=$(date +"%d.%m.%Y_%H%M")
  filename="$source_partition.$timestamp.iso"
  sudo dd if=/dev/$source_partition of="$backup_folder/$filename" bs=4M status=progress conv=sparse
  if [ "$compress" == "y" ]; then
    sudo gzip "$backup_folder/$filename"
  fi
  echo "Image file created successfully."
sudo umount "$tmp_mount_point"
sudo rmdir "$tmp_mount_point"

# Restore option
elif [ "$choice" == "r" ]; then
  list_partitions
  echo " "
  read -p "Enter the name of the partition you want to restore (e.g. sdb1): " restore_partition
  if ! lsblk | grep -q "$restore_partition"; then
    echo "Invalid partition name. Please try again."
    exit 1
  fi
  echo " "
  read -p "Enter the name of the partition where the image file is located (e.g. sdb1): " image_partition
  if ! lsblk | grep -q "$image_partition"; then
    echo "Invalid partition name. Please try again."
    exit 1
  fi
  echo " "

# Create a temporary mount point
tmp_mount_point="/mnt/tmp"

# Mount the destination partition at the temporary mount point
sudo mkdir -p "$tmp_mount_point"
sudo mount /dev/$image_partition "$tmp_mount_point"

# Create the /Backup directory at the root of the partition
image_folder="$tmp_mount_point/Backup/$host_name"
  list_image_files
  read -p "Enter the name of the image file to restore (e.g. sda1-2023-03-01_12-00-00.iso.gz): " image_file
  if [ ${image_file: -3} == ".gz" ]; then
    sudo gunzip "$image_folder/$image_file"
    image_file=${image_file::-3}
  fi
  sudo dd if="$image_folder/$image_file" of=/dev/$restore_partition bs=4M status=progress
  sudo umount "$tmp_mount_point"
  sudo rmdir "$tmp_mount_point"
  echo "Image file restored successfully."
else
  echo "Invalid choice. Please try again."
fi

