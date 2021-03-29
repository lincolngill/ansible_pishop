Go Development
=========

Setup golang development. Installs the desired version of go using the `arm6l` tarball. (The repo version is often quite old.)

Will uninstall the current version if it isn't the desired version. Does both an `apt remove` and reverts the old tarball installation.

This role is idempotent.

Requirements
------------

1. Raspian image prepared via *prepimage.yml* playbook. Or Pi setup for ansible ssh access

Role Variables
--------------

| Variable                 | Required | Default                       | Comments                                 |
|--------------------------|----------|-------------------------------|------------------------------------------|
| godev_gover              | no       | 1.16.2                        | Desired go version                       |
| godev_download_url       | no       | https://golang.org/dl         | golang download site                     |

Dependencies
------------
None.

Example Playbook
----------------

Run with `become: yes`.

#### *picamera.yml*
```yaml
- name: Pi security camera setup
  hosts: picameras
  gather_facts: no

  tasks:
...
    - import_role:
        name: godev
        tags: godev
      become: yes
```
```bash
ansible-playbook -i hosts --vault-id <label>@<source> picameras.yml --tags godev -l <hostlimit>
```