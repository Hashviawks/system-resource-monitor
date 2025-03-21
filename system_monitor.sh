#!/bin/bash

LOG_FILE="/var/log/system_monitor.log"
ALERT_EMAIL="abc@gmail.com"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//g')
NETWORK_USAGE=$(ifstat 1 1 | awk 'NR==3 {print $1 "KB/s Down, " $2 " KB/s UP"}')

echo "$TIMESTAMP | CPU: ${CPU_USAGE}% | MEM: ${MEM_USAGE}% | DISK: ${DISK_USAGE}% | NETWORK: $NETWORK_USAGE" >> "$LOG_FILE"

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
	echo "ALERT: High CPU usage detected: ${CPU_USAGE}%" | mail -s "CPU Usage Alert" $ALERT_EMAIL
fi

if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
	echo "ALERT: High Memory usage detected: ${MEM_USAGE}%" | mail -s "Memory Usage Alert" $ALERT_EMAIL
fi

if (( echo "$DISK_USSAGE > DISK_THRESHOLD" )); then
	echo "ALERT: High Disk usage detected: ${DISK_USAGE}%" | mail -s "Disk Usage Alert" $ALERT_EMAIL
fi

echo "System monitor completed at $TIMESTAMP"
