#!/bin/bash
#
# FortiGate SSL certificate discovery / check (Zabbix external check).
#
# Connects to a host:port, reads the presented certificate with openssl and
# returns a Zabbix-style JSON object with the subject, expiry date, issuer and
# the number of days left until expiry.
#
# Usage: fortigate_ssl_cert_discovery.sh <HOST> <PORT>

HOST="$1"
PORT="${2:-443}"

if [ -z "$HOST" ]; then
    echo '{"data":[]}'
    exit 1
fi

# Fetch certificate details via openssl
CERT_INFO=$(echo | timeout 10 openssl s_client -connect "$HOST:$PORT" -servername "$HOST" 2>/dev/null \
    | openssl x509 -noout -subject -enddate -issuer 2>/dev/null)

if [ -z "$CERT_INFO" ]; then
    echo '{"data":[]}'
    exit 1
fi

SUBJECT=$(echo "$CERT_INFO" | grep "^subject" | sed 's/subject=//')
END_DATE=$(echo "$CERT_INFO" | grep "^notAfter" | sed 's/notAfter=//')
ISSUER=$(echo "$CERT_INFO" | grep "^issuer" | sed 's/issuer=//')

# Days remaining until expiry
END_EPOCH=$(date -d "$END_DATE" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (END_EPOCH - NOW_EPOCH) / 86400 ))

echo "{\"data\":[{\"HOST\":\"$HOST\",\"PORT\":\"$PORT\",\"SUBJECT\":\"$SUBJECT\",\"ENDDATE\":\"$END_DATE\",\"ISSUER\":\"$ISSUER\",\"DAYSLEFT\":\"$DAYS_LEFT\"}]}"
