FROM debian:latest

# Dependencies
RUN apt-get update && apt-get install -y curl libpcap-dev build-essential

RUN curl -fsSL https://golang.org/dl/go1.25.5.linux-amd64.tar.gz | tar -C /usr/local -xzv
ENV PATH="/usr/local/go/bin:${PATH}"

# Tool installs
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
RUN go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

COPY recon.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/recon.sh
