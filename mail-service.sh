#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

FROM="PB Monitoring <monitoring@profitbricks.com>"
if [ -n "${ICINGA_ADMINEMAIL}" ] ; then
    FROM="${ICINGA_ADMINEMAIL}"
fi

SUBJECT="** ${ICINGA_NOTIFICATIONTYPE} Service Alert: ${ICINGA_HOSTNAME}/${ICINGA_SERVICEDESC} is ${ICINGA_SERVICESTATE}"

TO="${ICINGA_CONTACTEMAIL}"

#LOG=/var/log/icinga/email-service.log
#echo "" >>${LOG}
#echo "#-----------------------------------------------------" >>${LOG}
#echo "[$(date)]: $0" >>${LOG}
#env | sort >>${LOG}

BODY=$(cat <<ENDE
***** Nagios *****

Notification Type: ${ICINGA_NOTIFICATIONTYPE}

Service:   ${ICINGA_SERVICEDESC}
Host:      ${ICINGA_HOSTALIAS}
Address:   ${ICINGA_HOSTADDRESS}
State:     ${ICINGA_SERVICESTATE}
ENDE
)

if [ -n "${ICINGA_NOTIFICATIONAUTHOR}" ] ; then
    LBL="Author"
    if [ "${ICINGA_NOTIFICATIONTYPE}" = "ACKNOWLEDGEMENT" ] ; then
        LBL="Ack by"
    fi
    BODY="${BODY}"$(cat <<ENDE

${LBL}:    ${ICINGA_NOTIFICATIONAUTHOR}
ENDE
)
fi

BODY="${BODY}"$(cat <<ENDE


Notification-Number: ${ICINGA_SERVICENOTIFICATIONNUMBER}
ENDE
)

if [ -n "${ICINGA_NOTIFICATIONCOMMENT}" ] ; then
    BODY="${BODY}"$(cat <<ENDE


Comment:   ${ICINGA_NOTIFICATIONCOMMENT}
ENDE
)

fi

if [ -n "${ICINGA__SERVICEVOLUME_CONTENT}" ] ; then
    BODY="${BODY}"$(cat <<ENDE


Volume Content: ${ICINGA__SERVICEVOLUME_CONTENT}
ENDE
)
fi

BODY="${BODY}"$(cat <<ENDE


Date/Time: ${ICINGA_LONGDATETIME}

Additional Info: ${ICINGA_SERVICEOUTPUT}
ENDE
)

#printf "${BODY}" >>${LOG}

printf "${BODY}" | mailx -r "${FROM}" -s "${SUBJECT}" "${TO}"

# vim: ts=4 expandtab
