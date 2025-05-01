#!/bin/bash

# proxmox-storage-cleanup.sh
# A script to list and optionally delete all Proxmox VE storage
# Author: GitHub user
# License: CC BY-NC 4.0

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    print_message "$RED" "Error: This script must be run as root"
    exit 1
fi

# Check if we're on a Proxmox system
if ! command_exists pvesm; then
    print_message "$RED" "Error: This script must be run on a Proxmox VE system"
    exit 1
fi

# Get storage list
print_message "$BLUE" "Getting list of Proxmox VE storage..."

# Use an array to store the storage list
mapfile -t storage_array < <(pvesm status | tail -n +2 | awk '{print $1}')

# Count number of storage entries
storage_count=${#storage_array[@]}

# Check if we found any storage
if [ $storage_count -eq 0 ]; then
    print_message "$YELLOW" "No storage found in Proxmox VE"
    exit 0
fi

# Display all storage entries
print_message "$GREEN" "Found $storage_count storage entries in Proxmox VE:"
for i in "${!storage_array[@]}"; do
    echo "$((i+1))) ${storage_array[$i]}"
done

# Ask for confirmation before proceeding
echo ""
print_message "$YELLOW" "WARNING: This script will remove Proxmox VE storage entries!"
print_message "$YELLOW" "This operation cannot be undone. Content may not be deleted."
read -p "Do you want to proceed? (yes/no): " proceed_answer

# Convert answer to lowercase
proceed_answer=$(echo "$proceed_answer" | tr '[:upper:]' '[:lower:]')

# Exit if not confirmed
if [[ "$proceed_answer" != "y" && "$proceed_answer" != "yes" ]]; then
    print_message "$BLUE" "Operation cancelled."
    exit 0
fi

# Ask if user wants to delete all without asking
echo ""
read -p "Do you want to delete all storage entries without asking for each one? (yes/no): " delete_all_answer

# Convert answer to lowercase
delete_all_answer=$(echo "$delete_all_answer" | tr '[:upper:]' '[:lower:]')

# Process storage list
deleted_count=0
for storage in "${storage_array[@]}"; do
    if [[ "$delete_all_answer" == "y" || "$delete_all_answer" == "yes" ]]; then
        # Delete without asking for confirmation
        print_message "$YELLOW" "Deleting storage: $storage"
        if pvesm remove "$storage"; then
            print_message "$GREEN" "Successfully deleted storage: $storage"
            ((deleted_count++))
        else
            print_message "$RED" "Failed to delete storage: $storage"
        fi
    else
        # Ask for confirmation for each storage with explicit prompt
        print_message "$YELLOW" "Checking storage: $storage"
        while true; do
            read -p "Delete storage \"$storage\"? (yes/no/quit): " delete_answer
            
            # Convert answer to lowercase
            delete_answer=$(echo "$delete_answer" | tr '[:upper:]' '[:lower:]')
            
            # Process answer
            if [[ "$delete_answer" == "y" || "$delete_answer" == "yes" ]]; then
                print_message "$YELLOW" "Deleting storage: $storage"
                if pvesm remove "$storage"; then
                    print_message "$GREEN" "Successfully deleted storage: $storage"
                    ((deleted_count++))
                else
                    print_message "$RED" "Failed to delete storage: $storage"
                fi
                break
            elif [[ "$delete_answer" == "n" || "$delete_answer" == "no" ]]; then
                print_message "$BLUE" "Skipped storage: $storage"
                break
            elif [[ "$delete_answer" == "q" || "$delete_answer" == "quit" ]]; then
                print_message "$BLUE" "Operation cancelled. Deleted $deleted_count of $storage_count storage entries."
                exit 0
            else
                print_message "$RED" "Invalid response. Please enter yes, no, or quit."
            fi
        done
    fi
done

# Final summary
echo ""
print_message "$GREEN" "Operation completed. Deleted $deleted_count of $storage_count storage entries."
exit 0
