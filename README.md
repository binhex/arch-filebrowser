# Application

[File Browser](https://github.com/filebrowser/filebrowser)

## Description

File Browser provides a file managing interface within a specified directory.
It can be used to upload, delete, preview and edit files from a web browser.

## Build notes

Latest GitHub release.

## Usage

```bash
docker run -d \
        --name=<container name> \
        -p <webui port>:8125 \
        -v <path for config files>:/config \
        -v <path for files>:/media \
        -v /etc/localtime:/etc/localtime:ro \
        -e FILEBROWSER_USERNAME=<username> \
        -e FILEBROWSER_PASSWORD=<password> \
        -e FILEBROWSER_ROOT=</media path to expose> \
        -e FILEBROWSER_BASEURL=<base url> \
        -e ENABLE_TLS=<yes|no> \
        -e ENABLE_HEALTHCHECK=<yes|no> \
        -e HEALTHCHECK_COMMAND=<command> \
        -e HEALTHCHECK_ACTION=<action> \
        -e HEALTHCHECK_HOSTNAME=<hostname> \
        -e UMASK=<umask for created files> \
        -e PUID=<uid for user> \
        -e PGID=<gid for user> \
        ghcr.io/binhex/arch-filebrowser
```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access application

`http://<host ip>:8125`

Default username/password: `admin/filebrowser`

## Example

```bash
docker run -d \
        --name=filebrowser \
        -p 8125:8125 \
        -v /apps/docker/filebrowser:/config \
        -v /mnt/user:/media \
        -v /etc/localtime:/etc/localtime:ro \
        -e FILEBROWSER_USERNAME=admin \
        -e FILEBROWSER_PASSWORD=filebrowser \
        -e FILEBROWSER_ROOT=/media \
        -e FILEBROWSER_BASEURL=/ \
        -e ENABLE_TLS=no \
        -e UMASK=000 \
        -e PUID=99 \
        -e PGID=100 \
        ghcr.io/binhex/arch-filebrowser
```

## Notes

- Set `FILEBROWSER_ROOT` to the path you want visible in the File Browser UI
    (for example `/media`).
- If `ENABLE_TLS=yes`, self-signed certificates are auto-generated in
    `/config/filebrowser/certs` if missing.

User ID (PUID) and Group ID (PGID) can be found by issuing the following
command for the user you want to run the container as:-

```bash
id <username>
```

___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/THREAD/)
