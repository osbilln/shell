if [ -e ../search.yml.local ]; then
    java -jar ../target/Search.jar server ../search.yml.local
else
    java -jar ../target/Search.jar server ../search.yml
fi
