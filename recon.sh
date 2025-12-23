#!/bin/bash
set -o pipefail

WORKDIR="${1:-.}"

for f in "$WORKDIR/wildcards.txt" "$WORKDIR/domains.txt" "$WORKDIR/commonspeak2.txt"; do
  [ -f "$f" ] || { echo "Missing required file: $f"; exit 1; }
done

PORTS="22,21,25,80,443,8080,3000,139,445,3306,5432,6379,54321,5000"

subfinder -dL "$WORKDIR/wildcards.txt" -silent | dnsx | anew "$WORKDIR/subdomains.txt" &
shuffledns -l "$WORKDIR/wildcards.txt" -w "$WORKDIR/commonspeak2.txt" | dnsx | anew "$WORKDIR/subdomains.txt" &
wait

naabu -l "$WORKDIR/domains.txt" -p "$PORTS" | anew "$WORKDIR/open_ports.txt" &
naabu -l "$WORKDIR/subdomains.txt" -p "$PORTS" | anew "$WORKDIR/open_ports.txt" &
wait

httpx -l "$WORKDIR/domains.txt" -sc -cl -ct -title -server -silent -threads 20 | anew "$WORKDIR/httpx_results.txt" &
httpx -l "$WORKDIR/subdomains.txt" -sc -cl -ct -title -server -silent -threads 20 | anew "$WORKDIR/httpx_results.txt" &
wait
