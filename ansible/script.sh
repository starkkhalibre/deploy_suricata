#!/bin/bash

clone_repo() {
    local git_repo="$1"
    local local_directory="$2"
    
    if [ ! -d "$local_directory" ]; then
        echo "Cloning repo from $git_repo to $local_directory"
        git clone "$git_repo" "$local_directory"
    else
        echo "Repository already exists at $local_directory, pulling latest changes."
        cd "$local_directory" || exit 1
        if ! git pull origin; then
            echo "Failed to pull updates."
            return 1
        fi
        echo "Repository updated successfully."
        cd - > /dev/null || exit 1
    fi
}

# Function to run Ansible playbook
run_ansible_task() {
    local local_dir="$1"
    local ansible_dir="${local_dir}/ansible"
    local inventory_path="${ansible_dir}/inventory.yml"
    local playbook_path="${ansible_dir}/playbook.yml"
    
    if [ ! -f "$inventory_path" ]; then
        echo "Inventory file not found: $inventory_path"
        exit 1
    fi
    
    if [ ! -f "$playbook_path" ]; then
        echo "Playbook file not found: $playbook_path"
        exit 1
    fi
    
    echo "Running Ansible playbook: $playbook_path"
    
    # For testing with sudo password:
    # read -s -p "Enter sudo password: " ANSIBLE_BECOME_PASSWORD
    # export ANSIBLE_BECOME_PASSWORD
    # echo
    
    cd "$ansible_dir" || exit 1
    ansible-playbook -i inventory.yml playbook.yml
    
    local status=$?
    echo "Status: $status"
    
    # The output is already shown during ansible-playbook execution
}

# Main script
GIT_REPO="https://github.com/starkkhalibre/deploy_suricata.git"
LOCAL_DIRECTORY="/tmp/test3"

clone_repo "$GIT_REPO" "$LOCAL_DIRECTORY"
run_ansible_task "$LOCAL_DIRECTORY"
