#!/bin/bash
# set -euo pipefail
IFS=$'\n\t'

usage() { echo "Usage: pe-pls-extension.sh -m <mode> -i <ip>" 1>&2; exit 1; }

declare mode=""
declare ip=""

# Initialize parameters specified from command line
while getopts ":m:i:" arg; do
    case "${arg}" in
        m)
            mode=${OPTARG}
        ;;
        i)
            ip=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [[ -z "$mode" ]]; then
    if [[ -z "$MODE" ]]; then
        echo "env MODE or -m is not specified "
        exit 1
    fi
    mode=$MODE
fi
if [[ -z "$ip" ]]; then
    if [[ -z "$IP" ]]; then
        echo "env IP or -i is not specified "
        exit 1
    fi
    ip=$IP
fi
echo "=========================================="
echo "==========  PE PLS EXTENSION - ==========="
echo "====  pe-pls-extension - version 1.0  ===="
echo "=========================================="
echo "============    VARIABLES    ============="
echo "=========================================="
echo " mode       = "${MODE}
echo " ip         = "${IP}
echo "=========================================="

cat > .env <<EOF
MODE=$mode
IP=$ip
EOF

cat .env

if [ $mode == 'pe' ]; then
    echo "----> PE MODE - Configuring CRON PING"
    echo "### - Installing NGINX - ###"
    apt-get update -y && apt-get upgrade -y
    apt-get install -y nginx
    echo "### - touch /var/www/html/index.html - ###"
    echo "Ping service started on " $HOSTNAME " ! Pinging : " $ip "<br>" | sudo tee -a /var/www/html/index.html
    echo "### - create ping.sh into /tmp - ###"
    cat <<'EOF' > /tmp/ping.sh
#!/bin/bash
while [ true ]
do
    curl -s -o /dev/null -w "$(date) - Status: %{http_code}\n" $1 >> /var/www/html/index.html
    echo "<br>" >> /var/www/html/index.html
    sleep 10
done
EOF
    chmod 777 /tmp/ping.sh
    echo "### - Starting ping script - ###"
    /tmp/ping.sh $ip &
    echo "----> PE MODE - Done"
fi
if [ $mode == 'pls' ]; then
    echo "----> PLS MODE - Installing NGINX..."
    apt-get update -y && apt-get upgrade -y
    apt-get install -y nginx
    echo "Hello World from host" $HOSTNAME "!" | sudo tee -a /var/www/html/index.html
    echo "----> PLS MODE - Done"
fi



