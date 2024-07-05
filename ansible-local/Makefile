.PHONY: run
setup:
	ansible-playbook main.yml --tags "setup"  
setup_nodejs:
	ansible-playbook main.yml --tags "setupNodejs"  

setup_dotfiles:
	ansible-playbook main.yml --tags "setupDotfiles"  
vars:
	ansible -m debug -a var=hostvars all 