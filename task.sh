#!/bin/bash
HETZNER_HOST_IP=192.168.100.2

: ${GOVC_URL?"Need to set GOVC_URL"}
: ${GOVC_USERNAME?"Need to set GOVC_USERNAME"}
: ${GOVC_PASSWORD?"Need to set GOVC_PASSWORD"}
: ${GOVC_INSECURE?"Need to set GOVC_INSECURE"}
: ${HETZNER_HOST_IP?"Need to set HETZNER_HOST_IP"}
HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD=${HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD:-90}
awk --version
hash awk 2>/dev/null || { echo >&2 "awk not installed so aborting."; exit 1; }
govc version
govc host.info -host.ipath /drinks-dc/host/drinks-cl/$HETZNER_HOST_IP

memory_value=$(govc host.info -host.ipath /drinks-dc/host/drinks-cl/$HETZNER_HOST_IP | awk '/Memory:[[:space:]]/ { print $2 }')
memory_usage_value=$(govc host.info -host.ipath /drinks-dc/host/drinks-cl/$HETZNER_HOST_IP | awk '/Memory[[:space:]]/ { print $3 }')
memory_value=${memory_value//MB/} # remove suffix
echo "Memory total:" $memory_value"MB"
echo "Memory usage:" $memory_usage_value"MB"

percent=$((200*$memory_usage_value/$memory_value % 2 + 100*$memory_usage_value/$memory_value))
echo "Percentage memory usage:" $percent"%"

if (( ${percent} > $HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD )); then
  echo >&2 "Host $HETZNER_HOST_IP has memory running at $percent. Please reduce the memory footprint by shutting down VMs"; exit 1;
fi

echo "Host $HETZNER_HOST_IP is running fine"
