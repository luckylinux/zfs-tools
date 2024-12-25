#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Need Root / `sudo` Access Permissions to read SMART Attributes
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# Source: https://askubuntu.com/questions/865792/how-can-i-monitor-the-tbw-on-my-samsung-ssd
ON_TIME_TAG="Power_On_Hours"
LBAS_WRITTEN_TAG="Total_LBAs_Written"
LBA_SIZE=512 # Value in bytes

# On some SSDs the Wear Count is defined like this
# WEAR_COUNT_TAG="Wear_Leveling_Count"

# On Crucial MX500 the Wear Count is defined like this
WEAR_COUNT_TAG="Percent_Lifetime_Remain"


BYTES_PER_MB=1048576
BYTES_PER_GB=1073741824
BYTES_PER_TB=1099511627776

# For each device
for disk in "${disks[@]}"
do
   # Echo
   echo "Drive ${disk}"

   # Read all Attributes
   attributes=$(smartctl --attributes /dev/disk/by-id/${disk})

   # Get Written LBAs
   lbas_written=$(echo "${attributes}" | grep "${LBAS_WRITTEN_TAG}" | awk '{print $10}')

   # Debug
   # echo "Attributes: ${attributes}"
   # echo "LBAS Written: ${lbas_written}"

   wear_count=$(echo "${attributes}" | grep "${WEAR_COUNT_TAG}" | awk '{print $4}' | sed 's/^0*//')
   on_time=$(echo "${attributes}" | grep "${ON_TIME_TAG}" | awk '{print $10}')

   # Convert LBAs -> bytes
   B_written=$(echo "${lbas_written} * ${LBA_SIZE}" | bc)
   MB_written=$(echo "scale=3; ${B_written} / ${BYTES_PER_MB}" | bc)
   GB_written=$(echo "scale=3; ${B_written} / ${BYTES_PER_GB}" | bc)
   TB_written=$(echo "scale=3; ${B_written} / ${BYTES_PER_TB}" | bc)

   # Get Firmware Version
   fw_version=$(smartctl -a /dev/disk/by-id/${disk} | grep -i Firmware | awk '{print $3}')

   # Echo
   echo -e "\t------------------------------"
   echo -e "\t SSD Status:   ${disk}"
   echo -e "\t------------------------------"
   echo -e "\t Firmware Version: ${fw_version}"
   echo -e "\t------------------------------"
   echo -e "\t On time:      $(echo ${on_time} | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta') hr"
   echo -e "\t------------------------------"
   echo -e "\t Data written:"
   echo -e "\t           MB: $(echo ${MB_written} | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
   echo -e "\t           GB: $(echo ${GB_written} | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
   echo -e "\t           TB: $(echo ${TB_written} | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
   echo -e "\t------------------------------"
   echo -e "\t Mean write rate:"
   echo -e "\t        MB/hr: $(echo "scale=3; ${MB_written} / ${on_time}" | bc | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
   echo -e "\t------------------------------"
   echo -e "\t Drive health: ${wear_count} %"
   echo -e "\t------------------------------"

   # One-liner for written LBAs
   # echo "GB Written: $(echo "scale=3; $(sudo /usr/sbin/smartctl -A /dev/disk/by-id/${disk} | grep "Total_LBAs_Written" | awk '{print $10}') * 512 / 1073741824" | bc | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')"
done
