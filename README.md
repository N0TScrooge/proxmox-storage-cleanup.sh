# Proxmox Storage Cleanup

A Bash script for listing and cleaning up storage entries in Proxmox VE.

## Overview

`proxmox-storage-cleanup.sh` is a simple utility script that helps Proxmox VE administrators to:

1. List all storage entries configured in Proxmox VE
2. Safely delete unwanted storage entries with confirmation prompts
3. Provide an option to delete all storage entries in a single batch

## Features

- Lists all storage entries in your Proxmox VE environment
- Confirms before proceeding with any deletion operations
- Allows deletion of individual storage entries with confirmation for each
- Provides a "delete all" option to remove all storage entries without individual prompts
- Color-coded output for better readability
- Error handling for failed operations
- Summary report after completion

## Prerequisites

- A Proxmox VE server
- Root access (script must run as root)
- `pvesm` command available (installed by default on Proxmox VE)

## Usage

1. Download the script:
   ```
   wget https://raw.githubusercontent.com/N0TScrooge/proxmox-storage-cleanup/main/proxmox-storage-cleanup.sh
   ```

2. Make it executable:
   ```
   chmod +x proxmox-storage-cleanup.sh
   ```

3. Run the script with root privileges:
   ```
   sudo ./proxmox-storage-cleanup.sh
   ```

4. Follow the on-screen prompts:
   - Confirm that you want to proceed with the operation
   - Choose whether to delete all storage entries without individual confirmation
   - For individual confirmations, answer with "yes", "no", or "quit" for each storage entry

## Important Notes

- This script only removes the storage entry from Proxmox VE configuration
- It does not delete the actual content of the storage
- Use with caution as removal operations cannot be undone
- Always ensure you have backups of important data

## Example Output

```
Getting list of Proxmox VE storage...
Found 3 storage entries in Proxmox VE:
1) local
2) local-lvm
3) nfs-share

WARNING: This script will remove Proxmox VE storage entries!
This operation cannot be undone. Content may not be deleted.
Do you want to proceed? (yes/no): yes

Do you want to delete all storage entries without asking for each one? (yes/no): no
Delete storage "local"? (yes/no/quit): no
Skipped storage: local
Delete storage "local-lvm"? (yes/no/quit): yes
Deleting storage: local-lvm
Successfully deleted storage: local-lvm
Delete storage "nfs-share"? (yes/no/quit): yes
Deleting storage: nfs-share
Successfully deleted storage: nfs-share

Operation completed. Deleted 2 of 3 storage entries.
```

## License

This project is licensed under the modified Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

Use this script at your own risk. The author is not responsible for any data loss or system damage resulting from the use of this script.

## Contributing

Feel free to submit issues or pull requests to improve this script.
