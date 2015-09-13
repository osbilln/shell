ps -eo user,rss | awk 'NR>1{u[$1]+=$2}END{for(i in u)print "user: "i",mem: "u[i]}' 
