#!/bin/bash

CUR_GIT_BRANCH=$(git branch | grep '^*' | sed -e 's/^[ 	]*\*[ 	]*//' -e 's/[ 	]$//')

RED="\033[38;5;196m"
YELLOW="\033[38;5;226m"
GREEN="\033[38;5;46m"
BLUE="\033[38;5;27m"
NORMAL="\033[39m"

export LANG=C
export LANGUAGE=
export LC_CTYPE=C
export LC_NUMERIC=C
export LC_TIME=C
export LC_COLLATE=C
export LC_MONETARY=C
export LC_MESSAGES=C
export LC_PAPER=C
export LC_NAME=C
export LC_ADDRESS=C
export LC_TELEPHONE=C
export LC_MEASUREMENT=C
export LC_IDENTIFICATION=C
export LC_ALL=

USE_MY_DEBCHANGE=y
if type -t debchange >/dev/null ; then
    USE_MY_DEBCHANGE=n
fi

usage() {
    echo "Usage: $0 [-D unstable|testing|stable] [-a major|minor|micro|release]"
    echo "       $0 -h"
    echo
}

DO_HELP="n"
ACTION="micro"
WANT_STAGE="unstable"
case "${CUR_GIT_BRANCH}" in
    release/*) WANT_STAGE="stable";;
    master) WANT_STAGE="stable";;
esac

while getopts "ha:D:" options; do
    case $options in
        h) DO_HELP="y";;
        a) ACTION="${OPTARG}";;
        D) WANT_STAGE="${OPTARG}";;
        *) usage >&2
           exit 1
           ;;
    esac
done

echo "WANT_STAGE: ${WANT_STAGE}" >/dev/null
echo "ACTION: ${ACTION}" >/dev/null

if [ "${DO_HELP}" = "y" ] ; then
    usage
    exit 0
fi

case "${WANT_STAGE}" in
    stable|testing|unstable) ;;
    *) usage >&2
       exit 1
       ;;
esac

cd $(dirname $0)

if [ ! -f "debian/changelog" ] ; then
    echo -e "File '${RED}debian/changelog${NORMAL}' does not exists." >&2
    exit 4
fi

FIRST_LINE_CHANGELOG=$(cat debian/changelog | head -n 1)
CUR_VERSION=$(echo "${FIRST_LINE_CHANGELOG}" | sed -e 's/^.*(//' -e 's/).*//')
CUR_STAGE=$(echo "${FIRST_LINE_CHANGELOG}" | sed -e 's/.*)[ 	][ 	]*//' -e 's/;.*//')
PKG_NAME=$(echo "${FIRST_LINE_CHANGELOG}" | sed -e 's/[ 	][ 	]*(.*//')

#--------------------------------------------------
my_debchange() {

    local stage version

    stage="${CUR_STAGE}"
    version="${CUR_VERSION}"

    if [ "${1}" = '-D' ] ; then
        stage="${2}"
        shift
        shift
    fi

    if [ "${1}" = '-v' ] ; then
        version="${2}"
        shift
        shift
    fi

    TMP_FILE="debian/changelog.new"

    echo "${PKG_NAME} (${version}) ${stage}; urgency=low" >"${TMP_FILE}"
    echo >>"${TMP_FILE}"
    for entry in "$@"; do
        if [ "${entry}" != "" ] ; then
            echo "  * ${entry}" >>"${TMP_FILE}"
        fi
    done
    echo >>"${TMP_FILE}"

    echo " -- ${DEBFULLNAME:-Developer} <${DEBEMAIL:-so@profitbricks.com}>  $(date -R)" >>"${TMP_FILE}"
    echo >>"${TMP_FILE}"

    cat "debian/changelog" >>"${TMP_FILE}"
    mv "${TMP_FILE}" "debian/changelog"


}

#--------------------------------------------------
PB_VERSION=$(echo "${CUR_VERSION}" | awk -F'-' '{print $1}')
RELEASE_VERSION=$(echo "${CUR_VERSION}" | awk -F'-' '{print $2}')
if [ -z "${PB_VERSION}" ] ; then
    PB_VERSION='0.0.0'
fi
if [ -z "${RELEASE_VERSION}" ] ; then
    RELEASE_VERSION='1'
fi

MAJOR_VERSION=$( echo "${PB_VERSION}" | awk -F. '{print $1}')
if [ -z "${MAJOR_VERSION}" ]; then
    MAJOR_VERSION=0
    MINOR_VERSION=0
    MICRO_VERSION=0
