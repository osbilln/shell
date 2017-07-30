cd ../../../../../../../..
mkdir -p src/main/desc/
protoc src/main/java/com/totvslabs/idm/keystore/cluster/ClusterProtocol.proto --java_out=src/main/java --descriptor_set_out=src/main/desc/ClusterProtocol.desc
cd -
