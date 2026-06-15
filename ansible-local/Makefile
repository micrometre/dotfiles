.PHONY: help provision update-inventory configure configure_nodejs configure_python configure_dotfiles configure_docker configure_virtualization configure_vm_manager configure_android_dev configure_android_studio configure_dart_flutter uninstall_nodejs uninstall_python uninstall_dotfiles uninstall_docker uninstall_android_dev uninstall_android_studio uninstall_dart_flutter ssh-agent create_vm vm_status workspace clean clean_all

help:
	@echo "Ansible Infrastructure Management"
	@echo ""
	@echo "Available targets:"
	@echo "  configure              - Configure (install base packages, setup)"
	@echo "  configure_nodejs       - Install and configure Node.js via NVM"
	@echo "  configure_python       - Install and configure Python"
	@echo "  configure_dotfiles     - Install dotfiles and Vim config"
	@echo "  configure_android_dev  - Configure Android development environment"
	@echo "  configure_android_studio - Install Android Studio"
	@echo "  configure_dart_flutter - Configure Dart/Flutter via snap"
	@echo "  configure_docker       - Configure Docker"
	@echo "  configure_virtualization - Configure virtualization support"
	@echo "  configure_vm_manager   - Configure VM manager"
	@echo "  create_vm              - Create a new VM (default: hal9000)"
	@echo "  vm_status              - Check status of VMs"
	@echo "  workspace              - Show VM workspace overview"
	@echo "  clean                  - Cleanup a specific VM (default: hal9000)"
	@echo "  clean_all              - Remove all VM images and workspace"
	@echo "  uninstall_nodejs       - Uninstall Node.js / NVM"
	@echo "  uninstall_python       - Remove Python packages and symlink"
	@echo "  uninstall_dotfiles     - Remove dotfiles and Vim config"
	@echo "  uninstall_docker       - Remove Docker packages and config"
	@echo "  uninstall_android_dev  - Remove Android development environment"
	@echo "  uninstall_android_studio - Remove Android Studio"
	@echo "  uninstall_dart_flutter - Remove Dart and Flutter snaps"
	@echo "  ssh_agent              - Start SSH agent and add SSH key"


configure:
	@echo "Configuring ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml
	@echo ""
	@echo "✅ ${HOST_NAME} configured!"

configure_update_upgrade:
	@echo "Updating and upgrading ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags common
	@echo ""
	@echo "✅ ${HOST_NAME} updated and upgraded!"

configure_docker:
	@echo "Configuring Docker on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags docker
	@echo ""
	@echo "✅ ${HOST_NAME} configured with Docker!"

configure_virtualization:
	@echo "Configuring virtualization on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags virtualization
	@echo ""
	@echo "✅ ${HOST_NAME} configured with virtualization!"

configure_vm_manager:
	@echo "Configuring VM manager on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags vm-manager
	@echo ""
	@echo "✅ ${HOST_NAME} configured with VM manager!"

create_vm:
	@echo "Creating VM..."
	ansible-playbook playbooks/configure.yml --tags create-vm $(if $(VM_NAME),-e "vm_name=$(VM_NAME)",)

vm_status:
	@echo "Checking VM status..."
	ansible-playbook playbooks/configure.yml --tags create-vm -e "vm_action=status" $(if $(VM_NAME),-e "vm_name=$(VM_NAME)",)

workspace:
	@echo "VM Workspace Overview..."
	ansible-playbook playbooks/configure.yml --tags create-vm -e "vm_action=overview"

clean:
	@echo "Cleaning up VM..."
	ansible-playbook playbooks/configure.yml --tags create-vm -e "vm_cleanup=true" $(if $(VM_NAME),-e "vm_name=$(VM_NAME)",)

clean_all:
	@echo "Cleaning all VMs and images..."
	@# Remove the workspace and images directories as defined in role defaults
	rm -rf $(HOME)/vm-workspace
	rm -rf $(HOME)/vm-images
	@echo "✅ All VM data cleaned!"



configure_nodejs:
	@echo "Configuring Node.js on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags nodejs
	@echo ""
	@echo "✅ ${HOST_NAME} configured with Node.js!"

configure_python:
	@echo "Configuring Python on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags python
	@echo ""
	@echo "✅ ${HOST_NAME} configured with Python!"

configure_dotfiles:
	@echo "Configuring dotfiles on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags dotfiles
	@echo ""
	@echo "✅ ${HOST_NAME} configured with dotfiles!"

configure_android_dev:
	@echo "Configuring Android Development on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags android-dev
	@echo ""
	@echo "✅ ${HOST_NAME} configured with Android Development!"

configure_android_studio:
	@echo "Installing Android Studio on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags android-studio
	@echo ""
	@echo "✅ ${HOST_NAME} installed with Android Studio!"

configure_dart_flutter:
	@echo "Configuring Dart/Flutter on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags dart-flutter
	@echo ""
	@echo "✅ ${HOST_NAME} configured with Dart/Flutter!"

uninstall_nodejs:
	@echo "Uninstalling Node.js/NVM on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags nodejs -e nodejs_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} uninstalled Node.js/NVM!"

uninstall_python:
	@echo "Uninstalling Python on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags python -e python_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} uninstalled Python!"

uninstall_dotfiles:
	@echo "Removing dotfiles on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags dotfiles -e dotfiles_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} removed dotfiles!"

uninstall_docker:
	@echo "Uninstalling Docker on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags docker -e docker_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} uninstalled Docker!"

uninstall_android_dev:
	@echo "Removing Android development environment on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags android-dev -e android_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} removed Android development environment!"

uninstall_android_studio:
	@echo "Removing Android Studio on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags android-studio -e android_studio_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} removed Android Studio!"

uninstall_dart_flutter:
	@echo "Removing Dart/Flutter on ${HOST_NAME}..."
	ansible-playbook playbooks/configure.yml --tags dart-flutter -e flutter_uninstall=true
	@echo ""
	@echo "✅ ${HOST_NAME} removed Dart/Flutter!"




ssh-agent:
	@echo "Checking SSH agent..."
	@if ssh-add -l >/dev/null 2>&1; then \
		echo "✅ SSH agent is already running with keys loaded"; \
	else \
		echo "Starting SSH agent and adding key..."; \
		ssh-add ~/.ssh/id_rsa; \
		echo "✅ SSH agent started!"; \
	fi




# Legacy compatibility targets
check: vm_status
status: vm_status
