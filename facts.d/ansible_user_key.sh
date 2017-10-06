#!/bin/bash
if [ -f '/home/ansible/.ssh/id_rsa.pub' ]; then
  key=$(cat /home/ansible/.ssh/id_rsa.pub | cut -d ' ' -f 2)
  echo "ansible_user_key=${key}"
fi
