#! /bin/bash

PSK_FILE=/etc/puppetlabs/puppet/autosign_psk

csr=$(< /dev/stdin)

# Get the certificate extension with OID $1 from the csr
function extension {
  echo "$csr" | openssl req -noout -text | fgrep -A1 "$1" | tail -n 1 \
      | sed -e 's/^ *//;s/ *$//;s/\.\.//'
}

psk=$(extension '1.3.6.1.4.1.34380.1.1.4')

echo "autosign $1 with PSK from $PSK_FILE"

if [ -f "$PSK_FILE" ]; then
  if [ -n "$psk" ]; then
    if grep -q "$psk" "$PSK_FILE"; then
        exit 0
    else
        echo "No matching PSK entry"
        exit 1
    fi
  else
    echo 'No PSK set in certificate'
    exit 1
  fi
else
    echo "Could not find PSK file"
    exit 1
fi
