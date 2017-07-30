#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

FROM="PB Monitoring <monitoring@profitbricks.com>"
if [ -n "${ICINGA_ADMINEMAIL}" ] ; then
    FROM="${ICINGA_ADMINEMAIL}"
fi

SUBJECT="** ${ICINGA_NOTIFICATIONTYPE} Host Alert: ${ICINGA_HOSTNAME} is ${ICINGA_HOSTSTATE}"

TO="${ICINGA_CONTACTEMAIL}"

BODY=$(cat <<ENDE
***** Nagios *****

Notification Type: ${ICINGA_NOTIFICATIONTYPE}

Host:      ${ICINGA_HOSTALIAS}
Address:   ${ICINGA_HOSTADDRESS}
State:     ${ICINGA_HOSTSTATE}
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


Notification-Number: ${ICINGA_HOSTNOTIFICATIONNUMBER}

ENDE
)

if [ -n "${ICINGA_NOTIFICATIONCOMMENT}" ] ; then
    BODY="${BODY}"$(cat <<ENDE


Comment:   ${ICINGA_NOTIFICATIONCOMMENT}
ENDE
)

fi

BODY="${BODY}"$(cat <<ENDE


Date/Time: ${ICINGA_LONGDATETIME}

Info:      ${ICINGA_HOSTOUTPUT}
ENDE
)
printf "${BODY}" | mailx -r "${FROM}" -s "${SUBJECT}" "${TO}"

# vim: ts=4 expandtab
