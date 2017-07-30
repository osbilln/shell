openssl req -new -newkey rsa:2048 -nodes -out wildcard_zuberance_com.csr -keyout wildcard_zuberance_com.key \
  -subj '/C=US/ST=California/L=Burlingame/O=Zuberance Inc./OU=Engineering/CN=*.zuberance.com/ \
         subjectAltName=DNS.1=*.zubops.net, \
         DNS.2=*.zubeapps.com' > wildcard.zuberance.com.csr
