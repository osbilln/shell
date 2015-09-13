#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

FROM="PB Monitoring <monitoring@profitbricks.com>"
if [ -n "${ICINGA_ADMINEMAIL}" ] ; then
    FROM="${ICINGA_ADMINEMAIL}"
fi


SUBJECT="Nagios: ${ICINGA_NOTIFICATIONTYPE} Service Alert: ${ICINGA_HOSTNAME}/${ICINGA_SERVICEDESC} is ${ICINGA_SERVICESTATE}"

TO="${ICINGA_CONTACTPAGER}"

BODY=$(cat <<ENDE
Service: ${ICINGA_SERVICEDESC}
Host: ${ICINGA_HOSTALIAS}
State: ${ICINGA_SERVICESTATE}
ENDE
)

if [ "${ICINGA_NOTIFICATIONTYPE}" = "ACKNOWLEDGEMENT" ] ; then
    BODY="${BODY}"$(cat <<ENDE

Ack by: ${ICINGA_NOTIFICATIONAUTHOR}
Ack text: ${ICINGA_NOTIFICATIONCOMMENT}
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
Info: ${ICINGA_SERVICEOUTPUT}
ENDE
)
printf "${BODY}" | mailx -r "${FROM}" -s "${SUBJECT}" "${TO}"


# vim: ts=4 expandtab
