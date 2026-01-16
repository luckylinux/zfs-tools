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
    # ldisk_name=$(echo "${ldisk_config}" | cut -d "|" -f 1)
    ldisk_name=$(echo "${ldisk_config}" | awk -F"|" '{print $1}')

    # Return Value
    echo "${ldisk_name}"
}

# Get Disk Reference from Disk Configuration in config.sh
# (Alias)
get_disk_name() {
    get_disk_reference "$1"
}

# Get Disk Partition Number from Disk Configuration in config.sh
get_disk_partition_number() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Partition number
    local lpartition_number
    #lpartition_number=$(echo "${ldisk_config}" | cut -d "|" -f 2)
    lpartition_number=$(echo "${ldisk_config}" | awk -F"|" '{print $2}')

    # Check if Value is empty
    if [[ -z "${lpartition_number}" ]]
    then
        # Print warning
        # log_warning "Partition Number was not defined in Configuration. Defaulting to Partition Number = 1."

        # Default to lukspartnumber
        # Need to solve Circular Dependency ...
        #
        # Default to Partition 1 for now at least
        lpartition_number=1
    fi

    # Return Value
    echo "${lpartition_number}"
}

# Get Device Mapper Suffix from Disk Configuration in config.sh
get_device_mapper_suffix() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Device Mapper Suffix
    local ldm_suffix
    #ldm_suffix=$(echo "${ldisk_config}" | cut -d "|" -f 3)
    ldm_suffix=$(echo "${ldisk_config}" | awk -F"|" '{print $3}')

    # Check if Value is empty
    if [[ -z "${ldm_suffix}" ]]
    then
        # Default to Suffix "default"
        ldm_suffix="default"
    fi

    # Return Value
    echo "${ldm_suffix}"
}

# Get Device Reference (from Configuration Entry)
get_device_reference() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Disk Reference
    local ldisk_reference
    ldisk_reference=$(get_disk_reference "${ldisk_config}")

    # Get Partition Number
    local lpartition_number=$(get_disk_partition_number "${ldisk_config}")

    # Declare Variable
    local ldevice_reference

    # Compute Value
    ldevice_reference=$(get_device_reference_name_number "${ldisk_reference}" ${lpartition_number})

    # Return Value
    echo "${ldevice_reference}"
}

# Get Device Reference (from Disk Name & Partition Number)
get_device_reference_name_number() {
    # Input Arguments
    local ldisk_reference="$1"
    local lpartition_number="$2"

    # Declare Variable
    local ldevice_reference

    # If Partition Number is Zero, then we use the entire Disk
    if [ ${lpartition_number} -eq 0 ]
    then
        ldevice_reference="/dev/disk/by-id/${ldisk_reference}"
    else
        ldevice_reference="/dev/disk/by-id/${ldisk_reference}-part${lpartition_number}"
    fi

    # Return Value
    echo "${ldevice_reference}"
}

# Get Device Mapper Name from Disk Configuration in config.sh
get_device_mapper_name() {
    # Input Arguments
    local ldisk_config="$1"

    # Get Disk Name
    local ldisk_name
    ldisk_name=$(get_disk_name "${ldisk_config}")

    # Get Device Mapper Name
    local ldm_name
    ldm_name=$(get_device_mapper_suffix "${ldisk_config}")

    # Check if Value is empty
    # if [[ -z "${ldm_name}" ]]
    # then
    #     # Default to ...
    #     ldm_name=""
    # fi

    # Add "_crypt" Suffix
    ldm_name="${ldm_name}_crypt"

    # Add Disk Name Prefix
    ldm_name="${ldisk_name}_${ldm_name}"

    # Return Value
    echo "${ldm_name}"
}

# Check if any Tang Server is answering
tang_server_online() {
    # Input Arguments
    local ldevice="$1"

    # Get the list of Tang Servers
    # mapfile -t clevis_lines < <(clevis luks list -d ${ldevice} | sed -E "s|.*?\"http://([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\".*$|\1.\2.\3.\4|")

    # Get the list of Tang Servers
    mapfile -t clevis_lines < <(clevis luks list -d ${ldevice})

    # Extract Data
    tang_servers=()
    for clevis_line in "${clevis_lines[@]}"
    do
        # Match Pattern
        echo "${clevis_line}" | grep -Eq "[0-9]+: tang"
        is_tang_server=$?

        if [ ${is_tang_server} -eq 0 ]
        then
            # Try to get "tang" Type Entry - Begins with [0-9]+\. tang '{...}'
            mapfile -t clevis_current_servers < <(echo "${clevis_line}" | sed -E "s|^[0-9]+:\s?tang\s?'(.+)'|\1|g" | jq -r ".url")
        else
            # Try to get "sss" Type Entry - Begings with [0-9]+\. sss '{....}'
            mapfile -t clevis_current_servers < <(echo "${clevis_line}" | sed -E "s|^[0-9]+:\s?sss\s?'(.+)'|\1|g" | jq -r ".pins.tang.[].url")
        fi

        for s in "${clevis_current_servers[@]}"
        do
            # Debug
            echo "[DEBUG] Found Tang Server ${s} via Clevis"

            # Add to Array
            tang_servers+=("${s}")
        done
    done

    # Initialize Status Code
    overall_status=1
    tang_count_replied=0

    for tang_server in "${tang_servers[@]}"
    do
        # Echo
        # echo "[DEBUG] Processing Tang Server ${tang_server}"

        # Try to ping Device
        # ping -c4 "${tang_server}" > /dev/null

        # Save exit Code
        # tang_status=$?

        # Ping
        #if [ $? != 0 ]
        #then
        #    # Error - Tang Server was not reachable
        #    echo "[ERROR]: couldn't ping Tang Server at ${tang_server}"
        #else
        #    # OK
        #    echo "[INFO]: Tang Server ${target_status} is online"
        #fi

        # Define Server URL
        echo "${tang_server}" | grep -Eq "^http://"

        if [ $? -eq 0 ]
        then
            # Protocol "http://" is already within the tang_server, only need to add "/adv", NOT "http://"
            tang_server_url="${tang_server}/adv"

        else
            # Protocol "http://" is NOT within the tang_server, add both "http://" and "/adv"
            tang_server_url="http://${tang_server}/adv"
        fi

        # Use CURL to try the Advertisement
        http_code=$(curl -w "%{http_code}" "${tang_server_url}" -s --connect-timeout 5.0 -o /dev/null)

        if [[ "${http_code}" == "200" ]]
        then
            # OK
            echo "[INFO]: Tang Server ${tang_server} is online and answering at ${tang_server_url}"

            # Set status
            overall_status=0

            # Increment Counter of Servers that replied
            tang_count_replied=$((tang_count_replied+1))
        else
            # Error - Tang Server wasn't reachable or didn't answer in a valid Manner
            echo "[ERROR]: Tang Server didn't provide a Valid Response at ${tang_server_url} - HTTP Status Code was ${http_code}"
        fi
    done

    # Return Exit Code
    return ${overall_status}
}
