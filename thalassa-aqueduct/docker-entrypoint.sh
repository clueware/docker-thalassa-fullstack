#!/bin/sh
haproxy -qD -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
thalassa-aqueduct --debug --thalassaHost thalassa --thalassaPort 5001 --thalassaApiPort 9000
