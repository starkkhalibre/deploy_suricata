# deploy_suricata

## Prerequisites

- Python3
- Python virtual environment

## Setup

### Setup python virtual environment

```console
sudo apt install -y python3 python3-pip python3-venv
```
### Activate virtual environment

```console
source .venv/bin/activate
```

### Install required packages

```console
pip install -r requirements.txt
```

### Deploy

```console
ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
```


