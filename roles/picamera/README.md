Seup Raspberry Pi as camera
=========

Enable camera

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
| picamera_enable_camera   | True       | Desired state of pi camera               |

Dependencies
------------

Role dependencies:
* pi

Example Playbook
----------------

#### *picamera.yml*
```yaml
#
# Playbook setup Pi security camera
#
- name: Pi security camera setup
  hosts: picameras
  gather_facts: yes

  tasks:
    # picamera role depends on pi role
    - import_role:
        name: picamera
      become: yes
```
```bash
ansible-playbook -i hosts --vault-id <label>@<source> picameras.yml --tags <distupgrade|setpw|...> -l <hostlimit>
```