#!/bin/bash

echo "Updating local_ip in the local_config..."
sed -i "s|local_ip=.*|local_ip=$(hostname -I)|g" /etc/clearwater/local_config

echo "Update home domain in the shared_config..."
sed -i "s|home_domain=.*|home_domain=$ZONE|g" /etc/clearwater/shared_config

echo "Add bono_servers key in the shared_config..."
sed -i "2ibono_servers=bono" /etc/clearwater/shared_config

echo "Prepare the users file..."
/usr/share/clearwater/infrastructure/scripts/sip-stress

echo "Increace timeout to avoid repeated runs..."
sed -i "s/  sleep 60/\ \ sleep 10m/g" /usr/share/clearwater/bin/sip-stress

echo "Disable automatic re-run of clearwater-infrastructure..."
sed -i "s/\(^\s*\)service/\1# service/" /etc/init.d/clearwater-sip-stress
