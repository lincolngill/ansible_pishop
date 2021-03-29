New pi Image Injection Bootstrap Role
=========

Prepares a USB Raspian image prior to first boot.
* Injects wifi *wpa_supplicant.conf* file into `<image_dir>/boot`
* Updates hostname - Based on inventory host alias
* Sets up ssh authorised key

Once the role has run:
* Eject the SD, Place in Pi and boot.
* Check ssh access
   ```
   ansible newpi --vault-id <label>@<source> -i hosts -a "whoami"
   ```
* Then edit *hosts* inventory and move new pi host entry to it's normal group.

Requirements
------------

Steps required prior to running:

1. Put the hostname of the new pi in the `newpi` inventory group. E.g.
    ```
    [newpi]
    cam1pi.local
    ```
2. If not done previously, setup vault for `pies` group. 
   ```
   $ ansible-vault create --vault-id <label>@<source> group_vars/pies/vault.yml
   vault_wifi_ssid: <ssid>
   vault_wifi_psk: <psk>
   vault_wifi_passphrase:

   # Created via
   # $ mkpasswd -m sha-512 <secure_password>
   vault_pi_password_hash: "<password_hash_value>"
   ```
2. Flash raspian to SD card
3. Mount SD on localhost

Now you ready to run this role on the mounted image. Refer playbook example below.

Role Variables
--------------

| Variable                 | Required | Default                         | Comments                                     |
|--------------------------|----------|---------------------------------|----------------------------------------------|
| wifi_ssid                | yes      |                                 | WiFi SSID                                    |
| wifi_psk                 | either   |                                 | Generated from `$ wpa_passphrase <ssid>`     |
| wifi_passphrase          | or       |                                 | WiFi Passphrase (recommend using `wifi_psk`) |
| wifi_country             | yes      |                                 | WiFi country code. E.g. `NZ`                   |
| inventory_hostname_short | no       | Magic Variable                  | Injected into image as hostname              |
| newpi.bootdir            | no       | */media/${USER}/boot*           | Mounted image boot partition                 |
| newpi.rootfs             | no       | */media/${USER}/rootfs*         | Mounted image rootfs partition               |
| newpi.pubkeyfile         | no       | */home/${USER}/.ssh/id_rsa.pub* | Public key to copy to authorized_keys        |

If `wifi_psk` is set then it will be used in *wpa_supplicant.conf* and `wifi_passphrase` will be ignored. So don't set it to a value. Recommend using `wifi_psk` as it is slightly more secure than having a clear text passphrase in *wpa_supplicant.conf*.

Recommend setting the required variables in *group_vars/pies/vars.yml*. Based on vault variable set in *group_vars/pies/vault.yml*.

Dependencies
------------

None.

Example Playbook
----------------

All tasks in the playbook are `delegated_to: localhost`. The inventory host alias is used to set the hostname within the image.

#### *prepimage.yml*
```yaml
- name: Prepare USB Raspian image
  hosts: newpi
  gather_facts: no

  tasks:
    - import_role:
        name: newpi
```
```bash
ansible-playbook prepimage.yml -i hosts --vault-id <label>@<source>
```