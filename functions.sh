#!/bin/bash

# Get OS Release
get_os_release() {
    # The Distribution can be Detected by looking at the Line starting with ID=...
    # Possible values: ID=fedora, ID=debian, ID=ubuntu, ...
    distribution=$(cat /etc/os-release | grep -Ei "^ID=" | sed -E "s|ID=([a-zA-Z]+?)|\1|")

    # Return Value
    echo $distribution
}

# Replace Text in Template
replace_text() {
    local lfilepath=${1}
    local lnargin=$#
    local lnparameters=$(($((${lnargin}-1)) / 2))
    local lARGV=("$@")

    # Echo / Debug
    echo "${FUNCNAME[0]} - Passed <${lnargin}> arguments and <${lnparameters}> parameter"

    # Initialize Variables
    local p=1

    for ((p=1;p<=${lnparameters};p++))
    do
        local liname=$((2*p-1))
        local livalue=$((${liname}+1))
        local lname=${lARGV[${liname}]}
        local lvalue=${lARGV[${livalue}]}

        # Echo / Debug
        echo "${FUNCNAME[0]} - Replace <{{${lname}}}> -> <${lvalue}> in <${lfilepath}>"

        # Execute Replacement
        sed -Ei "s|\{\{${lname}\}\}|${lvalue}|g" "${lfilepath}"
    done
}

# Check if Systemd Service Exists
systemd_exists() {
    # Service Name is passed as First Argument
    local lservicename=$1

    # Check if Unit File Exists
    if systemctl list-unit-files "${lservicename}" &>/dev/null
    then
       #echo "1"
       return 0
    else
       if [[ "${lservicename}" == *".service" ]]
       then
          # Service Name ends with .service already
          # Give up
          #echo "0"
          return 1
       else
          # Test Again with .service added at the End of the Service Name
          systemd_exists "${lservicename}.service"
       fi
    fi
}

# Check if Systemd Service is Masked
systemd_ismasked() {
    # Service Name is passed as First Argument
    local lservicename=$1

    # Get Status
    local lstatus=$(systemctl show "${lservicename}" --property=UnitFileState --value)

    # Check
    if [[ "${lstatus}" == "masked" ]]
    then
        # Service is masked
        #echo "1"
        return 0
    else
        # Service is NOT masked
        #echo "0"
        return 1
    fi
}

# Check if Systemd Service is NOT Masked
systemd_isnotmasked() {
    # Service Name is passed as First Argument
    local lservicename=$1

    # Check if Masked
    systemd_ismasked "${lservicename}"
    local lismasked=$?

    # Reverse the Logic
    if [[ ${lismasked} -eq 0 ]]
    then
        # Service is masked
        #echo "1"
        return 1
    else
        # Service is NOT masked
        #echo "0"
        return 0
    fi
}

# Check if Systemd Service Exists and is NOT Masked
systemd_exists_isnotmasked() {
    # Service Name is passed as First Argument
    local lservicename=$1

    if systemd_exists "${lservicename}" && systemd_isnotmasked "${lservicename}"
    then
        #echo "1"
        return 0
    else
        #echo "0"
        return 1
    fi
}

# Get Disk Reference from Disk Configuration in config.sh
get_disk_reference() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Disk Name
    local ldisk_name
    ldisk_name=$(echo "${ldisk_config}" | cut -d "|" -f 1)

    # Return Value
    echo "${ldisk_name}"
}

# Get Disk Partition Number from Disk Configuration in config.sh
get_disk_partition_number() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Partition number
    local lpartition_number
    lpartition_number=$(echo "${ldisk_config}" | cut -d "|" -f 2)

    # Check if Value is empty
    if [[ -z "${lpartition_number}" ]]
    then
        # Default to lukspartnumber
        # Need to solve Circular Dependency ...
        #
        # Default to Partition 1 for now at least
        lpartition_number=1
    fi

    # Return Value
    echo "${lpartition_number}"
}

# Get Device Mapper Name from Disk Configuration in config.sh
get_device_mapper_name() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Device Mapper Name
    local ldm_name
    ldm_name=$(echo "${ldisk_config}" | cut -d "|" -f 3)

    # Check if Value is empty
    # if [[ -z "${ldm_name}" ]]
    # then
    #     # Default to ...
    #     ldm_name=""
    # fi

    # Add "_crypt" Suffix
    ldm_name="${ldm_name}_crypt"

    # Return Value
    echo "${ldm_name}"
}
