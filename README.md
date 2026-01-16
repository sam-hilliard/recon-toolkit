# Recon Toolkit

A Docker container with preinstalled bug bounty recon tools (`subfinder`, `shuffledns`, `naabu`, `httpx`, `dnsx`, `anew`). Designed to run recon on a local bug bounty workspace.

---

## Features

* No need to install tools on your local machine (thanks to docker)
* Pulls the latest tools everytime the container is built
* Easy to run!

---

## Requirements

* [Docker](https://docs.docker.com/get-docker/) installed on your system
* A local workspace containing at least `domains.txt` and `wildcards.txt`

Example workspace layout:

```bash
❯ tree
.
├── domains.txt
├── parse_scope.sh
├── scope.csv
└── wildcards.txt

1 directory, 4 files
```

---

## Build the container

```bash
docker build -t recon-toolkit .
```

---

## Usage

Run recon in the **current directory**:

```bash
$ cd /path/to/bounty workspace
$ recon
```

Or specify a target directory:

```bash
$ recon /path/to/bounty/workspace
```
