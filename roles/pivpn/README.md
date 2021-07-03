Seup Raspberry Pi as WireGuard VPN
=========

Enable ufw firewall.

Requirements
------------

1. Raspian image prepared via *prepimage.yml* playbook. Or Pi setup for ansible ssh access

Role Variables
--------------

None.

Internal Variables
------------------

| Variable                 | Value      | Comments                                 |
|--------------------------|------------|------------------------------------------|

Dependencies
------------

Role dependencies:

Example Playbook
----------------

#### *pivpn.yml*
```yaml
---
#
# Playbook setup Pi WireGuard VPN
#
- name: Pi WireGuard VPN setup
  hosts: pivpn
  gather_facts: yes
  become: yes

  tasks:
    - import_role:
        name: pi
    - import_role:
        name: pivpn
```
```bash
ansible-playbook -i hosts --vault-id <label>@<source> pivpn.yml --tags <distupgrade|setpw|...> -l <hostlimit>
```