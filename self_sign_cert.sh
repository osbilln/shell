#!/bin/bash

domain_name=$1
openssl x509 -req -days 3650 -in $domain_name.csr -signkey $domain_name.key -out $domain_name.crt
