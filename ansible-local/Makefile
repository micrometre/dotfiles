.PHONY: run
setup:
	ansible-playbook main.yml --tags "setup" -v  
setup_nodejs:
	ansible-playbook main.yml --tags "setupNodejs"  
vars:
	ansible -m debug -a var=hostvars all 