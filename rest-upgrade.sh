cd /cloudpass/backend/build/dist
java -cp ./rest.jar:../lib/ com.totvslabs.idm.rest.scripts.UpgradeNameDescription /data/totvslabs/scim/neo4j/embedded  /data/totvslabs/scimnew/neo4j/embedded
cd /data/totvslabs
mv scim scim.o
mv scimnew scim
