#!/bin/bash

knife xenserver vm create --vm-template "$1" \
		--keep-template-networks \
		-E _default \
    		--ssh-user billn \
		--identity-file ~billnguyen/.ssh/id_rsa.pub \
		--vm-ip 192.168.201.194 \
		--vm-cpus 4 \
		--vm-memory 4096 \
		--run-list 'recipe[haproxy]' \
		--node-name $2 \
		--vm-name $2
