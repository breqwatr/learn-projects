# 4.3 Configuration with Ansible

The code for [Configuration with Ansible](https://learn.breqwatr.workers.dev/tutorials/ansible-configuration/) on learn.breqwatr.cloud. Follow the page: it explains each file and the order to run things in.

Playbooks that launch a Linux and a Windows instance with the `openstack.cloud` collection, a dynamic inventory, and the configuration of a web server on each: over SSH on Linux and WinRM on Windows.

## Files

- `configure.yml`
- `destroy.yml`
- `group_vars/os_linux/vars.yml`
- `group_vars/os_windows/vars.yml`
- `openstack.yml`
- `provision.yml`
- `vars.yml`
- `winrm-https.ps1`

## Before you run it

Set your values in `vars.yml` and your cloud name in `openstack.yml`. The page shows how to create the SSH key and the Ansible Vault file, which stay on your computer.

## Versions

Tested with Ansible 14.5.0 (ansible-core 2.21.5) on Python 3.14, with the `openstack.cloud`, `ansible.windows` and `community.windows` collections it includes, and pywinrm.
