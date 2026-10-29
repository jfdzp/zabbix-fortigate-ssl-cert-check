# FortiGate SSL certificate check

A Bash external check for Zabbix that reports the SSL certificate expiry of a
host (originally used against FortiGate firewalls, but it works for any TLS
endpoint).

## What it does

It connects to `host:port`, reads the presented certificate with `openssl`, and
returns a Zabbix-style JSON object with the subject, expiry date, issuer and the
**number of days left** until the certificate expires.

```json
{"data":[{"HOST":"...","PORT":"443","SUBJECT":"...","ENDDATE":"...","ISSUER":"...","DAYSLEFT":"28"}]}
```

## When to use it

To alert on certificates that are about to expire. Point an external check item
at it, extract `DAYSLEFT`, and trigger when it drops below, say, 30 or 14 days.

## Setup in Zabbix

Place the script in the Zabbix `externalscripts` directory and create an
**External check** item such as:

```
fortigate_ssl_cert_discovery.sh[{HOST.CONN},443]
```

then parse `DAYSLEFT` out of the JSON with a dependent item or preprocessing.

## Usage (standalone)

```bash
./fortigate_ssl_cert_discovery.sh example.com 443
```

## Requirements

- `openssl` available on the Zabbix server / proxy.
