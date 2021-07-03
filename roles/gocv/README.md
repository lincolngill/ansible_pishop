Build OpenCV From make File Provided by gocv
=========

Tasks:
* Installs `git` and `screen`
* Gets the gocv module - Which includes the OpenCV make file
* Runs a shell script in a detached screen to run the `make` steps (Takes a long time)

The `make` steps are run from a script that runs in a detached `screen` session on the target.
The script takes a long time. You can leave it running and `ssh` to the target and reattached to the screen session to check on progress:
```bash
pi@cam1pi:~ $ screen -r make_gocv
```
The `screen` session is logged. So all `make` related output can be reviewed after the screen session has terminated. The script is idempotent. It keeps a short status log file that is used to detect if the separate make steps have already completed.
```bash
pi@cam1pi:~ $ ls *.log
gocv_make.log  gocv_make_tasks.log
```

The role creates a copy of the version check example in `/home/pi/godev/version`. Run the version check once the role and `screen` session have completed successfully:
```bash
pi@cam1pi:~ $ cd godev/version
pi@cam1pi:~/godev/version $ go run main.go 
gocv version: 0.26.0
opencv lib version: 4.5.1
```

This role is idempotent.

The role should NOT be run with `become: yes`. Individual tasks within the role use `beome: yes`, when required. The `make` and example setup are run as `pi`.

Requirements
------------

Setup the Pi with the newpi, pi, picamera and godev roles.

Role Variables
--------------

| Variable                 | Required | Default                   | Comments                                            |
|--------------------------|----------|---------------------------|-----------------------------------------------------|
|                          |          |                           |                                                     |

The role will install the latest version of gocv. It will also upgrade to the latest version if one is available. It's worth checking if new versions are available before running the role because the make step takes ~12hrs and will be overwriting version independent libraries as it runs.

```bash
go list -m -versions gocv.io/x/gocv
```

Dependencies
------------

None.

Example Playbook
----------------

#### *picameras.yml*
```yaml
---
- name: Pi security camera setup
  hosts: picameras
  gather_facts: yes

  tasks:
...
    - import_role:
        name: gocv
      tags: gocv
```
```bash
ansible-playbook picameras.yml -i hosts --vault-id <label>@<source>
```