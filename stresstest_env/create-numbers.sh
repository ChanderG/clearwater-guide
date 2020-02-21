#!/bin/bash

echo -e "\e[31m Setting up the number of numbers... \e[0m"
num_users=50000
top_number=$(expr 2010000000 + $num_users - 1)
numbers=$(seq 2010000000 $top_number)

echo -e "\e[31m Creating the users csv... \e[0m"
filename=/tmp/users.csv
. /etc/clearwater/config; for DN in $numbers ; do
echo sip:$DN@$home_domain,$DN@$home_domain,$home_domain,7kkzTyGW ;
done > $filename

echo -e "\e[31m Creating the runner scripts... \e[0m"
/usr/share/clearwater/crest-prov/src/metaswitch/crest/tools/bulk_create.py $filename > /dev/null 2>&1

echo -e "\e[31m Editing the runner scripts to include cassandra hostname... \e[0m"
sed -i 's|cassandra-cli|cassandra-cli -h cassandra|g' /tmp/users.create_homestead.sh

echo -e "\e[31m Creating the numbers... \e[0m"
/tmp/users.create_homestead.sh
