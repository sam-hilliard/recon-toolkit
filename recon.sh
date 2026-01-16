#!/bin/bash
set -euo pipefail

log() { echo "[`date '+%H:%M:%S'`] $*"; }
die() { echo "[ERROR] $*" >&2; exit 1; }

REQUIRED_INPUTS=(wildcards.txt domains.txt)
OUTPUTS=(subdomains.txt open_ports.txt httpx_results.txt)
PORTS="22,21,25,80,443,8080,3000,139,445,3306,5432,6379,54321,5000"

for f in "${REQUIRED_INPUTS[@]}"; do
  [[ -f "$f" ]] || die "Missing required file: $f"
done

touch "${OUTPUTS[@]}"

log "Starting subdomain enumeration..."
subfinder -dL wildcards.txt -silent | dnsx -silent | anew subdomains.txt &
dnsx -d wildcards.txt -w /opt/wordlists/commonspeak2.txt -silent | anew subdomains.txt &
wait
log "Subdomain enumeration complete."

log "Starting port scanning..."
naabu -l domains.txt -p "$PORTS" -silent | anew open_ports.txt &
naabu -l subdomains.txt -p "$PORTS" -silent | anew open_ports.txt &
wait
log "Port scanning complete."

log "Starting HTTP probing..."
httpx -l domains.txt -sc -cl -ct -title -server -silent -threads 20 | anew httpx_results.txt &
httpx -l subdomains.txt -sc -cl -ct -title -server -silent -threads 20 | anew httpx_results.txt &
wait
log "HTTP probing complete."

log "Recon finished successfully."
