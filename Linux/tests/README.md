# Tests
## Integration
Integration tests for the bash edition of GossAudit are meant to be run using [Ansible](https://docs.ansible.com/) and [molecule](https://molecule.readthedocs.io/en/latest/).

## Setting up
Install the latest versions of ansible, molecule, and the Docker driver for molecule.
```bash
pipenv install ansible molecule[docker]

python3 -m venv GossAuditIntegration
source GossAuditIntegration/bin/activate
pip3 install ansible molecule[docker]
```

You can then execute different scenarios.
```bash
molecule test
molecule test -s default
molecule test -s broken_dns
```
