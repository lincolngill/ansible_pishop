#!/usr/bin/env bash
echo "Service"
echo "======="
systemctl --user status ddns_update.service
echo ""
echo "Timer"
echo "====="
systemctl --user status ddns_update.timer
echo ""
echo "Log"
echo "==="
cat "$(dirname $0)/ddns_update.log"
