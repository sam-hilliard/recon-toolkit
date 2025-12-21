#!/bin/bash

subfinder -silent | anew subdomains.txt

cat subdomains.txt | shuffledns -w /opt/wordlists/commonspeak2.txt -r resolvers.txt | anew resolved_subdomains.txt

cat resolved_subdomains.txt | naabu -p 22,21,25,80,443,8080,3000,139,445,3306,5432,6379,54321,5000 | anew open_ports.txt

cat resolved_subdomains.txt | httpx -sc -cl -ct -title -server -silent -threads 20 | anew httpx_results.txt
