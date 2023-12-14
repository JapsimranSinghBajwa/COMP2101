#!/bin/bash

# Function to save error message with a timestamp into a logfile
errormessage() {
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local error_message=$1
    echo "$timestamp - $error_message" >> /var/log/systeminfo.log
    echo "Error: $error_message" >&2
}

# Function to generate CPU report
cpureport() {
    echo "=== CPU Report ==="
    echo "CPU Manufacturer and Model: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)"
    echo "CPU Architecture: $(lscpu | grep "Architecture" | cut -d':' -f2 | xargs)"
    echo "CPU Core Count: $(lscpu | grep "Core(s) per socket" | cut -d':' -f2 | xargs)"
    echo "CPU Maximum Speed: $(lscpu | grep "Max Speed" | cut -d':' -f2 | xargs)"
    echo "Cache Sizes:"
    echo "  L1 Cache: $(lscpu | grep "L1d cache" | cut -d':' -f2 | xargs)"
    echo "  L2 Cache: $(lscpu | grep "L2 cache" | cut -d':' -f2 | xargs)"
    echo "  L3 Cache: $(lscpu | grep "L3 cache" | cut -d':' -f2 | xargs)"
}

# Function to generate Computer report
computerreport() {
    echo "=== Computer Report ==="
    echo "Computer Manufacturer: $(dmidecode -s system-manufacturer)"
    echo "Computer Model: $(dmidecode -s system-product-name)"
    echo "Computer Serial Number: $(dmidecode -s system-serial-number)"
}

# Function to generate OS report
osreport() {
    echo "=== OS Report ==="
    echo "Linux Distro: $(lsb_release -d | cut -d':' -f2 | xargs)"
    echo "Distro Version: $(lsb_release -r | cut -d':' -f2 | xargs)"
}

# Function to generate RAM report
ramreport() {
    echo "=== RAM Report ==="
    echo "Installed Memory Components:"
    echo "Manufacturer | Model | Size | Speed | Location"
    echo "------------------------------------------------"
    dmidecode -t memory | grep -A6 "Memory Device" | awk 'NR%7==1 {manufacturer=$2} NR%7==2 {model=$2} NR%7==3 {size=$2} NR%7==4 {speed=$2} NR%7==6 {print manufacturer" | "model" | "size" | "speed" | "$2}' | column -t
    echo "Total Installed RAM: $(free -h | grep "Mem:" | awk '{print $2}')"
}

# Function to generate Video report
videoreport() {
    echo "=== Video Report ==="
    echo "Video Card/Chipset Manufacturer: $(lspci | grep VGA | cut -d':' -f3 | xargs)"
    echo "Video Card/Chipset Description or Model: $(lspci | grep VGA | cut -d':' -f3- | xargs)"
}

# Function to generate Disk report
diskreport() {
    echo "=== Disk Report ==="
    echo "Installed Disk Drives:"
    echo "Manufacturer | Model | Size | Partition | Mount Point | Filesystem Size | Filesystem Free Space"
    echo "---------------------------------------------------------------------------------------------"
    lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINT | awk '$1~/^sd/ {print $2" | "$3" | "$4" | "$1" | "$5" | "$6}' | column -t
}

# Function to generate Network report
networkreport() {
    echo "=== Network Report ==="
    echo "Installed Network Interfaces:"
    echo "Manufacturer | Model/Description | Link State | Current Speed | IP Addresses | Bridge Master | DNS Servers | Search Domains"
    echo "-----------------------------------------------------------------------------------------------------------------------"
    ip -o link show | awk '$2!="lo:" {print $2}' | xargs -n1 ip -o addr show | \
        awk '{print $2" | "$3" | "$9" | "$10" | "$4}' | \
        column -t -s "|" | xargs -n8 bash -c 'echo $0 | grep -q "master" && echo " | Yes" || echo " | No"'
}

# Example usage of error message function
# errormessage "This is an error message."

# Uncomment the following lines for testing each report function individually
# cpureport
# computerreport
# osreport
# ramreport
# videoreport
# diskreport
# networkreport
