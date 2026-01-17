#!/bin/bash

REQUIRED_INPUTS=(wildcards.txt domains.txt)
PORTS="22,21,25,80,443,8080,3000,139,445,3306,5432,6379,54321,5000"

for f in "${REQUIRED_INPUTS[@]}"; do
  [[ -f "$f" ]] || die "Missing required file: $f"
done

subfinder -dL wildcards.txt \
  | anew subdomains.txt

naabu -l domains.txt -p "$PORTS" \
  | anew open_ports.txt

naabu -l subdomains.txt -p "$PORTS" \
  | anew open_ports.txt

httpx -l domains.txt -sc -cl -ct -title -server -threads 20 \
  | anew httpx_results.txt

httpx -l subdomains.txt -sc -cl -ct -title -server -threads 20 \
  | anew httpx_results.txt
