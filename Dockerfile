FROM debian:bookworm-slim

ARG GO_VERSION=1.22.6

# System deps
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    gcc \
    libc6-dev \
    libpcap-dev \
    python3 \
    python3-pip \
    pipx \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

# massdns (required by shuffledns)
RUN git clone https://github.com/blechschmidt/massdns.git /opt/massdns \
    && cd /opt/massdns \
    && make \
    && cp bin/massdns /usr/local/bin/massdns \
    && rm -rf /opt/massdns

# dnsvalidator
ENV PATH="/root/.local/bin:${PATH}"
RUN pipx install git+https://github.com/vortexau/dnsvalidator.git


# ProjectDiscovery tools
RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
    go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest && \
    go install github.com/projectdiscovery/alterx/cmd/alterx@latest && \
    go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest && \
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest && \
    go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Wordlists
RUN mkdir -p /opt/wordlists \
    && curl -fsSL https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt \
       -o /opt/wordlists/commonspeak2.txt

# Recon script
COPY recon.sh /usr/local/bin/recon.sh
RUN chmod +x /usr/local/bin/recon.sh

WORKDIR /root
