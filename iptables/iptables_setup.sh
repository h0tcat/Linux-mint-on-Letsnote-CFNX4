!#/bin/bash
iptables -A INPUT -m state --state NEW,INVALID -j DROP
