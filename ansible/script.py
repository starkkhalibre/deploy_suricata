from git import Repo, GitCommandError
import ansible_runner
import os
# for testing with sudo pass
# import getpass

def clone_repo(git_repo, local_directory):
    if not os.path.exists(local_directory):
        print(f"Cloning repo from {git_repo} to {local_directory}")
        Repo.clone_from(git_repo, local_directory)
    else:
        print(f"Repository already exists at {local_directory}, pulling latest changes.")
        try:
            repo = Repo(local_directory)
            origin = repo.remotes.origin
            origin.pull()
            print("Repository updated successfully.")
        except GitCommandError as e:
            print(f"Failed to pull updates: {e}")

def run_ansible_task(local_dir):
    ansible_dir = os.path.join(local_dir, 'ansible')
    inventory_path = os.path.join(ansible_dir, 'inventory.yml')
    playbook_path = os.path.join(ansible_dir, 'playbook.yml')

    if not os.path.exists(inventory_path):
        raise FileNotFoundError(f"Inventory file not found: {inventory_path}")
    if not os.path.exists(playbook_path):
        raise FileNotFoundError(f"Playbook file not found: {playbook_path}")
    
    # become_pass = getpass.getpass("Enter sudo password: ")

    print(f"Running Ansible playbook: {playbook_path}")
    r = ansible_runner.run(
        private_data_dir=ansible_dir,
        inventory='inventory.yml',
        playbook='playbook.yml'
        # for testing with sudo pass
        # extravars={"ansible_become_password": become_pass},
        # envvars={"ANSIBLE_BECOME_PASSWORD": become_pass}
    )

    print("Status:", r.status)
    print("RC:", r.rc)
    print("Final stdout:")
    for each_event in r.events:
        # for testing with sudo pass
        # print(each_event.get('stdout',''))
        print(each_event['stdout'])

if __name__ == "__main__":
    git_repo = "https://github.com/starkkhalibre/deploy_suricata.git"
    local_directory = "/tmp/test3"

    clone_repo(git_repo, local_directory)
    run_ansible_task(local_directory)
