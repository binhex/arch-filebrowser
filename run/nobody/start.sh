#!/usr/bin/dumb-init /bin/bash

# no config bind mount
if [[ ! -d "/config" ]]; then
	echo "[crit] /config bind mount not found, exiting..." ; exit 1
fi

# define config and database paths
filebrowser_install_path="/opt/filebrowser"
config_root="/config/filebrowser"
config_path="${config_root}/config"
cert_path="${config_root}/certs"
database_path="${config_root}/database"
cache_path="${config_root}/cache"

# create config, database and cache paths
mkdir -p \
	"${config_root}" \
	"${config_path}" \
	"${cert_path}" \
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

# hash the initial password using filebrowser's built in hashing function, this
# must be done, you cannot just pass the password in plain text, otherwise you
# will get the error 'invalid credentials' when trying to login to filebrowser
hashed_password="$("${filebrowser_install_path}/filebrowser" hash 'filebrowser')"

# set auth method based on ENABLE_AUTHENTICATION variable
if [[ "${ENABLE_AUTHENTICATION}" == 'no' ]]; then
	auth_method="noauth"
else
	auth_method="json"
fi

# configure options for filebrowser, this must be done BEFORE filebrowser runs,
# otherwise you recieve the error 'timeout'
#
# set authentication method based on ENABLE_AUTHENTICATION variable
"${filebrowser_install_path}/filebrowser" \
	config set --auth.method="${auth_method}" \
	--config "${config_path}/settings.json" \
	--database "${database_path}/filebrowser.db"

# run filebrowser with appropriate options
"${filebrowser_install_path}/filebrowser" \
	--username 'admin' \
	--password "${hashed_password}" \
	--address '0.0.0.0' \
	--baseURL "${FILEBROWSER_BASEURL}" \
	--port '8125' \
	--root "${FILEBROWSER_ROOT}" \
	${cert_option} \
	${key_option} \
	--config "${config_path}/settings.json" \
	--database "${database_path}/filebrowser.db" \
	--cacheDir "${cache_path}"
