#!/usr/bin/env bash
#
# Helper script to run ansible commands
#
STEP=${1:-1}
LIMIT="${2}"
PLAY="${3:-pivpn}"
TAGS="${4}"
AOPT=""
if [ -n "$LIMIT" ]; then
    AOPT="-l ${LIMIT}"
fi
if [ -n "$TAGS" ]; then
    AOPT="$AOPT --tags ${TAGS}"
fi

VAULT_ID="gills@~/ansible-vpw"

cd $(dirname $0)

fn_run () {
    set -x; $1
    { set +x; } 2>/dev/null
}

case $STEP in
    0) fn_run "ansible-vault edit --vault-id ${VAULT_ID} group_vars/pies/vault.yml" ;;
    # mount USB SD card locally
    1) fn_run "ansible-playbook prepimage.yml -i hosts ${AOPT} --vault-id ${VAULT_ID}" ;;
    2) fn_run "ansible ${LIMIT} -i hosts -a whoami --vault-id ${VAULT_ID}" ;;
    # Run playbook with vault
    3) fn_run "ansible-playbook ${PLAY}.yml -i hosts ${AOPT} --vault-id ${VAULT_ID}" ;;
    # Run playbook without vault
    4) fn_run "ansible-playbook ${PLAY}.yml -i hosts ${AOPT}" ;;
    5) fn_run "ansible-galaxy init roles/newrole" ;;
    # List facts
    6) fn_run "ansible -i hosts -m setup --vault-id ${VAULT_ID} $LIMIT" ;;
    10) fn_run "ansible-vault view --vault-id ${VAULT_ID} group_vars/pies/vault.yml" ;;
    11) fn_run "ansible-vault edit --vault-id ${VAULT_ID} roles/pivpn/defaults/main/vault.yml" ;;
    12) fn_run "ansible-vault edit --vault-id ${VAULT_ID} roles/afraid_ddns/defaults/main/vault.yml" ;;
    13) fn_run "ansible-vault edit --vault-id ${VAULT_ID} roles/nextcloud/defaults/main/vault.yml" ;;
    100) fn_run "ansible-playbook pivpn.yml -i hosts ${AOPT} --vault-id ${VAULT_ID}" ;;
    101) fn_run "ansible-playbook octopi.yml -i hosts ${AOPT} --vault-id ${VAULT_ID}" ;;
    *) echo "Usage: doit.sh [<step>] [<ansible_limit>]" >&2; exit 1 ;;
esac
