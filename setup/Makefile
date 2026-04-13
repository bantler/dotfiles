.PHONY: all win wsl wsl-ansible help

all: help

help:
	@printf "Usage:\n  make win         Run Windows PowerShell setup\n  make wsl         Run WSL install script (run inside WSL or have bash available)\n  make wsl-ansible Run Ansible playbook (requires Ansible)\n"

win:
	@echo "Running Windows PowerShell setup..."
	@powershell -NoProfile -ExecutionPolicy Bypass -File "./win/windows_setup.ps1"

wsl:
	@echo "Running WSL install script..."
	@bash ./wsl/install.sh

wsl-ansible:
	@echo "Running Ansible playbook (ensure ansible is installed in your environment)"
	@ansible-playbook ./wsl/ansible/playbook.yml
