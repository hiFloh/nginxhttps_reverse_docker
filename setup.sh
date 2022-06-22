#!/bin/bash

x=true
i=0

if ! [[ -n "${SSLCERT_PATH}" ]] 
then 
    SSLCERT_PATH=/var/cert/live/$HOST0/
fi
if ! [[ -n "${SSLCERT_NAME}" ]]
then 
    SSLCERT_NAME=fullchain.pem
fi
if ! [[ -n "${SSLCERT_KEY}" ]]
then 
    SSLCERT_KEY=privkey.pem
fi
        

# HOST0=storage.gapp-hsg.eu
# HOST0_DEST=app
# HOST0_PORT=80
# HOST0_TYPE=nc
# HOST1=gitlab.gapp-hsg.eu
# HOST1_DEST=192.168.40.15
# HOST2=matrix.gapp-hsg.eu
# HOST2_DEST=matrix
# HOST3=onlyoffice.gapp-hsg.eu
# HOST3_DEST=only
# HOST4=speedtest.gap-hsg.eu
# HOST4_DEST=speedtest
while $x
do
host=HOST$i
host_dest=HOST${i}_DEST
host_type=HOST${i}_TYPE
host_port=HOST${i}_PORT
port=${!host_port}
type=${!host_type}
if [[ -n "${!host}" ]]
then
    echo "start generating ${!host}"
    if ! [[ -n "${!host_dest}" ]] 
    then
        echo "ERROR ${!host} missing destination"
    else
        if ! [[ -n "${type}" ]] 
        then 
            type=default
        fi
        if ! [[ -n "${port}" ]] 
        then
            port=80
        fi
        rdi=0
        y=true
        echo ""> /tmp/redirect
        while $y
        do
            redirect=HOST${i}_REDIRECT$rdi
            if [[ -n "${!redirect}" ]]
            then
                echo "start generating ${!redirect}"
                redirectdest=HOST${i}_REDIRECT{rdi}_DEST
                if [[ -n "${!redirectdest}" ]]
                then
                    echo "s|srcPath|${!redirect}|g" >/tmp/sed
                    echo "s|destURL|${!redirectdest}|g" >>/tmp/sed
                    sed -f /tmp/sed /start/redirectTemplate.x >> /tmp/redirect
                else
                    echo "ERROR ${!redirect} missing destination"
                    y=false
                fi
            else
                echo "redirect $rdi not there"
                y=false
            fi
            ((rdi++))
        done
        echo "preapare generating config"
        echo "$i:${!host} ${!host_dest} ${type} ${port}"
        echo "s|hostname|${!host}|g" > /tmp/sed 
        echo "s|destination|${!host_dest}|g" >> /tmp/sed
        echo "s|destPort|${port}|g" >> /tmp/sed
        echo "s|certPath|${SSLCERT_PATH}|g" >> /tmp/sed
        echo "s|certName|${SSLCERT_NAME}|g" >> /tmp/sed
        echo "s|SSLCERT_KEY|${SSLCERT_KEY}|g" >> /tmp/sed
        echo "s|redirects|cat /tmp/redirect|e" >> /tmp/sed
        echo "generating config"
        sed -f /tmp/sed /start/${type}.conf > /etc/nginx/conf.d/${!host}.conf
        echo "generation done"
    fi
else
    echo "host $i not there"
  x=false
fi

((i++))

done
#cat -n /etc/nginx/conf.d/gitlab.gapp-hsg.eu.conf
ls -la /etc/nginx/conf.d/