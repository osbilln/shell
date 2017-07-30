


openssl genrsa -des3 -out server.key 2048
openssl req -new -key server.key -out server.csr
cp server.key server.key.old
openssl rsa -in server.key.old -out server.key
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
