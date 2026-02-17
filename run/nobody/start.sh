#!/usr/bin/dumb-init /bin/bash

# no config bind mount
if [[ ! -d "/config" ]]; then
	echo "[crit] /config bind mount not found, exiting..." ; exit 1
fi

# define config and database paths
filebrowser_install_path="/opt/filebrowser"
config_path="/config/filebrowser"
cert_path="${config_path}/certs"
database_path="${config_path}/database"
cache_path="${config_path}/cache"

# create config, database and cache paths
mkdir -p \
	"${cert_path}" \
	"${config_path}" \
	"${database_path}" \
	"${cache_path}"

# setup certs if TLS is enabled, then run filebrowser with appropriate options
if [[ "${ENABLE_TLS}" == 'yes' ]]; then
	# define cert paths
	cert_filepath="${cert_path}/cert.pem"
	key_filepath="${cert_path}/key.pem"

	# define cert option
	cert_option="--cert ${cert_filepath}"
	key_option="--key ${key_filepath}"

	# create certs if they do not exist
	if [[ ! -f "${cert_filepath}" ]] || [[ ! -f "${key_filepath}" ]]; then
		echo "[info] TLS enabled but cert/key not found, creating self-signed cert/key pair..."
		if ! openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout "${key_filepath}" -out "${cert_filepath}" -subj "/CN=localhost"; then
			echo "[warn] Failed to create cert/key pair, disabling TLS..."
			cert_option=""
			key_option=""
		fi
	fi
else
	# if TLS is not enabled then set cert and key paths to empty string to avoid filebrowser erroring on startup
	cert_option=""
	key_option=""
fi

# run
"${filebrowser_install_path}/filebrowser" \
	--username "${FILEBROWSER_USERNAME}" \
	--password "${FILEBROWSER_PASSWORD}" \
	--address '0.0.0.0' \
	--baseURL "${FILEBROWSER_BASEURL}" \
	--port '8125' \
	--root "${FILEBROWSER_ROOT}" \
	"${cert_option}" \
	"${key_option}" \
	--config "${config_path}/config.json" \
	--database "${database_path}/filebrowser.db" \
	--cacheDir "${cache_path}"
