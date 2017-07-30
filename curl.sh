STATUSCODE=$(curl --silent --output /dev/stderr --write-out "%{http_code}" "https://qa5.naehas.com/CoxImpQA2Dashboard/Login.jsp")

if test $STATUSCODE -ne 200; then
    # error handling
fi
