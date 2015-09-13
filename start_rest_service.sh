if [ -e ../rest.yml.local ]; then
  java -jar ../target/rest.jar server ../rest.yml.local
else
  java -jar ../target/rest.jar server ../rest.yml
fi
