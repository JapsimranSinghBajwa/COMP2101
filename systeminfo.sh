#!/bin/bash

# Script: systeminfo.sh
# Description: Generates a system report using functions from reportfunctions.sh
# Author: Your Name
# Date: Date

# Source the function library
source reportfunctions.sh

# Function to display script usage
usage() {
    echo "Usage: $0 [-h] [-v] [-system] [-disk] [-network]"
}

# Parse command line options
while getopts ":hvn" option; do
    case "$option" in
        h) # Display help and exit
            usage
            exit 0
            ;;
        v) # Run script verbosely
            VERBOSE=true
            ;;
        system) # Run only the specified reports
            SYSTEM_REPORT=true
            ;;
        disk)
            DISK_REPORT=true
            ;;
        network)
            NETWORK_REPORT=true
            ;;
        \?) # Invalid option
            usage
            exit 1
            ;;
    esac
done

# Function to run full system report
run_full_report() {
    computerreport
    osreport
    cpureport
    ramreport
    videoreport
    diskreport
    networkreport
}

# Function to handle errors gracefully
handle_errors() {
    local error_message=$1
    if [ "$VERBOSE" = true ]; then
        # Display error to user if running verbosely
        echo "Error: $error_message" >&2
    else
        # Log error with timestamp
        errormessage "$error_message"
    fi
}

# Check for root permission
if [ "$(id -u)" -ne 0 ]; then
    handle_errors "Script must be run with root permissions. Use sudo or run as root."
    exit 1
fi

# Perform actions based on command line options
if [ "$SYSTEM_REPORT" = true ]; then
    run_full_report
elif [ "$DISK_REPORT" = true ]; then
    diskreport
elif [ "$NETWORK_REPORT" = true ]; then
    networkreport
else
    run_full_report
fi
