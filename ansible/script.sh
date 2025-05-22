#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisites() {
    if ! command_exists ansible-playbook; then
        log "Error: ansible-playbook is not installed. Please install ansible and try again."
        exit 1
    fi
}

clone_repo() {
    local git_repo="$1"
    local local_directory="$2"
    
    if [ ! -d "$local_directory" ]; then
        log "Cloning repo from $git_repo to $local_directory"
        git clone "$git_repo" "$local_directory"
    else
        log "Repository exists at $local_directory, pulling latest changes."
        
        cd "$local_directory" || exit 1
        
        # Fix permissions if needed
        if [ ! -w .git/FETCH_HEAD ] 2>/dev/null; then
            sudo chown -R "$(whoami)" .
        fi
        
        if ! git pull origin main; then
            log "Failed to pull updates."
            return 1
        fi
        
        log "Repository updated successfully."
        cd - > /dev/null || exit 1
    fi
}

run_ansible_task() {
    local local_dir="$1"
    local ansible_dir="${local_dir}/ansible"
    local inventory_path="${ansible_dir}/inventory.yml"
    local playbook_path="${ansible_dir}/playbook.yml"
    
    if [ ! -f "$inventory_path" ]; then
        log "Inventory file not found: $inventory_path"
        exit 1
    fi
    
    if [ ! -f "$playbook_path" ]; then
        log "Playbook file not found: $playbook_path"
        exit 1
    fi
    
    log "Running Ansible playbook: $playbook_path"
    
    cd "$ansible_dir" || exit 1
    
    if command_exists ansible-playbook; then
        ansible_cmd=$(command -v ansible-playbook)
        "$ansible_cmd" -i inventory.yml playbook.yml --tags "update-suricata,test-suricata"
    else
        log "Error: ansible-playbook command not found"
        exit 1
    fi
    
    local status=$?
    log "Ansible playbook execution completed with status: $status"
}

log "Starting Suricata deployment script"

check_prerequisites

LOCK_FILE="/var/lock/suricata_deploy.lock"

if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if ps -p "$PID" > /dev/null; then
        log "Another instance is already running (PID: $PID). Exiting."
        exit 0
    else
        log "Found stale lock file. Removing it."
        rm -f "$LOCK_FILE"
    fi
fi

echo "$" > "$LOCK_FILE"

GIT_REPO="https://github.com/starkkhalibre/deploy_suricata.git"
LOCAL_DIRECTORY="/tmp/test3"

clone_repo "$GIT_REPO" "$LOCAL_DIRECTORY"
run_ansible_task "$LOCAL_DIRECTORY"

rm -f "$LOCK_FILE"

log "Suricata deployment script completed"