#!/bin/bash

if [ $# -ne 1 ]; then

  echo "Reports if a given Domain as at least one AAAA record for www.domain-name, for MX and NS."
  echo "Also checks if the domain uses DNSSEC"
  echo "Usage: $0 domain-name" >&2

  exit 1

fi

domain=$1
hostname=`echo -n "www."$domain`

dnskey=`dig dnskey $domain +short`
aaaa_rec=`host $hostname | grep : | cut -d " " -f5`
mx_rec=`dig mx $domain +short | cut -d " " -f2`
ns_rec=`dig ns $domain +short`

if [ -n "$aaaa_rec" ]; then
  host_has_v6=true
fi

if [ -n "$dnskey" ]; then
  has_dnssec=true
fi

for i in ${mx_rec[@]}; do
  mx_aaaa=`dig aaaa $i +short`
  mx_has_v6=`echo $mx_aaaa | grep :` 

  if [ -n "$mx_aaaa" ]; then
	mx_has_v6=true
  fi

done

for i in ${ns_rec[@]}; do
  ns_aaaa=`dig aaaa $i +short`

  if [ -n "$ns_aaaa" ]; then
	ns_has_v6=true
  fi

done

if [ "$has_dnssec" = true ]; then
  echo "Domain has DNSSEC"
else
  echo "Domain has no DNSSEC"
fi

if [ "$host_has_v6" = true ]; then
  echo "Host has at least one AAAA record"
else
  echo "Host has no AAAA record"
fi

if [ "$ns_has_v6" = true ]; then
  echo "At least one nameserver has an AAAA record"
else
  echo "No nameserver has an AAAA record"
fi

if [ "$mx_has_v6" = true ]; then
  echo "At least one MX has an AAAA record"
else
  echo "No MX has an AAAA record"
fi

exit 0
