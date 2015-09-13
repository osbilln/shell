#!/bin/bash



print() {

  echo -n $@

}

println() {

  echo $@

}

errorPrint() {

  echo $@

  exit 1

}

createInitialUser() {



  println "create first campaign"

  BRANCH=`svn info | grep URL | sed -e  's#.*/## ; s#trunk#test#'`

  NAEHAS_SYSTEM_USER=system

  NAEHAS_SYSTEM_PASSWORD='nh%40dmin'

  NAEHAS_TEST_CLIENT="$DESCRIPTION"

  NAEHAS_TEST_USER="$USER@naehas.com"

  NAEHAS_TEST_PASSWORD=qwer1234

  NAEHAS_TEST_CAMPAIGN="$DESCRIPTION"



  COOKIE_FILE=/tmp/curl.cookie.$PID

  CURL="/usr/bin/curl -k -S -f -b ${COOKIE_FILE} -c ${COOKIE_FILE} -v "

  # Changed from localhost to $BASE_URL since cookie now enforces path for security

  DASHBOARD_URL=$BASE_URL/$URL

  

  println "authenticate system user"

  println "naehas user = $NAEHAS_SYSTEM_USER"

  resp=`$CURL -X POST $DASHBOARD_URL/j_spring_security_check -d j_username=${NAEHAS_SYSTEM_USER} -d j_password="${NAEHAS_SYSTEM_PASSWORD}" 2>&1`

  if echo "$resp" | grep "error=1" ; then

    /bin/rm -f $COOKIE_FILE

    errorPrint "Could not authenticate system user."

  else

    println "System user Authenticated."

  fi

  $CURL -X GET $DASHBOARD_URL/home 2>&1 > /tmp/csrf.$PID

  csrf=`grep "window._n_token" /tmp/csrf.$PID | awk 'NR==1 {print $3}' | grep -Po '".*?"' | sed 's/"//g'`

  println "Create Client"

  $CURL -X POST $DASHBOARD_URL/admin/Client/create -d test=true -d name="${NAEHAS_TEST_CLIENT}" -d mode=CREATE -d csrf=${csrf}

  retCode=$?

  if [ "0" != "$retCode" ] ; then

    /bin/rm -f $COOKIE_FILE

    errorPrint "Fail to create Naehas client, curl returns ${retCode}."

  fi

  

  println "Create User"

  $CURL -X POST $DASHBOARD_URL/lp/createuser -d username=${NAEHAS_TEST_USER} -d client="${NAEHAS_TEST_CLIENT}" -d password=${NAEHAS_TEST_PASSWORD} -d csrf=${csrf} 

  retCode=$?

  if [ "0" != "$retCode" ] ; then

    /bin/rm -f $COOKIE_FILE

    errorPrint "Fail to create Naehas user, curl returns ${retCode}."

  fi



  #login as newly created user

  println "Authenticate newly created user"

  resp=`$CURL -X POST $DASHBOARD_URL/j_spring_security_check -d j_username=${NAEHAS_TEST_USER}  -d j_password=${NAEHAS_TEST_PASSWORD} 2>&1`

  if echo "$resp" | grep "Login.jsp" ; then

    /bin/rm -f $COOKIE_FILE

    errorPrint "Could not authenticate User ${NAEHAS_TEST_USER}."

  else

    println "User ${NAEHAS_TEST_USER} successfully authenticated."

  fi

  $CURL -X GET $DASHBOARD_URL/home 2>&1 > /tmp/csrf.$PID

  csrf=`grep "window._n_token" /tmp/csrf.$PID | awk 'NR==1 {print $3}' | grep -Po '".*?"' | sed 's/"//g'`



  /bin/rm -f $COOKIE_FILE



  println "Initial user created."



  println "Initial user is ${NAEHAS_TEST_USER}."



  return 0;

}

createInitialUser