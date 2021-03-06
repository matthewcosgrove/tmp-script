#!/bin/bash

: ${GOVC_URL?"Need to set GOVC_URL"}
: ${GOVC_USERNAME?"Need to set GOVC_USERNAME"}
: ${GOVC_PASSWORD?"Need to set GOVC_PASSWORD"}
: ${GOVC_INSECURE?"Need to set GOVC_INSECURE"}
: ${HETZNER_HOST_IP?"Need to set HETZNER_HOST_IP"}
: ${HETZNER_HOST?"Need to set HETZNER_HOST"}
: ${FAILURE_RESULT_OUTPUT_FOLDER?"Need to set FAILURE_RESULT_OUTPUT_FOLDER"}
: ${FAILURE_RESULT_OUTPUT_FILE?"Need to set FAILURE_RESULT_OUTPUT_FILE"}
HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD=${HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD:-80}
echo "Percentage memory threshold:" $HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD"%"

echo "Host: " $HETZNER_HOST $HETZNER_HOST_IP

memory_value=$(govc host.info -host.ipath /drinks-dc/host/drinks-cl/$HETZNER_HOST_IP | awk '/Memory:/ { print $2 }')
memory_usage_value=$(govc host.info -host.ipath /drinks-dc/host/drinks-cl/$HETZNER_HOST_IP | awk '/Memory usage/ { print $3 }')
memory_value=${memory_value//MB/} # remove suffix
[[ -z "$memory_value" ]] && { echo "memory_value is empty" ; exit 1; }
[[ -z "$memory_usage_value" ]] && { echo "memory_usage_value is empty" ; exit 1; }
memory_value_pretty="Memory total: ${memory_value}MB"
memory_usage_value_pretty="Memory usage: ${memory_usage_value}MB"
echo $memory_value_pretty
echo $memory_usage_value_pretty

percent=$((200*$memory_usage_value/$memory_value % 2 + 100*$memory_usage_value/$memory_value))
echo "Percentage memory usage:" $percent"%"

if (( ${percent} > $HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD )); then
  output_file=$FAILURE_RESULT_OUTPUT_FOLDER/$FAILURE_RESULT_OUTPUT_FILE
  echo "Percentage memory threshold:" $HETZNER_HOST_MEMORY_PERCENTAGE_THRESHOLD"%" >> $output_file
  echo $memory_value_pretty >> $output_file
  echo $memory_usage_value_pretty >> $output_file
  msg="Host $HETZNER_HOST $HETZNER_HOST_IP has memory running at $percent%. Please reduce the memory footprint by shutting down VMs"
  echo >&2 $msg;
  echo $msg >> $output_file
  exit 1;
fi

echo "Host $HETZNER_HOST $HETZNER_HOST_IP is running fine"
