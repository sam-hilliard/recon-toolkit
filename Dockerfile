# syntax=docker/dockerfile:1.7

# Build Stage
FROM debian:bookworm-slim AS builder

ARG GO_VERSION=1.22.6
ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"
ENV CGO_ENABLED=1

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    curl git make gcc libc6-dev libpcap-dev python3 python3-pip pipx ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz

# mass dns install (dep for shuffledns)
RUN git clone --depth 1 https://github.com/blechschmidt/massdns.git /opt/massdns \
    && make -C /opt/massdns

# Recon tools
RUN --mount=type=cache,target=/root/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go install \
      github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
      github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest \
      github.com/projectdiscovery/httpx/cmd/httpx@latest \
      github.com/projectdiscovery/naabu/v2/cmd/naabu@latest \
      github.com/tomnomnom/anew@latest

# dnsvalidator install (for generating resolve.txt to feed to shuffledns)
RUN --mount=type=cache,target=/root/.cache/pip \
    pipx install git+https://github.com/vortexau/dnsvalidator.git

# Runtime stage
FROM debian:bookworm-slim

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    libpcap0.8 python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 10001 reconuser

COPY --from=builder /root/go/bin/* /usr/local/bin/
COPY --from=builder /opt/massdns/bin/massdns /usr/local/bin/
COPY --from=builder /root/.local/bin/dnsvalidator /usr/local/bin/

# Fix naabu raw socket perms
RUN setcap cap_net_raw=ep /usr/local/bin/naabu

# Wordlists
RUN mkdir -p /opt/wordlists \
    && curl -fsSL https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt \
       -o /opt/wordlists/commonspeak2.txt \
    && chown -R reconuser:reconuser /opt/wordlists

WORKDIR /home/reconuser
COPY --chown=reconuser:reconuser recon.sh /usr/local/bin/recon.sh
RUN chmod +x /usr/local/bin/recon.sh

USER reconuser
