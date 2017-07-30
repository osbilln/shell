# http://shib.kuleuven.be/docs/ssl_commands.shtml

keytool -printcert -v -file star_fluigidentity_com.p7b
keytool -import -noprompt -keystore fluigidentity.jks -storepass "j;X/>c@m<{g@?7x" -file star_thecloudpass_com.crt
keytool -import -trustcacerts -alias "digicert" -storepass "j;X/>c@m<{g@?7x" -file DigiCertCA.crt -keystore fluigidentity.jks

-import {-alias alias} {-file cert_file} [-keypass keypass]
                   {-noprompt} {-trustcacerts} {-storetype storetype}
                   {-keystore keystore} [-storepass storepass]
                   [-provider provider_class_name]
                   {-v} {-Jjavaoption}
