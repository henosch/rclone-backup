# Backup to cloud

Simple script that uses [Rclone](https://rclone.org) to backup your important files to cloud service.

_This script was previously meant for backing up Pi-hole installation but it is universal now._

### Install

```bash
wget -O - https://raw.githubusercontent.com/jacklul/rclone-backup/master/install.sh | sudo bash
```

You must add Rclone remote called `remote` to `/etc/rclone-backup/rclone.conf` - `sudo rclone config --config /etc/rclone-backup/rclone.conf`.

Filtering rules are in `/etc/rclone-backup/backup.list` - see [here](https://rclone.org/filtering/) for more information.

If there is something you need to do before every backup you can create `/etc/rclone-backup/script.sh` script, it will be executed each time the task starts.

Any arguments passed to `rclone-backup` are passed to `rclone` command line!

# Setup for Pi-hole

_Up to date as of Pi-hole v5.2.4._

