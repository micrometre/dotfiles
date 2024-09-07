.PHONY: run
setup:
	ansible-playbook main.yml --tags "setup"  -vvv
setup_nodejs:
	ansible-playbook main.yml --tags "setupNodejs"  

setup_dotfiles:
	ansible-playbook main.yml --tags "setupDotfiles"  
setup_pipx:
	ansible-playbook main.yml --tags "setupPipx"  
vars:
	ansible -m debug -a var=hostvars all 