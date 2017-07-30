if [ -e ../config/scim.yml.local ]; then
  java -jar ../dist/ScimServerStart.jar server ../config/scim.yml.local
else
  java -jar ../dist/ScimServerStart.jar server ../config/scim.yml
fi
