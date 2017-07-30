if [ -e ../adsync.yml.local ]; then
  java -jar ../target/ADSync.jar server ../adsync.yml.local
else
  java -jar ../target/ADSync.jar server ../adsync.yml
fi