else
    MINOR_VERSION=$( echo "${PB_VERSION}" | awk -F. '{print $2}')
    if [ -z "${MINOR_VERSION}" ]; then
        MINOR_VERSION=0
        MICRO_VERSION=0
    else
        MICRO_VERSION=$( echo "${PB_VERSION}" | awk -F. '{print $3}')
        if [ -z "${MICRO_VERSION}" ]; then
            MICRO_VERSION=0
        fi
    fi
fi

case "${ACTION}" in
    major|minor|micro|release)
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

case "${ACTION}" in
    major)
        MAJOR_VERSION=$(( ${MAJOR_VERSION} + 1 ))
        MINOR_VERSION=0
        MICRO_VERSION=0
        RELEASE_VERSION=1
        ;;
    minor)
        MINOR_VERSION=$(( ${MINOR_VERSION} + 1 ))
        MICRO_VERSION=0
        RELEASE_VERSION=1
        ;;
    micro)
        MICRO_VERSION=$(( ${MICRO_VERSION} + 1 ))
        RELEASE_VERSION=1
        ;;
    release)
        RELEASE_VERSION=$(( ${RELEASE_VERSION} + 1 ))
        ;;
esac

NEW_PB_VERSION=${MAJOR_VERSION}.${MINOR_VERSION}.${MICRO_VERSION}
NEW_DEBIAN_VERSION="${NEW_PB_VERSION}-${RELEASE_VERSION}"
echo -e "Current version:    ${GREEN}${CUR_VERSION}${NORMAL}"
echo -e "New version:        ${GREEN}${NEW_PB_VERSION}${NORMAL}"
echo -e "New Debian version: ${GREEN}${NEW_DEBIAN_VERSION}${NORMAL}"
echo -e "Set distribution:   ${GREEN}${WANT_STAGE}${NORMAL}"

ACCEPT=""
while [ true ] ; do
    echo
    echo -e -n "Commit new version  [${RED}y${NORMAL}/${GREEN}N${NORMAL}]?"
    read -t 10 -p " " ACCEPT
    if [ -z "${ACCEPT}" ]; then
        echo
        exit 0
    fi
    ACCEPT=$( echo "${ACCEPT}" | tr '[:upper:]' '[:lower:]' )
    if [ "${ACCEPT}" = 'n' -o "${ACCEPT}" = 'no' ] ; then
        exit 0
    fi
    if [ "${ACCEPT}" = 'y' -o "${ACCEPT}" = 'yes' ] ; then
        break
    fi
done

echo
echo -e "Increasing version to ${GREEN}${NEW_DEBIAN_VERSION}${NORMAL} ..."

SECOND_LINE=
if [ "${CUR_STAGE}" != "${WANT_STAGE}" ] ; then
    SECOND_LINE="Declared for ${WANT_STAGE}"
fi

echo -n "debchange -D \"${WANT_STAGE}\" -v \"${NEW_DEBIAN_VERSION}\" \"Version bump\" "
if [ "${USE_MY_DEBCHANGE}" = "y" ] ; then
    my_debchange -D "${WANT_STAGE}" -v "${NEW_DEBIAN_VERSION}" "Version bump" "${SECOND_LINE}"
else
    echo -e "\n" | debchange -D "${WANT_STAGE}" -v "${NEW_DEBIAN_VERSION}" "Version bump"
fi
echo -e "[${GREEN}OK${NORMAL}]"

if [ "${CUR_STAGE}" != "${WANT_STAGE}" ] ; then
    echo -n "debchange \"Declared for ${WANT_STAGE}\" "
    if [ "${USE_MY_DEBCHANGE}" != "y" ] ; then
        debchange "Declared for ${WANT_STAGE}"
    fi
    echo -e "[${GREEN}OK${NORMAL}]"
fi

# Mangling Python scripts
py_scripts="nagios/__init__.py"
for script in $py_scripts; do
    if [ -f $script ] ; then
        echo -n "Performing $script ... "
        sed -i -e "s/__version__\\([ 	]*=[ 	]*\\)[^ 	]*/__version__\\1'${NEW_PB_VERSION}'/" $script
        echo -e "[${GREEN}OK${NORMAL}]"
    fi
done

# Mangling Perl scripts
pl_scripts="bin/check-vg-free"
for script in $pl_scripts; do
    if [ -f $script ] ; then
        echo -n "Performing $script ... "
        sed -i -e "s/\$VERSION\\([ 	]*=[ 	]*\\)[^ 	]*/\$VERSION\\1'${NEW_PB_VERSION}';/" $script
        echo -e "[${GREEN}OK${NORMAL}]"
    fi
done


git status debian/changelog $py_scripts $pl_scripts

# vim: ts=4 expandtab
