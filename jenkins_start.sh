nohup sudo /usr/bin/java -jar /usr/share/jenkins/jenkins.war --webroot=/var/run/jenkins/war --httpPort=9080 --ajp13Port=-1 --preferredClassLoader=java.net.URLClassLoader --logfile=/var/log/jenkins/jenkins.log &