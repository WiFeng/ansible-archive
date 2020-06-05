#!/bin/sh

useradd ansible

mkdir /home/ansible/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvpgTCq9ZSt8xkc71+fUNwrauSrYh6dLlimdww35TBnB5CdDUVQlbzPtZf4EBnyftWeuEYaibbTgYjwWI8NkYKVY9AacLuNxiyb2eWud8Xt+hqejTCfKsF/T9P0c5luO57sdjpjj0SIH76bnBnfCBT8NxzXNjBBUeU34e31wHylleqOchMibxMSSomEn4279NIOic4S5zIl3weq6b9o/F0QoXEU/rRe+hCX4HwTLTMmrucvHQ4XOdkDVnUCvjiG0PGagxQeVD9+dTgvgg5xdyNZS+EGO8Oy5BuG7XaNNMogHnbJ2qD2oAHM31dC1pNHrXAemNoXHrcxyJKzro3gYR7Q== ansible@vm-10-176-30-201" >> /home/ansible/.ssh/authorized_keys

chown -R ansible:ansible /home/ansible/.ssh/

chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
