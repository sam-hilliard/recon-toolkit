FROM debian:bookworm-slim

ARG GO_VERSION=1.22.6

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git make gcc libc6-dev libpcap-dev libcap2-bin \
      python3 python3-pip pipx ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz

ENV GOPATH=/root/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV PATH=/root/.local/bin:$PATH

RUN go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
 && go install github.com/projectdiscovery/httpx/cmd/httpx@latest \
 && go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest \
 && go install github.com/tomnomnom/anew@latest \
 && go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest


# wordlists
RUN mkdir -p /opt/wordlists \
 && curl -fsSL https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt \
       -o /opt/wordlists/commonspeak2.txt

COPY recon.sh /usr/local/bin/recon.sh
RUN chmod +x /usr/local/bin/recon.sh

COPY provider-config.yaml /root/.config/subfinder/provider-config.yaml

RUN mkdir -p /bounty
WORKDIR /bounty
