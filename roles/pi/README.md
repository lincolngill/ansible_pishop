Raspberry Pi
=========

Setup Pi

Requirements
------------

1. Raspian image prepared via *prepimage.yml* playbook. Or Pi setup for ansible ssh access

Role Variables
--------------

| Variable                 | Required | Default                       | Comments                                 |
|--------------------------|----------|-------------------------------|------------------------------------------|
| pi_password_hash         | yes      |                               | Password hash value for pi account       |
| locale                   | yes      |                               | locale for raspi-conf                    |
| timezone                 | yes      |                               | timezone for raspi-conf                  |
| pi_show_pi_version       | no       | false                         | Display pi version information           |
| pi_disable_wireless      | no       | false                         | Disable WiFi and Bluetooth               |

Recommend setting the required variables in *group_vars/pies/vars.yml*. Based on vault variable set in *group_vars/pies/vault.yml*.

Dependencies
------------

None.

Example Playbook
----------------

#### *picamera.yml*
```yaml
- name: Pi security camera setup
  hosts: picameras
  gather_facts: no
  become: yes

  tasks:
    - import_role:
        name: pi
```
```bash
ansible-playbook -i hosts --vault-id <label>@<source> picameras.yml --tags <distupgrade|setpw|...> -l <hostlimit>
```