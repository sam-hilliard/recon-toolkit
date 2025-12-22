# Base image
FROM debian:bookworm-slim

# Arguments
ARG GO_VERSION=1.22.6

# Create non-root user first
RUN useradd -m -u 10001 reconuser

# Install build/runtime dependencies as root
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git make gcc libc6-dev libpcap-dev libcap2-bin \
      python3 python3-pip pipx ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

# Switch to non-root user
USER reconuser
ENV GOPATH=/home/reconuser/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV PATH=/home/reconuser/.local/bin:$PATH
WORKDIR /home/reconuser

# Install Go-based recon tools
RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
 && go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest \
 && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
 && go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest \
 && go install github.com/tomnomnom/anew@latest

# Temporarily switch to root to allow naabu raw socket capability
USER root
RUN setcap cap_net_raw=ep /home/reconuser/go/bin/naabu

# Switch back to non-root user
USER reconuser

# Install Python-based tool dnsvalidator
RUN pipx install git+https://github.com/vortexau/dnsvalidator.git \
 && dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 20 -o resolvers.txt

# Wordlists in user's home
RUN mkdir -p /home/reconuser/wordlists \
 && curl -fsSL https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt \
       -o /home/reconuser/wordlists/commonspeak2.txt

# Copy provider config for subfinder
COPY --chown=reconuser:reconuser provider-config.yaml /home/reconuser/provider-config.yaml


# Copy recon script
COPY --chown=reconuser:reconuser recon.sh /usr/local/bin/recon.sh

WORKDIR /home/reconuser
