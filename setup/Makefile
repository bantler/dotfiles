.PHONY: all bootstrap wsl-dev wsl-base wsl-cloud help

# Linux Distro to be install in WSL
WSL_DISTRO ?= Ubuntu-22.04

# Directory that contains this Makefile
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# Repo root (automation/)
REPO_ROOT_WIN := $(abspath $(THIS_DIR)/../..)

# WSL path version of repo root
REPO_ROOT_WSL := $(shell wsl -d $(WSL_DISTRO) -- wslpath -a "$(REPO_ROOT_WIN)")

help:
	@printf "Usage:\n  make win         Run Windows PowerShell setup\n  make wsl         Run WSL install script (run inside WSL or have bash available)\n  make wsl-ansible Run Ansible playbook (requires Ansible)\n"

bootstrap:
	@echo "Running Windows Bootstrap setup..."
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./windows/bootstrap.ps1 -WSL_DISTRO $(WSL_DISTRO)

wsl-base:
	wsl -d $(WSL_DISTRO) -- bash -lc "cd '$(REPO_ROOT_WSL)/scripts/local environments/wsl' && ansible-playbook -i inventory/local.ini playbooks/base.yaml"

	wsl -d Ubuntu-22.04 -- bash -lc "cd '/mnt/c/Users/CollinM/source/repos/azuredevops/automation/scripts/local environments/wsl' && ansible-playbook -i inventory/local.ini playbooks/base.yaml"

wsl-dev:
	wsl -d $(WSL_DISTRO) -- bash -lc "cd '$(REPO_ROOT_WSL)/scripts/local environments/wsl' && ansible-playbook -i inventory/local.ini playbooks/dev.yaml"

wsl-cloud:
	wsl -d $(WSL_DISTRO) -- bash -lc "cd '$(REPO_ROOT_WSL)/scripts/local environments/wsl' && ansible-playbook -i inventory/local.ini playbooks/cloud.yaml"