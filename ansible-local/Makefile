# Check playbook syntax
check-syntax:
	ansible-playbook --syntax-check main.yml


# VM Management targets
setup-virtualization:
	ansible-playbook -i inventory/inventory.yml main.yml --tags setup_virtualization

create-vm:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm

vm-status:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "vm_action=status"
	sleep 15 && virsh domifaddr hal9000 --source arp
	ssh -o StrictHostKeyChecking=no ubuntu@192.168.122.100 "hostname && ip addr show enp1s0"

vm-cleanup:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "vm_cleanup=true"

vm-overview:
	@echo "VM Workspace Overview:"
	@if [ -d "$(HOME)/vm-workspace" ]; then \
		echo "Total usage: $$(du -sh $(HOME)/vm-workspace | cut -f1)"; \
		echo "VM directories:"; \
		ls -la $(HOME)/vm-workspace/; \
		echo ""; \
		echo "Structure:"; \
		if command -v tree >/dev/null 2>&1; then \
			tree $(HOME)/vm-workspace -h; \
		else \
			find $(HOME)/vm-workspace -type f -exec ls -lh {} \;; \
		fi; \
	else \
		echo "No workspace found at $(HOME)/vm-workspace"; \
	fi

setup-vm-full: setup-virtualization create-vm

# Create custom VM with specific name and static IP
custom_vm:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm \
		-e "vm_name=ubuntu" \
		-e "vm_hostname=ubuntu" \
		-e "vm_static_ip=192.168.122.100"

# Clean all VMs and storage completely using virsh
clean_full:
	@echo "Destroying all VMs and removing all storage..."
	@for vm in $$(virsh list --all --name 2>/dev/null | grep -v '^$$'); do \
		echo "Destroying VM: $$vm"; \
		virsh destroy "$$vm" 2>/dev/null || true; \
		virsh undefine "$$vm" --remove-all-storage 2>/dev/null || true; \
	done
	@echo "Cleaning VM workspace directory..."
	@if [ -d "$(HOME)/vm-workspace" ]; then \
		rm -rf "$(HOME)/vm-workspace"; \
		echo "Removed $(HOME)/vm-workspace"; \
	else \
		echo "No VM workspace found at $(HOME)/vm-workspace"; \
	fi
	@echo "Cleaning inventory files..."
	@if ls inventory/vm-*.yml 1> /dev/null 2>&1; then \
		rm -f inventory/vm-*.yml; \
		echo "Removed individual VM inventory files"; \
	fi
	@if [ -f "inventory/created_vms.yml" ]; then \
		rm -f "inventory/created_vms.yml"; \
		echo "Removed master inventory file"; \
	fi
	@echo "Complete cleanup finished!"

sshkey_multipass:
	cat ~/.ssh/*.pub | multipass exec microanpr -- tee -a .ssh/authorized_keys

vars:
	ansible -m debug -a var=hostvars all  