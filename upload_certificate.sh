# http://www.sslshopper.com/ssl-checker.html#hostname=app.fluigidentity.com
# http://docs.aws.amazon.com/IAM/latest/UserGuide/InstallCert.html#SampleCert
# http://docs.aws.amazon.com/IAM/latest/UserGuide/InstallCert.html

# change private key to RSA private key
openssl rsa -in star_fluigidentity_com.key -outform PEM -out star_fluigidentity_com.pem

# update certificate
iam-servercertupload -b star_fluigidentity_com.crt  -c DigiCertCA.crt -k star_fluigidentity_com.pem -s FluigIdentityCert
