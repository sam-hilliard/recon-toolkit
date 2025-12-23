#!/bin/bash
set -o pipefail

for f in wildcards.txt domains.txt /opt/wordlists/commonspeak2.txt; do
  [ -f "$f" ] || { echo "Missing required file: $f"; exit 1; }
done

PORTS="22,21,25,80,443,8080,3000,139,445,3306,5432,6379,54321,5000"

subfinder -dL wildcards.txt -silent | dnsx | anew subdomains.txt &
shuffledns -l wildcards.txt -w /opt/wordlists/commonspeak2.txt | dnsx | anew subdomains.txt &
wait

naabu -l domains.txt -p "$PORTS" | anew open_ports.txt &
naabu -l subdomains.txt -p "$PORTS" | anew open_ports.txt &
wait

httpx -l domains.txt -sc -cl -ct -title -server -silent -threads 20 | anew httpx_results.txt &
httpx -l subdomains.txt -sc -cl -ct -title -server -silent -threads 20 | anew httpx_results.txt &
wait
