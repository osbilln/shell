#! /bin/sh
SHELL=/bin/sh
export SHELL

# Copyright 2007 SafeNet Inc. 
# All Rights Reserved
#
# Use of this file for any purpose whatsoever is prohibited without the
# prior written consent of SafeNet Inc. 
#
# File  : $RCSfile$
# Author: Bob Hepple
#
# Description: Unix installation script
#
# Version Control Info:
#
# $Source$
# $Revision: 28 $
# $Date: 2005-08-23 15:13:02 +1000 (Tue, 23 Aug 2005) $
# $Author: ahacking $

# SafeNet install/uninstall script for all supported flavours of Unix:
# Use the '-h' option to get help

KNOWN_OS_DIRS="AIX HP-UX Linux Linux64 Solaris SolarisX86"

###############################################################################
# notes:

# This script should sit in the root directory of the installation CD

# The CD is assumed to be laid out as follows - the elements necessary
# to the functioning of this script are marked ESSENTIAL:
#
# /README 					simple installation notes
# /installation_guide.pdf   
# /safeNet-install.sh		this script - ESSENTIAL
# /autorun.bat 				for Windows
# /setup.bat 				for Windows
# /doc/                     
# /support/                 acrobat, jre etc as normal
# /Linux/					all Linux packages - ESSENTIAL
# /Solaris/					all Solaris packages - ESSENTIAL
# etc

# the / directory must contain a subdirectory for each OS supported
# here, although other subdirectories may also be present and will be
# ignored (eg for Windows):

# /Linux/ptko-client/ERACcprc-3.09-1.rpm
# /Linux/ptko-runtime/ERACcp8k-3.09-1.rpm
# /Linux/ptko-sdk/ERACcp8k-3.09-1.rpm
# /Solaris/ptko-runtime/ERACcp8k.pkg 
# /Solaris/ptko-runtime/ERACcp8k/
# etc

# In general, the directories under the OS level can be anything, and
# the actual name is not used or presented to the user:
# /$OS/*/package_file

# Note that each package directory (eg. /Linux/ptko-client) _MUST_
# have at most one package file or directory. The only exceptions is
# that the AIX package directories _MUST_ have the .toc file too and
# .sig files are allowed (but not checked in this version).

# No package should be compressed (over and above the default for that
# package format) - so no .gz .bz2 or .zip files!

# Note that any dependency and exclusion rules (eg. REQUIRES,
# PROVIDES) should be built into the packages as normal. Dependency
# checking does not belong here.

# 'Support' packages can be included eg java jre, acrobat, etc - but
# they must be in the 'native' install format eg RPM for Linux .depot
# for HPUX etc - not a 'shar' script or other format. If this cannot
# be done for whatever reason then the support package should go into
# the /support directory.

# There is room on the menus for up to about 15 packages per platform
# - either install or uninstall. If more than this is required, further
# development would be needed.

# This script need not be included in Unix packages - it installs
# itself in /usr/bin, overwriting any earlier version of itself.

# This script must be portable across all Unix systems. Beware
# the tempting bash-extensions such as:

# indirection: 	${!A} ...use `eval echo \\$"$A"` instead
# execution: 	$(pwd) ...use `pwd` instead
# etc etc

# Other platform gotchas:
# Solaris cp has no -f option
# Solaris 'find' lacks -maxdepth option
# Do all awks (esp. Solaris nawk) support -v option?
# On Solaris sh exits if cd fails; other platforms - get error in $? ???
# On Solaris "for i; do ...; done" is illegal ???
# $(...) is illegal on Solaris - use `...`
# On UnixwWare (at least), "if !" does not work - use "if X; then : ; else Y; done"
# UW7 tr does this: echo "~~~@~~~@" |tr '~' '-' => ~@~@    !!!! so use sed instead!!

# http://multivac.cwru.edu/lintsh/: Solaris sh forks for compound
# commands with redirections such as "while read var; do something;
# done < file", so variable assignments and exit behave differently
# (although errors still cause the top-level shell to exit if set -e
# is in effect). bash and pdksh do not fork. As a workaround, the
# compound command can be made into a shell function, and the function
# can be invoked with redirections; this will not cause Solaris sh to
# fork. UnixWare & OS5 appear to be the same in this regard.

# On that note, remember that in "a | b", "b" is in a sub-shell and
# changes in environment parameters are not seen.

# This script uses the descriptions built into the packages themselves
# - be aware of the CSA7000 package name conflict - eg. ERACcpsdk rev
# 2.XX is for 7000, rev 3.xx is for 8000


# Set this to turn on some debugging:
DEBUG=""
trace_debug() {
	if [ "$DEBUG" ]; then
		echo ${1+"$@"} pwd=`pwd` >&2
	fi
}

chop() {
	sed -e "s/\\(.\\{1,$MAX_SCREEN_WIDTH\}\\).*/\\1/"
}

# Note: use path to echo to eliminate the built-in version:
echo_no_cr_backslash() {
	MSG="$1\\c"
	$ECHO "$MSG"
}

echo_no_cr_n() {
	$ECHO -n "$1"
}

tput_output() {
	if [ "$ENABLE_TPUT" ]; then
		OUTPUT=`tput $@ 2>/dev/null`
		if [ $? -eq 0 -a -n "$OUTPUT" ]; then
			$ECHO_NO_CR $OUTPUT
		else
			return 1
		fi
	fi
}

print_normal() {
	$ECHO_NO_CR "$@"
}

print_reverse() {
	$ECHO_NO_CR "$START_REVERSE$@$START_NORMAL"
}

print_italic() {
	$ECHO_NO_CR "$START_ITALIC$@$START_NORMAL"
}

print_bold() {
	$ECHO_NO_CR "$START_BOLD$@$START_NORMAL"
}

print_alarm() {
	$ECHO_NO_CR "$START_ALARM$@$START_NORMAL"
}

print_menu_letter() {
	$ECHO_NO_CR "$START_ALARM$@$START_NORMAL"
}

print_blink() {
	$ECHO_NO_CR "$START_BLINK$@$START_NORMAL"
}

clear_last_line() {
	tput_output cuu1
	tput_output ed
}

press_enter() {
	print_reverse "type enter to continue:"
	print_normal " "
	read I
	I=`echo $I| $TR '[A-Z]' '[a-z]'`
	if [ "$I" = "q" ]; then
		exit 0
	fi
	clear_last_line
}

skip_lines() {
	echo
	I="$1"
	while [ "$I" -lt "$SCREEN_HEIGHT" ]; do
		I=`expr "$I" + 1`
		echo
	done
}

wait_over() {
	echo " ... done"
}

please_wait() {
	MSG=${1+"$@"}
	if [ -z "$MSG" ]; then
		MSG="working"
	fi
	print_normal "$MSG ... please wait"
}

confirm() {
	while true; do
		print_reverse "$1"
		echo
		print_normal "[y or n]? "
		read CONFIRM
		CONFIRM=`echo $CONFIRM |$TR '[A-Z]' '[a-z]'`
		clear_last_line
		case $CONFIRM in
			"y*") CONFIRM="y";;
			"n*") CONFIRM="n";;
		esac
		if [ "$CONFIRM" = "y" -o "$CONFIRM" = "n" ]; then
			return
		fi
	done
}

do_main_title() {
	print_bold "$TITLE"
	echo
	echo "$SUBTITLE"
	echo ${1+"$@"}
	echo
	return 4
}

get_input() {
	DEFAULT="$1"
	shift
	LEGALINPUT=${1+"$@"}
	while true; do
		print_normal "Choice "
		print_menu_letter "($LEGALINPUT)"
		print_normal " [$DEFAULT]:"
		print_normal " "
		read INVAL
		INVAL=`echo $INVAL |$TR '[A-Z]' '[a-z]'`
		if [ -z "$INVAL" ]; then
			INVAL="$DEFAULT"
			clear_last_line
			return
		fi
		for IN in $LEGALINPUT; do
			if [ "$INVAL" = "$IN" ]; then
				clear_last_line
				return
			fi
		done
		INVAL=$DEFAULT
	done
}

show_command() {
	if [ "$EXEC" = "test_mode" ]; then
		echo "If we weren't in test mode we would be running:"
		echo $COMMAND
	else
		echo "Now running the following command:"
		echo $COMMAND
	fi
}

mod_command_for_test() {
	if [ "$EXEC" = "test_mode" ]; then
		COMMAND="echo $COMMAND"
	fi
}

must_be_root() {
	if [ `$IDPROG -u` -ne 0 ]; then
		echo "$PROG: you must be root to run this"
		exit 1
	fi
}

guess_package_name() {
	case $1 in
		ERACe8k*|devices.pci.11106510*) 
			echo "SafeNet PCI HSM Device Driver";;
	   	ERACecsa*|devices.pci.e810bc80*) 
			echo "ProtectServer Blue (CSA7000) Device Driver";;
		ERACcprov*) 
			echo "ProtectToolkit C Runtime (PS Blue)";;
		ERACcp8k*) 
			echo "ProtectToolkit C Runtime (PS Orange)";;
		ERACcprc*) 
			echo "ProtectToolkit C Remote Client Runtime";;
		ERACcpsw*) 
			echo "ProtectToolkit C SDK Software";;
		ERACcpsdk*) 
			echo "ProtectToolkit C Software Development Kit";;
		ERACjprov*) 
			echo "ProtectToolkit J Runtime";;
		ERACjpsdk*) 
			echo "ProtectToolkit J Software Development Kit";;
		ERACtoeft*) 
			echo "ProtectToolkit C Orange EFT";;
		ETptkeftw*) 
			echo "ProtectToolkit C White EFT";;
		ERACpenc*) 
			echo "Pin Encryption Software Development Kit";;
		ETlhsm*|ETpcihsm*)
			#echo "ProtectServer Gold Device Driver";;
			echo "SafeNet PCI HSM Device Driver";;
		ETrhsm*|ETnethsm*)
			echo "Remote Client HSM Access Provider";;
		ETnetsrv*)
			echo "HSM Net Server";;
		ETcprt-sdk*)
			echo "ProtectToolkit C SDK Runtime";;
		ETcprt*)
			echo "ProtectToolkit C Runtime";;
		ETcpsw*)
			echo "ProtectToolkit C SDK Software";;
		ETcpsdk*)
			echo "ProtectToolkit C SDK";;
		ETppohdk*)
		    echo "ProtectProcessing Orange HDK";;
		devices.pci.11106510*)
			#echo "ProtectServer Gold Device Driver";;
			echo "SafeNet PCI HSM Device Driver";;
		devices.pci.e810bc80*)
			echo "ProtectServer Blue (CSA7000) Device Driver";;
		esac
}

# pwd is ./
guess_packages() {
	trace_debug "guess_packages($1)"
	OS_DIRS=`ls_known_oss`

	for OS in $OS_DIRS; do 
		if [ -d "$OS" ]; then 
			(
				cd "$OS"
				echo "$OS:"
				for DIR in *; do
					if [ -d "$DIR" ]; then
						PKG=`cd "$DIR"; ls -1 |egrep "^ERAC|^ET|^devices" 2>/dev/null | fgrep -v .sig | ${FIRSTLINE}`
						if [ -z "$PKG" ]; then
							continue
						fi
						guess_package_name $PKG
					fi
				done
				echo
			)
		fi
	done
}

# METHODS:
# The build_install_command_* methods are called with "PKG~VERSION~DESCRIPTION"
# ... PKG is the _directory_ containing the package installation file
# The build_uninstall_command_* methods are called with "PKG~VERSION~DESCRIPTION"
# ... PKG is the machine-readable package name eg. ERACcp8k
# The list_installed_* methods must print "PKG~VERSION~DESCRIPTION"

# pwd is $OS
# no args
list_installed_Linux() {
	PACKAGES=`rpm -qa|egrep '^ET|^ERAC'`
	if [ -z "$PACKAGES" ]; then
		return
	fi
	for PKG in $PACKAGES; do
		VERSION=`rpm -q --qf "%{VERSION}" $PKG | sed 's/~/-/g'`
		DESC=`rpm -q --qf "%{SUMMARY}" $PKG | sed 's/~/-/g'`
		echo "nil~$PKG~$VERSION~$DESC"
	done
}
list_installed_Linux64() {
	PACKAGES=`rpm -qa|egrep '^ET|^ERAC'`
	if [ -z "$PACKAGES" ]; then
		return
	fi
	for PKG in $PACKAGES; do
		VERSION=`rpm -q --qf "%{VERSION}" $PKG | sed 's/~/-/g'`
		DESC=`rpm -q --qf "%{SUMMARY}" $PKG | sed 's/~/-/g'`
		echo "nil~$PKG~$VERSION~$DESC"
	done
}

# pwd is $OS
# $1 is directory to list
list_cd_Linux() {
	DIR="$1"

	PKGFILE=`cd "$DIR"; ls -1 *.rpm 2>/dev/null |${FIRSTLINE}`
	if [ -z "$PKGFILE" ]; then
		return
	fi
	PKGFILE="$DIR/$PKGFILE"
	NAME=`rpm -qp --qf "%{NAME}" $PKGFILE | sed 's/~/-/g'`
	VERSION=`rpm -qp --qf "%{VERSION}" $PKGFILE | sed 's/~/-/g'`
	DESC=`rpm -qp --qf "%{SUMMARY}" $PKGFILE | sed 's/~/-/g'`
	echo "$DIR~$NAME~$VERSION~$DESC"
}
list_cd_Linux64() {
	DIR="$1"

	PKGFILE=`cd "$DIR"; ls -1 *.rpm 2>/dev/null |${FIRSTLINE}`
	if [ -z "$PKGFILE" ]; then
		return
	fi
	PKGFILE="$DIR/$PKGFILE"
	NAME=`rpm -qp --qf "%{NAME}" $PKGFILE | sed 's/~/-/g'`
	VERSION=`rpm -qp --qf "%{VERSION}" $PKGFILE | sed 's/~/-/g'`
	DESC=`rpm -qp --qf "%{SUMMARY}" $PKGFILE | sed 's/~/-/g'`
	echo "$DIR~$NAME~$VERSION~$DESC"
	}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
build_install_command_Linux() {
	DIR="$1"
	PKG="$2"
	COMMAND="$INSTALL_PROGRAM -U $EXTRA_OPTIONS $DIR/$PKG*.rpm"
}
build_install_command_Linux64() {
	DIR="$1"
	PKG="$2"
	COMMAND="$INSTALL_PROGRAM -U $EXTRA_OPTIONS $DIR/$PKG*.rpm"
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_Linux() {
	DIR="$1"
	PKG="$2"
	COMMAND="$UNINSTALL_PROGRAM -e $EXTRA_OPTIONS $PKG"
}
build_uninstall_command_Linux64() {
	DIR="$1"
	PKG="$2"
	COMMAND="$UNINSTALL_PROGRAM -e $EXTRA_OPTIONS $PKG"
}

# SOLARIS METHODS

# pwd is $OS
# no args
list_installed_Solaris() {
	PACKAGES=`pkginfo | $AWK '{print $2}' | egrep '^ET|^ERAC'`
	if [ -z "$PACKAGES" ]; then
		return
	fi
	for PKG in $PACKAGES; do
		print_normal "nil~"
		pkginfo -l $PKG |$AWK '
			/VERSION:/   {$1=""; gsub(/[^-0-9.]/,"",$0); gsub(/~/,"-",$0); V=$0}
			/DESC:/      {$1=""; sub(/^ +/,"",$0); gsub(/~/,"-",$0); D=$0}
			/PKGINST:/   {$1=""; sub(/^ +/,"",$0); gsub(/~/,"-",$0); P=$0}
			END { printf "%s~%s~%s~\n", P, V, D }'
	done
}

# pwd is $OS
# $1 is directory to list
list_cd_Solaris() {
	DIR="$1"

	PKGFILE=`cd "$DIR"; ls -1 *.pkg 2>/dev/null | ${FIRSTLINE}`
	if [ -z "$PKGFILE" ]; then
		PKGDIR=`cd "$DIR"; ls -1 2>/dev/null | fgrep -v .sig | ${FIRSTLINE}` # pickup directory
	fi
	if [ -z "$PKGFILE" ]; then
		if [ -z "$PKGDIR" ]; then
			return
		fi
	fi

	P=`pwd`
	RAW_INFO=`if [ "$PKGFILE" ]; then pkginfo -l -d "$P/$DIR/$PKGFILE" ; else pkginfo -l -d "$P/$DIR" "$PKGDIR"; fi 2>/dev/null`

	if [ $? -eq 0 ]; then
		print_normal "$DIR~"
		echo "$RAW_INFO" |$AWK '
			/VERSION:/   {$1=""; gsub(/[^-0-9.]/,"",$0); gsub(/~/,"-",$0); V=$0}
			/DESC:/      {$1=""; sub(/^ +/,"",$0); gsub(/~/,"-",$0); D=$0}
			/PKGINST:/   {$1=""; sub(/^ +/,"",$0); gsub(/~/,"-",$0); P=$0}
			END { printf "%s~%s~%s~\n", P, V, D }'
	fi
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
build_install_command_Solaris() {
	DIR="$1"
	PKG="$2"
	COMMAND="$INSTALL_PROGRAM $EXTRA_OPTIONS -d `pwd`/$DIR $PKG"
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_Solaris() {
	DIR="$1"
	PKG="$2"

	COMMAND="$UNINSTALL_PROGRAM $EXTRA_OPTIONS $PKG"
}

# AIX METHODS

# pwd is $OS
# no args
list_installed_AIX() {
	lslpp -L -c all |egrep '^ERAC|^ET|^devices.pci.11106510|^devices.pci.e810bc80' | while read DATA; do
		SAVE_IFS=$IFS
		IFS=':'
		set -- $DATA
		PKG=`echo "$1" | sed 's/~/-/g'`
		VERSION=`echo "$3"| sed 's/~/-/g'`
		DESCRIPTION=`echo "${8}"| sed 's/~/-/g'`
		IFS=$SAVE_IFS
		echo "nil~$PKG~$VERSION~$DESCRIPTION"
	done
}

# pwd is $OS
# $1 is directory to list
list_cd_AIX() {
	trace_debug "list_cd_AIX(${1+"$@"})"
	DIR="$1"

	PKGFILE=`cd $DIR; ls -1 *.bff 2>/dev/null |${FIRSTLINE}`
	if [ -z "$PKGFILE" ]; then
		return
	fi
	DATA=`installp -L -d $DIR/$PKGFILE`
	SAVE_IFS=$IFS
	IFS=':'
	set -- $DATA
	PKG=`echo "$1" | sed 's/~/-/g'`
	VERSION=`echo "$3"| sed 's/~/-/g'`
	DESCRIPTION=`echo "${12}"| sed 's/~/-/g'`
	IFS=$SAVE_IFS
	echo "$DIR~$PKG~$VERSION~$DESCRIPTION"
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
build_install_command_AIX() {
	DIR="$1"
	PKG="$2"
	COMMAND="$INSTALL_PROGRAM $EXTRA_OPTIONS -acgNQqwX -d `pwd`/$DIR/$PKG.bff $PKG.rte"
	case $PKG in
		ETpcihsm*|devices*) POSTINSTALL="cfgmgr";;
	esac
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_AIX() {
	DIR="$1"
	PKG="$2"

	COMMAND="$INSTALL_PROGRAM $EXTRA_OPTIONS -u $PKG"
}

# HPUX METHODS

# pwd is $OS
# no args
list_installed_HPUX() {
	# Assumes VERSION contains no spaces ....

	swlist | egrep '^  (ERAC|ET)' | $AWK '{P=$1; V=$2; $1=""; $2=""; gsub("^ +", ""); printf "nil~%s~%s~%s~\n", P, V, $0 }'
}

# pwd is $OS
# $1 is directory to list
list_cd_HPUX() {
	trace_debug "list_cd_HPUX(${1+"$@"})"
	DIR="$1"

	PKGFILE=`cd "$DIR"; ls -1 *.depot 2>/dev/null |${FIRSTLINE}`
	if [ -z "$PKGFILE" ]; then
		return
	fi
	swlist -s `pwd`/$DIR/$PKGFILE |egrep '^  (ERAC|ET)' |$AWK '{P=$1; V=$2; $1=""; $2=""; gsub("^ +", ""); printf "'"$DIR"'~%s~%s~%s~\n", P, V, $0 }'
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
# swinstall fails if the depot file is on a NFS mounted system. In this case,
# copy it to /tmp and hope _that_ is not NFS mounted.
build_install_command_HPUX() {
	trace_debug "build_install_command_HPUX(${1+"$@"})"
	DIR="$1"
	PKG="$2"
	DEPOTFILE=`cd "$DIR"; ls -1 *.depot 2>/dev/null | ${FIRSTLINE}`
	DEPOTDIR="`pwd`/$DIR"

	# is the installation file on an NFS volume?
	if ! df "$DEPOTDIR" | $AWK '{print $1}' |grep ":" >/dev/null; then
		# the depot file is NFS mounted
		cp "$DEPOTDIR/$DEPOTFILE" "/tmp/$DEPOTFILE"
		DEPOTDIR="/tmp"
	fi

	COMMAND="$INSTALL_PROGRAM $EXTRA_OPTIONS -s $DEPOTDIR/$DEPOTFILE $PKG"
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
cleanup_HPUX() {
	DIR="$1"
	PKG="$2"
	DEPOTFILE=`cd "$DIR"; ls -1 *.depot 2>/dev/null | ${FIRSTLINE}`
	DEPOTDIR="`pwd`/$DIR"

	# was the installation file on an NFS volume?
	if ! df "$DEPOTDIR" | $AWK '{print $1}' |grep ":" >/dev/null; then
		# the depot file was NFS mounted
		rm "/tmp/$DEPOTFILE"
	fi
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_HPUX() {
	DIR="$1"
	PKG="$2"

	COMMAND="$UNINSTALL_PROGRAM $EXTRA_OPTIONS $PKG"
}

# UnixWare METHODS

# pwd is $OS
# no args
list_installed_UnixWare() {
	list_installed_Solaris $@
}

# pwd is $OS
# $1 is directory to list
list_cd_UnixWare() {
	list_cd_Solaris $@
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
build_install_command_UnixWare() {
	build_install_command_Solaris $@
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_UnixWare() {
	build_uninstall_command_Solaris $@
}

# OpenServer METHODS

# pwd is $OS
# no args
list_installed_OpenServer() {
	list_installed_Solaris $@
}

# pwd is $OS
# $1 is directory to list
list_cd_OpenServer() {
	list_cd_Solaris $@
}

# pwd=./$OSNAME
# $1 is DIR
# $2 is PKG
build_install_command_OpenServer() {
	build_install_command_Solaris $@
}

# pwd=./
# $1 is DIR
# $2 is PKG
build_uninstall_command_OpenServer() {
	build_uninstall_command_Solaris $@
}

fqn() {

	# return the full filename, removing ./ ../ adding `pwd` if necessary

	FILE="$1"

	# file		dot relative
	# ./file	dot relative
	# ../file	parent relative
	# /file		absolute
	while true; do
		case "$FILE" in
			/* ) 		
		# Remove /./ inside filename:
			while echo "$FILE" |fgrep "/./" >/dev/null 2>&1; do
				FILE=`echo "$FILE" | sed "s/\\/\\.\\//\\//"`
			done
		# Remove /../ inside filename:
			while echo "$FILE" |grep "/[^/][^/]*/\\.\\./" >/dev/null 2>&1; do
				FILE=`echo "$FILE" | sed "s/\\/[^/][^/]*\\/\\.\\.\\//\\//"`
			done
			echo "$FILE"
			exit 0
			;;
			
			*)
			FILE=`pwd`/"$FILE"
			;;
		esac

	done
}

default_hsm_link() {
	set -- $HSM_LINK_LABELS
	for HSM_LINK in $LEGAL_HSM_LINKS; do
		if [ -f "$HSM_LINK" ]; then
			echo $HSM_LINK
			return 0
		fi
		shift
	done
	return 1
}

default_cryptoki() {
	set -- $CRYPTOKI_LABELS
	for CRYPTOKI in $LEGAL_CRYPTOKIS; do
		if [ -f "$CRYPTOKI" ]; then
			echo $CRYPTOKI
			return 0
		fi
		shift
	done
	return 1
}

# makes 
# ln -s /opt/PKG/lib/sparc/libX.so to /opt/PTK/lib/libX.so
# ln -s /opt/PKG/lib/sparc/sparv9/libX.so to /opt/PTK/lib/sparcv9/libX.so
make_links() {
	PKG="$1" # eg ETpcihsm
	F1="$2"  # eg lib/bin/doc/man
	F2="$3"  # eg sparc/linux-i386/hpux-pa/hpux-ia64/aix-ppc or ""
	F3="$4"  # eg sparcv9/64 or ""

	if [ -d ${BASENAME}/${PKG}/$F1/$F2 ] ; then
		mkdir -p ${BASENAME}/PTK/$F1 2>/dev/null

		(
			cd ${BASENAME}/${PKG}/$F1/$F2
			for i in *; do
				if [ ! -d $i ]; then
					if [ ! $LINKTEST ${BASENAME}/PTK/$F1/$i ]; then
						ln -s `pwd`/$i ${BASENAME}/PTK/$F1/$i
					fi
				fi
			done
		)
	fi

	if [ "$F2" -a "$F3" -a -d "${BASENAME}/${PKG}/$F1/$F2/$F3" ] ; then
		mkdir -p ${BASENAME}/PTK/$F1/$F3 2>/dev/null

		(
			cd "${BASENAME}/${PKG}/$F1/$F2/$F3"
			for i in *; do
				if [ ! -d $i ]; then
					if [ ! $LINKTEST "${BASENAME}/PTK/$F1/$F3/$i" ]; then
						ln -s `pwd`/$i "${BASENAME}/PTK/$F1/$F3/$i"
					fi
				fi
			done
		)
	fi
}

check_links() {
	# Remove any dead symbolic links:
	if [ -d "$BASENAME/PTK" ]; then
		find $BASENAME/PTK | while read LINK; do
			if [ $LINKTEST "$LINK" ]; then
				if follow_link $LINK >/dev/null 2>&1; then
					:
				else
					rm -f $LINK
				fi
			fi
		done
	fi

	# remove any empty directories:
	DONE=""
	while [ -d "$BASENAME/PTK" -a -z "$DONE" ]; do
		DONE="yes"
		find $BASENAME/PTK | while read LINK; do
			if [ -d "$LINK" ]; then
				rmdir "$LINK" >/dev/null 2>&1
				if [ $? -eq 0 ]; then
					DONE=""
				fi
			fi
		done
	done

	rmdir $BASENAME/PTK >/dev/null 2>&1

	CRYPTOKI=`default_cryptoki`
 	if [ $CRYPTOKI ]; then # there is at least one cryptoki available
		CURRENT_CRYPTOKI=`follow_link $DEFAULT_CRYPTOKI_LINK`
		if [ "$CURRENT_CRYPTOKI" ]; then
			# all is well
			:
		else
			DIR=`dirname $DEFAULT_CRYPTOKI_LINK`
			mkdir -p $DIR 2>/dev/null
			ln -s $CRYPTOKI $DEFAULT_CRYPTOKI_LINK
		fi
		if [ "$LIB64" ]; then
			# make sure this link follows the main one:
			rm -f $DEFAULT_CRYPTOKI_LINK64
			F=`basename $CRYPTOKI`
			D=`dirname $CRYPTOKI`
			if [ -f $D/$LIB64/$F ]; then
				mkdir -p `dirname $DEFAULT_CRYPTOKI_LINK64` 2>/dev/null
				ln -s $D/$LIB64/$F $DEFAULT_CRYPTOKI_LINK64
			fi
		fi
		if [ "$LEGACY" ]; then
			# make sure this link follows the main one:
			rm -f $DEFAULT_CRYPTOKI_LINK_LEGACY
			F=`basename $CRYPTOKI`
			D=`dirname $CRYPTOKI`
			if [ -f $D/$LEGACY/$F ]; then
				mkdir -p `dirname $DEFAULT_CRYPTOKI_LINK_LEGACY` 2>/dev/null
				ln -s $D/$LEGACY/$F $DEFAULT_CRYPTOKI_LINK_LEGACY
			fi
		fi
	fi
	CURRENT_CRYPTOKI=`follow_link $DEFAULT_CRYPTOKI_LINK`

	HSM_LINK=`default_hsm_link`
	if [ "$HSM_LINK" ]; then # there is at least one hsm library available
		CURRENT_HSM_LINK=`follow_link $DEFAULT_HSM_LINK`
		if [ "$DEFAULT_HSM_LINK" ]; then
			# all is well
			:
		else
			DIR=`dirname $DEFALT_HSM_LINK`
			mkdir -p $DIR 2>/dev/null
			ln -s $HSM_LINK $DEFAULT_HSM_LINK
		fi
		if [ "$LIB64" ]; then
			rm -f $DEFAULT_HSM_LINK64
			F=`basename $HSM_LINK`
			D=`dirname $HSM_LINK`
			if [ -f $D/$LIB64/$F ]; then
				mkdir -p `dirname $DEFAULT_HSM_LINK64` 2>/dev/null
				ln -s $D/$LIB64/$F $DEFAULT_HSM_LINK64
			fi
		fi
		if [ "$LEGACY" ]; then
			rm -f $DEFAULT_HSM_LINK_LEGACY
			F=`basename $HSM_LINK`
			D=`dirname $HSM_LINK`
			if [ -f $D/$LEGACY/$F ]; then
				mkdir -p `dirname $DEFAULT_HSM_LINK_LEGACY` 2>/dev/null
				ln -s $D/$LEGACY/$F $DEFAULT_HSM_LINK_LEGACY
			fi
		fi
	fi
	CURRENT_HSM_LINK=`follow_link $DEFAULT_HSM_LINK`

	# Make sure other links are in place - if not, create them for the
	# product containing the default cryptoki eg.
	# /opt/ERACcprc/lib/linux-i386/libctclient.so. These links may be
	# missing eg if remote client and SDK are installed and then SDK
	# removed.

	if [ "$CURRENT_CRYPTOKI" ]; then
		DIR=`dirname $CURRENT_CRYPTOKI` 	# eg. /opt/ERACcprc/lib/linux-i386
		DIR=`dirname $DIR` 					# eg. /opt/ERACcprc/lib
		DIR=`dirname $DIR` 					# eg. /opt/ERACcprc
		PKG=`basename $DIR` 				# eg. ERACcprc
		make_links $PKG lib
		make_links $PKG lib $ARCH $LIB64
		if [ "$LEGACY" ]; then
			L=$LIBSUFFIX 
			LIBSUFFIX=$LEGACY_LIBSUFFIX 
			make_links $PKG lib $ARCH $LEGACY
			LIBSUFFIX=$L
		fi
		make_links $PKG bin
		make_links $PKG bin $ARCH $LIB64
		make_links $PKG doc
		make_links $PKG man
		make_links $PKG man/man1
		make_links $PKG man/man1m
	fi

	# Any others?
	for PKG in ERACe8k ERACcprc ERACcpsdk ERACcp8k ERACcprs ERACcpsw ERACcprov ETcprt ETcpsw ETcpsdk ETlhsm ETpcihsm ETrhsm ETnethsm; do
		if [ -d $BASENAME/$PKG ]; then
			make_links $PKG lib
			make_links $PKG lib $ARCH $LIB64
			if [ "$LEGACY" ]; then
				L=$LIBSUFFIX 
				LIBSUFFIX=$LEGACY_LIBSUFFIX 
				make_links $PKG lib $ARCH $LEGACY
				LIBSUFFIX=$L
			fi
			make_links $PKG bin
			make_links $PKG bin $ARCH $LIB64
			make_links $PKG doc
			make_links $PKG man
			make_links $PKG man/man1
			make_links $PKG man/man1m
		fi
	done

	return 0
}

ls_known_oss() {
	ls -d $KNOWN_OS_DIRS 2>/dev/null
	cd ..
}

# parse input records into DIR PKG VERSION DESCRIPTION and paint menu
# do this in a subroutine to avoid forking in Solaris (& UnixWare &
# OS5?) sh: $1=number to stop at; if 0 do all but suppress the numeric
# prefixes (in this case it's a listing, not a menu)
paint_menu_items() {
	CARDINAL=$1
	if [ "$1" = 0 ]; then
		LISTING=1
	else
		LISTING=""
	fi

	LEGAL=""
	I=0
	while read ENTRY; do
		I=`expr $I + 1`
		SAVE_IFS=$IFS
		IFS='~'
		set -- $ENTRY
		DIR="$1"
		PKG="$2"
		VERSION=`echo "$3" |awk '{printf("%-9s",$0)}'` # 'X.XX.X ' - left justified!
		DESCRIPTION="$4"
		IFS=$SAVE_IFS

		if [ "$LISTING" ]; then
			echo "$VERSION$DESCRIPTION" |chop
		else
			print_menu_letter $I
			echo " $VERSION$DESCRIPTION" |chop
		fi
		LEGAL="$LEGAL $I"
		if [ "$CARDINAL" = "$I" ]; then
			return $I
		fi
	done 
	return $I
}

uninstall_menu() {
	INVAL="$REPAINT"
	INSTALLED=$TMPFILE-installed

	while true; do
		case "$INVAL" in
		"$REPAINT")
			if [ ! -s "$TMPFILE-installed" ]; then 
				print_alarm "No SafeNet packages installed" 
				echo
				press_enter
				return
			fi

			do_main_title "Main menu >> Uninstall Menu"
			SKIP=$?

			paint_menu_items < $TMPFILE-installed
			SKIP=`expr $SKIP + $?`

			echo
			print_menu_letter "b"
			echo " back"
			print_menu_letter "q"
			echo " quit the utility"
			SKIP=`expr $SKIP + 5`

			skip_lines $SKIP
			;;

		[123456789]*)
			# NB: we're re-using INSTALLED from the screen repaint to save time!!
			paint_menu_items $INVAL < $TMPFILE-installed >/dev/null
			echo "Uninstall package:"
			confirm "$VERSION: $DESCRIPTION"
			if [ "$CONFIRM" = "y" ]; then
				EXTRA_OPTIONS=""
				if [ -n "$POSSIBLE_UNINSTALL_OPTIONS" ]; then
					print_reverse "Any extra options for the uninstallation program?"
					echo
					print_normal "eg. $POSSIBLE_UNINSTALL_OPTIONS [] "
					read EXTRA_OPTIONS
				fi
				please_wait "uninstalling"
				echo
				build_uninstall_command_$OSNAME "$DIR" "$PKG"
				show_command
				mod_command_for_test
				# use 'tee' in case input is needed eg. "Relink Kernel now?" in OS5
				# but $? is then the result of the tee rather than COMMAND so
				# we can't detect success or failure and TMPFILE is useless
				# $COMMAND |tee /dev/tty >$TMPFILE 2>&1
				$COMMAND
				if [ "$?" -ne 0 ]; then
					print_alarm "There were errors:"
					echo
				else
					print_reverse "Success!"
					echo
				fi
				please_wait "scanning system for installed packages"
				list_installed_$OSNAME > $TMPFILE-installed
				wait_over
				check_links
				press_enter
			else
				echo "Did not uninstall $VERSION: $DESCRIPTION"
				press_enter
			fi
			INVAL="$REPAINT"
			continue
			;;

		b|B)
			break
			;;
		q|Q) 
			confirm "Really quit?"
			if [ "$CONFIRM" = "y" ]; then
				exit 0
			fi
			INVAL="$REPAINT"
			;;
		esac

		get_input "$REPAINT" $LEGAL b q
	done
}

install_menu() {
	INVAL="$REPAINT"

	while true; do
		case "$INVAL" in
		"$REPAINT")
			do_main_title "Main menu >> Install Menu"
			SKIP=$?

			paint_menu_items < $TMPFILE-cd
			SKIP=`expr $SKIP + $?`

			echo
			print_menu_letter "b"
			echo " back"
			print_menu_letter "q"
			echo " quit the utility"

			SKIP=`expr $SKIP + 5`
			skip_lines $SKIP
			;;

		[123456789]*)
			paint_menu_items $INVAL < $TMPFILE-cd >/dev/null

			echo "Install:"
			confirm "$VERSION: $DESCRIPTION"
			if [ "$CONFIRM" != "y" ]; then
				echo "Did not install $VERSION: $DESCRIPTION"
				press_enter
				INVAL="$REPAINT"
				continue
			fi

			EXTRA_OPTIONS=""
			if [ -n "$POSSIBLE_INSTALL_OPTIONS" ]; then
				print_reverse "Any extra options for the installation program?"
				echo
				print_normal "eg. $POSSIBLE_INSTALL_OPTIONS [] "
				read EXTRA_OPTIONS
			fi
			please_wait "installing"
			echo
			(
				cd $OS_DIR
				POSTINSTALL=""
				build_install_command_$OSNAME "$DIR" "$PKG"
				show_command
				mod_command_for_test
				# use 'tee' in case input is needed eg. "Relink Kernel now?" in OS5
				# but $? is then the result of the tee rather than COMMAND so
				# we can't detect success or failure
				# $COMMAND |tee /dev/tty >$TMPFILE 2>&1
				$COMMAND
				if [ "$?" -ne 0 ]; then
					print_alarm "There were errors:"
					echo
				else
					if [ "$POSTINSTALL" ]; then
						if [ "$OSNAME" = "AIX" ]; then
							echo ""
							echo "Running sync"
							sync sync sync sync
						fi

						please_wait "Running $POSTINSTALL"
						echo ""
						$POSTINSTALL
						wait_over
					fi
					print_reverse "Success!"
					echo

					# Install a copy of this script, if not already there or older than this:
					DEST=/usr/bin
					SELF_INSTALL=""
					if [ -x "$DEST/$PROG" ]; then
						if [ "`${FIRSTLINE} $DEST/$PROG 2>/dev/null`" = "#! /bin/sh" ]; then
							if grep PTK $DEST/$PROG >/dev/null 2>&1; then
								EXISTING_VERSION=`$DEST/$PROG -V 2>/dev/null`
								if [ $? = 0 ]; then
									SELF_INSTALL=`awk "END {if (\"$EXISTING_VERSION\" < \"$PROG_VERSION\") { print \"yes\" } }" </dev/null 2>/dev/null`
								fi
							fi
						fi
					else
						SELF_INSTALL="yes"
					fi
					if [ "$SELF_INSTALL" ]; then
						echo "$PROG: Installing a copy of this script in $DEST"
						cp -f $PROG_DIR/$PROG $DEST
					fi

				fi
				if [ "$OSNAME" = "HPUX" ]; then
					cleanup_HPUX "$DIR" "$PKG"
				fi
				
			)
			please_wait "scanning system for installed packages"
			list_installed_$OSNAME > $TMPFILE-installed
			wait_over
			press_enter
			INVAL="$REPAINT"
			continue
			;;

		b|B)
			break
			;;

		q|Q) 
			confirm "Really quit?"
			if [ "$CONFIRM" = "y" ]; then
				exit 0
			fi
			INVAL="$REPAINT"
			;;
		esac

		get_input "$REPAINT" $LEGAL b q
	done
}

# pwd=./
# $1=message
# $2=all or OS to list
print_packages() {
	trace_debug "print_packages(${1+"$@"})"
	(
		# enter_bold - don't use terminal enhancements in a pager
		echo "$1"
		echo
		SKIP=4

		if [ $2 = "all" ]; then
			cat $TMPFILE-cd-guess
			L=`cat $TMPFILE-cd-guess | wc -l `
			SKIP=`expr $SKIP + $L`
		else
			paint_menu_items 0 < $TMPFILE-cd
			SKIP=`expr $? + 5`
			echo
		fi
		return $SKIP
	) > $TMPFILE
	SKIP=$?
	OUTPUT_METHOD=cat
	DISPLAY_LINES=`cat $TMPFILE |wc -l`
	DISPLAY_LINES=`expr $DISPLAY_LINES + 1`
	if [ "$DISPLAY_LINES" -ge "$SCREEN_HEIGHT" ]; then
		OUTPUT_METHOD=$PAGER
	fi
	$OUTPUT_METHOD < $TMPFILE
	rm $TMPFILE
	if [ "$OUTPUT_METHOD" = cat ]; then
		skip_lines $SKIP
	fi

	press_enter
}

list_cd_menu() {
	INVAL="$REPAINT"

	while true; do
		case "$INVAL" in
		"$REPAINT") 
			do_main_title "Main Menu >> List CD menu"
			SKIP=$?
			print_menu_letter "1"
			echo " list packages for this platform"
			print_menu_letter "2"
			echo " list packages for all platforms"
			echo
			print_menu_letter "b"
			echo " back"
			print_menu_letter "q"
			echo " quit the utility"
			SKIP=`expr $SKIP + 7`
			skip_lines $SKIP
			;;

		1)
			print_packages "Packages available for $OSNAME on this CD:" $OSNAME
			INVAL="$REPAINT"
			continue
			;;

		2)
			print_packages "Packages available on this CD:" all
			INVAL="$REPAINT"
			continue
			;;

		b|B) 
			INVAL="$REPAINT"
			return 
			;;

		q|Q) 
			confirm "Really quit?"
			if [ "$CONFIRM" = "y" ]; then
				exit 0
			fi
			INVAL="$REPAINT"
			;;

		esac

		get_input "$REPAINT" 1 2 b q
	done
}

# print the filename pointed to by $1 otherwise "" if a dead link
follow_link() {
	L=$1

	if [ ! -f "$L" ] ; then
		echo ""
		return 0
	fi

	if [ -d "$L" ]; then
		echo $L
		return 2
	fi

	while [ $LINKTEST "$L" ]; do
		# L=`ls -l $L | awk '{print $11}'`
		L=`ls -l $L | sed "s/^.*-> //"`

		if [ -d "$L" ]; then
			echo $L
			return 2
		fi

		if [ ! -f "$L" ] ; then # -f == exists, could be another symbolic link
			echo ""
			return 0
		fi
 	done
	echo $L
	return 0
}

# Returns the number of hsm_link files installed
probe_hsm_links() {
	NUM_HSMS=0
	set -- $HSM_LINK_LABELS
	for C in $LEGAL_HSM_LINKS; do
		if [ -f "$C" ]; then
			echo $1 $C
			NUM_HSMS=`expr $NUM_HSMS + 1`
		fi
		shift
	done
	return $NUM_HSMS
}

count_hsm_links() {
	probe_hsm_links >/dev/null
	echo $?
}	

# Paints menu items and sets HSM_LINK and HSM_LINK_FILE parameters
# Parameters:
# $1 is the item to "paint": "" means all
paint_hsm_link_menu() {
	CARDINAL=$1
	I=$NUM_CRYPTOKIS
	while read HSM_LINK HSM_LINK_FILE; do
		I=`expr $I + 1`
		FLAG="   "
		if [ "$CURRENT_HSM_LINK" = "$HSM_LINK_FILE" ]; then
			FLAG=" * "
		fi
		DESC=`guess_package_name $HSM_LINK`
		print_menu_letter $I
		echo "$FLAG$DESC"
		LEGAL="$LEGAL $I"
		if [ "$CARDINAL" = "$I" ]; then
			return $I
		fi
	done
	return $I
}

# Returns the number of cryptoki files installed
# SDK can contain sw, rc and 8k/7k cryptokis.
probe_cryptokis() {
	NUM_CRYPTOKIS=0
	set -- $CRYPTOKI_LABELS
	for C in $LEGAL_CRYPTOKIS; do
		if [ -f "$C" ]; then
			echo $1 $C
			NUM_CRYPTOKIS=`expr $NUM_CRYPTOKIS + 1`
		fi
		shift
	done
	return $NUM_CRYPTOKIS
}

count_cryptokis() {
	probe_cryptokis >/dev/null
	echo $?
}	

# Paints menu items and sets CRYPTOKI and CRYPTOKI_FILE parameters
# Parameters:
# $1 is the item to "paint": "" means all
paint_cryptoki_menu() {
	CARDINAL=$1
	I=0
	while read CRYPTOKI CRYPTOKI_FILE; do
		I=`expr $I + 1`
		FLAG="   "
		if [ "$CURRENT_CRYPTOKI" = "$CRYPTOKI_FILE" ]; then
			FLAG=" * "
		fi
		DESC=`guess_package_name $CRYPTOKI`
		print_menu_letter $I
		echo "$FLAG$DESC"
		LEGAL="$LEGAL $I"
		if [ "$CARDINAL" = "$I" ]; then
			return $I
		fi
	done
	return $I
}

set_cryptoki_hsm_menu() {
	INVAL="$REPAINT"
	while true; do
		case "$INVAL" in
		"$REPAINT") 
			do_main_title "Main Menu >> Check/Set Default Cryptoki & HSM Menu"
			SKIP=$?
			LEGAL=""

			CURRENT_CRYPTOKI==""
			if [ -f "$DEFAULT_CRYPTOKI_LINK" ]; then
				CURRENT_CRYPTOKI=`follow_link "$DEFAULT_CRYPTOKI_LINK"`
			fi

			probe_cryptokis >$TMPFILE
			NUM_CRYPTOKIS=$?
			if [ "$NUM_CRYPTOKIS" -ge 1 ]; then
				echo "-------------------- Cryptoki Selection --------------------"
				SKIP=`expr $SKIP + 1`
				paint_cryptoki_menu <$TMPFILE
				SKIP=`expr $SKIP + $NUM_CRYPTOKIS`
				echo
				SKIP=`expr $SKIP + 1`
			fi

			CURRENT_HSM_LINK=""
			if [ -f "$DEFAULT_HSM_LINK" ]; then
				CURRENT_HSM_LINK=`follow_link "$DEFAULT_HSM_LINK"`
			fi

			probe_hsm_links >$TMPFILE-hsm
			NUM_HSMS=$?
			cat $TMPFILE-hsm >>$TMPFILE
			if [ "$NUM_HSMS" -gt 1 ]; then
				echo "---------------------- HSM Selection ----------------------"
				SKIP=`expr $SKIP + 1`
			fi

			if [ "$NUM_HSMS" -ge 1 ]; then
				paint_hsm_link_menu <$TMPFILE-hsm
				SKIP=`expr $SKIP + $NUM_HSMS`
			fi

			echo
			echo "b back"
			echo "q quit the utility"
			SKIP=`expr $SKIP + 5`
			skip_lines $SKIP
			;;

		[123456789]*)
			if [ "$INVAL" -le "$NUM_CRYPTOKIS" ]; then
				# Setup the CRYPTOKI & CRYPTOKI_FILE parameters:
				paint_cryptoki_menu $INVAL <$TMPFILE >/dev/null

				echo "Change the default cryptoki to:"
				PKGNAME=`guess_package_name $CRYPTOKI`
				confirm "$PKGNAME"
				if [ "$CONFIRM" = "y" ]; then
					rm -f "$DEFAULT_CRYPTOKI_LINK"
					ln -s "$CRYPTOKI_FILE" "$DEFAULT_CRYPTOKI_LINK"
					if [ "$LIB64" ]; then
						rm -f $DEFAULT_CRYPTOKI_LINK64
						F=`basename $CRYPTOKI_FILE`
						D=`dirname $CRYPTOKI_FILE`
						if [ -f $D/$LIB64/$F ]; then
							mkdir -p `dirname $DEFAULT_CRYPTOKI_LINK64` 2>/dev/null
							ln -s $D/$LIB64/$F $DEFAULT_CRYPTOKI_LINK64
						fi
					fi
					if [ "$LEGACY" ]; then
						rm -f $DEFAULT_CRYPTOKI_LINK_LEGACY
						F=`basename $CRYPTOKI_FILE`
						D=`dirname $CRYPTOKI_FILE`
						if [ -f $D/$LEGACY/$F ]; then
							mkdir -p `dirname $DEFAULT_CRYPTOKI_LINK_LEGACY` 2>/dev/null
							ln -s $D/$LEGACY/$F $DEFAULT_CRYPTOKI_LINK_LEGACY
						fi
					fi
				fi
			else
				# Setup the HSM_LINK & HSM_LINK_FILE parameters:
				paint_hsm_link_menu $INVAL <$TMPFILE-hsm >/dev/null

				echo "Change the default hsm link to:"
				PKGNAME=`guess_package_name $HSM_LINK`
				confirm "$PKGNAME"
				if [ "$CONFIRM" = "y" ]; then
					rm -f "$DEFAULT_HSM_LINK"
					ln -s "$HSM_LINK_FILE" "$DEFAULT_HSM_LINK"
					if [ "$LIB64" ]; then
						rm -f $DEFAULT_HSM_LINK64
						F=`basename $HSM_LINK_FILE`
						D=`dirname $HSM_LINK_FILE`
						if [ -f $D/$LIB64/$F ]; then
							mkdir -p `dirname $DEFAULT_HSM_LINK64` 2>/dev/null
							ln -s $D/$LIB64/$F $DEFAULT_HSM_LINK64
						fi
					fi
					if [ "$LEGACY" ]; then
						rm -f $DEFAULT_HSM_LINK_LEGACY
						F=`basename $HSM_LINK_FILE`
						D=`dirname $HSM_LINK_FILE`
						if [ -f $D/$LEGACY/$F ]; then
							mkdir -p `dirname $DEFAULT_HSM_LINK_LEGACY` 2>/dev/null
							ln -s $D/$LEGACY/$F $DEFAULT_HSM_LINK_LEGACY
						fi
					fi
				fi
			fi
			rm $TMPFILE
			INVAL="$REPAINT"
			continue
			;;

		b|B) 
			INVAL="$REPAINT"
			return 
			;;

		q|Q) 
			confirm "Really quit?"
			if [ "$CONFIRM" = "y" ]; then
				exit 0
			fi
			INVAL="$REPAINT"
			;;

		esac

		get_input "$REPAINT" $LEGAL b q
	done
}

main_menu() {
	INVAL="$REPAINT"
	while true; do
		case "$INVAL" in
		"$REPAINT") 
			LEGAL=""
			do_main_title "Main menu"
			SKIP=$?
			print_menu_letter "1"
			echo " list SafeNet packages already installed"
			LEGAL="$LEGAL 1"
			SKIP=`expr $SKIP + 1`

			if [ "$HAVE_PACKAGES" ]; then
				print_menu_letter "2"
				echo " list packages on CD"
				SKIP=`expr $SKIP + 1`
				LEGAL="$LEGAL 2"
			fi

			if [ "$HAVE_PACKAGES" ]; then
				if [ "$IS_ROOT" ]; then
					print_menu_letter "3"
					echo " install a package from this CD"
					SKIP=`expr $SKIP + 1`
					LEGAL="$LEGAL 3"
				fi
			fi

			if [ "$IS_ROOT" ]; then
				print_menu_letter "4"
				echo " uninstall a SafeNet package"
				SKIP=`expr $SKIP + 1`
				LEGAL="$LEGAL 4"
			fi

			if [ "$IS_ROOT" ]; then
				NUM_CRYPTOKIS=`count_cryptokis`
				NUM_HSM_LINKS=`count_hsm_links`
				if [ "$NUM_CRYPTOKIS" -gt 1 -o "$NUM_HSM_LINKS" -gt 1 ]; then
					print_menu_letter "5"
					echo " Set the default cryptoki and/or hsm link"
					SKIP=`expr $SKIP + 1`
					LEGAL="$LEGAL 5"
				fi
			fi

			echo
			print_menu_letter "q"
			echo " quit the utility"
			echo

			if [ ! "$IS_ROOT" ]; then
				echo "Run this as root to be able to install and uninstall packages"
				SKIP=`expr $SKIP + 1`
			fi
			if [ ! "$HAVE_PACKAGES" ]; then
				echo "Change directory to the CDROM before running this to see the CDROM contents"
				SKIP=`expr $SKIP + 1`
			fi
			#print_normal "Support is available at: "
			#print_bold "support@eracom-tech.com"
			echo
			SKIP=`expr $SKIP + 6`
			skip_lines $SKIP
			;;

		1)
			if [ ! -s "$TMPFILE-installed" ]; then 
				print_alarm "No SafeNet packages installed" 
				echo
				press_enter
				INVAL="$REPAINT"
				continue
			fi

			(
				# enter_bold # don't put enhancements through PAGER
				echo "SafeNet packages already installed on `hostname`:"
				echo
				SKIP=2
				paint_menu_items 0 < $TMPFILE-installed
				SKIP=`expr $SKIP + $? + 3`
				echo ""
				return $SKIP
			)  > $TMPFILE
			SKIP=$?
			OUTPUT_METHOD=cat
			DISPLAY_LINES=`cat $TMPFILE |wc -l`
			DISPLAY_LINES=`expr $DISPLAY_LINES + 1`
			if [ "$DISPLAY_LINES" -gt "$SCREEN_HEIGHT" ]; then
				OUTPUT_METHOD=$PAGER
			fi
			$OUTPUT_METHOD < $TMPFILE
			rm $TMPFILE
			if [ "$OUTPUT_METHOD" = cat ]; then
				skip_lines $SKIP
			fi

			press_enter

			INVAL="$REPAINT"
			continue
			;;

		2) 
			list_cd_menu 
			INVAL="$REPAINT"
			continue
			;;

		3)
			install_menu
			INVAL="$REPAINT"
			continue
			;;

		4)
			uninstall_menu
			INVAL="$REPAINT"
			continue
			;;

		5)
			set_cryptoki_hsm_menu
			INVAL="$REPAINT"
			continue
			;;

		q|Q) 
			confirm "Really quit?"
			if [ "$CONFIRM" = "y" ]; then
				exit 0
			fi
			INVAL="$REPAINT"
			;;
		esac

		get_input "$REPAINT" $LEGAL q
	done
}

check_packages() {
	HAVE_PACKAGES=""
	if [ -d "$OS_DIR" ]; then
		please_wait "scanning CD"
		(
			
			cd $OS_DIR
			for DIR in *; do
				if [ -d "$DIR" ]; then
					list_cd_$OSNAME "$DIR"
				fi
			done
		) >$TMPFILE-cd

		if [ -s "$TMPFILE-cd" ]; then
			HAVE_PACKAGES="yes"
		fi
		guess_packages >$TMPFILE-cd-guess
		wait_over
	fi
	please_wait "scanning system for installed packages"
	list_installed_$OSNAME > $TMPFILE-installed
	wait_over
}

check_programs() {
# DEPENDENCIES:
# All: 			sh, awk, sed, grep, egrep, fgrep, tr, ls, expr, id, more, head, tput (optional), hostname, uname, tee
# Linux: 		rpm
# Solaris: 		pkgadd, pkginfo, pkgrm, nawk
# HPUX: 		swlist, swinstall, swremove
# AIX:			installp, lslpp
# UnixWare: 	pkgadd, pkginfo, pkgrm
# OpenServer:	pkgadd, pkginfo, pkgrm
	
	ERR=""
	PROGLIST="awk sed grep egrep fgrep tr ls expr id more head hostname uname tee"
	case `uname -s` in
		[lL]inux) 	
			PROGLIST="$PROGLIST rpm"
			;;
		SunOS) 		
			PROGLIST="$PROGLIST pkgadd pkginfo pkgrm nawk"
			;;
		SCO_SV) 	
			PROGLIST="$PROGLIST pkgadd pkginfo pkgrm"
			;;
		UnixWare) 	
			PROGLIST="$PROGLIST pkgadd pkginfo pkgrm"
			;;
		AIX) 		
			PROGLIST="$PROGLIST installp lslpp"
			;;
		HP-UX) 		
			PROGLIST="$PROGLIST swlist swinstall swremove"
			;;
		*)
			echo "$PROG: this OS is not supported: $OSNAME"
			exit 1
			;;
	esac

	for P in $PROGLIST; do
		if type $P >/dev/null 2>&1 ; then
			:
		else
			echo "$PROG: Can't find $P"
			ERR="yes"
		fi
	done

	if [ "$ERR" ]; then
		echo "PATH=$PATH" >&2
		exit 1
	fi
}

check_term() {

	if [ "$ENABLE_TPUT" ]; then
		# make sure tput is usable, otherwise disable:

		if tput init >/dev/null 2>&1 ; then
			:
		else
			I=`stty -a |sed -n -e 's/^.*intr *= *\([^;]*\);.*$/\1/p'`
			echo "This program needs to know what sort of terminal you are using, but the"
			echo "terminal identifier (TERM) is presently set to '$TERM' and this is unknown."
			echo
			echo "If you see garbage after this point, press your INTR key ($I)"
			echo "to exit this program and use the -p option next time."
			echo
			echo "Please type the correct value for TERM or press ENTER."
			print_normal "(eg. vt100, xterm): "
			read T
			if [ -n "$T" ]; then
				TERM=$T
				export TERM
			fi
			if tput init >/dev/null 2>&1 ; then
				tput_output sgr0
			else
				ENABLE_TPUT=""
			fi
		fi
	fi

	START_BOLD=""
	START_NORMAL=""
	START_REVERSE=""
	START_ITALIC=""
	START_BLINK=""
	START_ALARM=""
	export START_BOLD
	export START_NORMAL
	export START_REVERSE
	export START_ITALIC
	export START_BLINK
	export START_ALARM

	if [ "$ENABLE_TPUT" ]; then
		START_BOLD=${START_BOLD}`tput bold`
		START_BOLD=${START_BOLD}`tput setaf 3` # yellow
		START_BOLD=${START_BOLD}`tput setab 4` # blue
		START_NORMAL=${START_NORMAL}`tput setaf 7` # white
		START_NORMAL=${START_NORMAL}`tput setab 0` # black
		START_NORMAL=${START_NORMAL}`tput sgr0`
		START_REVERSE=`tput rev`
		START_ITALIC=`tput sitm`
		START_BLINK=`tput blink`
		START_ALARM=""
		START_ALARM=$START_ALARM`tput rev`
		START_ALARM=${START_ALARM}`tput setaf 3` # yellow
		START_ALARM=${START_ALARM}`tput setab 1` # red
		if [ -z "$SCREEN_HEIGHT" ]; then
			SCREEN_HEIGHT=`tput lines`
		fi
		if [ -z "$SCREEN_WIDTH" ]; then
			SCREEN_WIDTH=`tput cols`
		fi
	fi

	if [ -z "$SCREEN_HEIGHT" ]; then
		SCREEN_HEIGHT=$LINES
	fi
	if [ -z "$SCREEN_HEIGHT" ]; then
		SCREEN_HEIGHT=24
	fi
	if [ "$SCREEN_HEIGHT" -lt 10 ]; then
		SCREEN_HEIGHT=24
	fi

	if [ -z "$SCREEN_WIDTH" ]; then
		SCREEN_WIDTH=$COLS
	fi
	if [ -z "$SCREEN_WIDTH" ]; then
		SCREEN_WIDTH=80
	fi
	if [ "$SCREEN_WIDTH" -lt 65 ]; then
		SCREEN_WIDTH=80
	fi

	# echo screensize==${SCREEN_WIDTH}x$SCREEN_HEIGHT
	# don't write in the rightmost column in case it pushes the cursor down:
	MAX_SCREEN_WIDTH=`expr $SCREEN_WIDTH - 1`
}

check_install_basename() {
	if [ -d "$BASENAME/SafeNet" ]; then
		return
	fi
	return # only support installation in $BASENAME for the time being ...
	skip_lines 0
	while true; do
		print_normal "Where should SafeNet packages be installed? [$BASENAME]: "
		read B
		if [ -d "$B" ]; then
			BASENAME="$B"
			return
		fi
	done
}

os_dependancies() {
	LIBSUFFIX=so
	OSNAME=`uname -s`
	case $OSNAME in
		[lL]inux)
			MACHINE_OS=`uname -m`
			case $MACHINE_OS in 
				[xX]86_64)
					OSNAME="Linux64"
					;;
				[iI]386)
					;;
			esac
			;;
	esac
			
	OS_DIR=$OSNAME
	LINKTEST="-L"
	IDPROG="id"
	TR=tr
	AWK=awk
	FIRSTLINE="head -n 1"
	for ECHO in /usr/bin/echo /bin/echo nil; do
		if [ -x "$ECHO" ]; then
			break
		fi
	done
	if [ "$ECHO" = "nil" ]; then
		echo "$PROG: can't find an 'echo' program"
		exit 1
	fi

	if [ `$ECHO 'one line\c'|wc -l` -eq 0 ]; then
		ECHO_NO_CR=echo_no_cr_backslash
	else
		ECHO_NO_CR=echo_no_cr_n
	fi

	LIB64=""
	case $OSNAME in
		[lL]inux64)
			OSNAME=Linux64
			OS_DIR=Linux64
			ARCH=linux-x86_64
			INSTALL_PROGRAM=rpm
			UNINSTALL_PROGRAM=rpm
			POSSIBLE_INSTALL_OPTIONS="--nodeps --noscripts"
			POSSIBLE_UNINSTALL_OPTIONS="--nodeps --noscripts"
			;;
		[lL]inux)
   			OSNAME=Linux
   			OS_DIR=Linux
   			ARCH=linux-i386
   			INSTALL_PROGRAM=rpm
   			UNINSTALL_PROGRAM=rpm
   			POSSIBLE_INSTALL_OPTIONS="--nodeps --noscripts"
   			POSSIBLE_UNINSTALL_OPTIONS="--nodeps --noscripts"
   			;;
		SunOS) 		
			OSNAME=Solaris

			AWK=nawk
			IDPROG="/usr/xpg4/bin/id"
			OS_DIR=Solaris
			LIB64=sparcv9
			ARCH=`uname -p`

                        #For X86
                        if [ "$ARCH" != "sparc" ];then
                                echo "Installing for Solaris X86"
                                OS_DIR=SolarisX86
                                LIB64=amd64
                        fi

			INSTALL_PROGRAM=pkgadd
			UNINSTALL_PROGRAM=pkgrm
			POSSIBLE_INSTALL_OPTIONS=""
			POSSIBLE_UNINSTALL_OPTIONS=""
			LINKTEST="-h"
			;;
		SCO_SV) 	
			OSNAME=OpenServer
			OS_DIR=$OSNAME
			ARCH=openserver-i386
			INSTALL_PROGRAM=pkgadd
			UNINSTALL_PROGRAM=pkgrm
			POSSIBLE_INSTALL_OPTIONS=""
			POSSIBLE_UNINSTALL_OPTIONS=""
			;;
		UnixWare) 	
			OSNAME=UnixWare
			TR="tr -s"
			ARCH=unixware-i386
			INSTALL_PROGRAM=pkgadd
			UNINSTALL_PROGRAM=pkgrm
			POSSIBLE_INSTALL_OPTIONS=""
			POSSIBLE_UNINSTALL_OPTIONS=""
			;;
		AIX) 	
			OSNAME=AIX
			ARCH=aix-ppc
			LIBSUFFIX=a
			INSTALL_PROGRAM=installp
			UNINSTALL_PROGRAM=installp
			POSSIBLE_INSTALL_OPTIONS=""
			POSSIBLE_UNINSTALL_OPTIONS=""
			must_be_root # otherwise installp can't even list packages!
			LIB64=aix-ppc64
			LEGACY=legacy
			LEGACY_LIBSUFFIX=so
			;;
		HP-UX) 		
			OSNAME=HPUX
			OS_DIR=HP-UX
			case `uname -m` in
				ia64) 
				ARCH=hpux-ia64
				LIBSUFFIX=so
				;;
				*)    
				ARCH=hpux-pa
				LIBSUFFIX=sl
				;;
			esac
			INSTALL_PROGRAM=swinstall
			UNINSTALL_PROGRAM=swremove
			POSSIBLE_INSTALL_OPTIONS=""
			POSSIBLE_UNINSTALL_OPTIONS=""
			must_be_root # otherwise swlist command hangs
			LINKTEST="-h"
			LIB64=64
			;;
		*)
			echo "$PROG: this OS is not supported: $OSNAME"
			exit 1
			;;
	esac
}

# usage: inPath new_directory LD_LIBRARY_PATH
inPath() {
	RETVAL=1
    CANDIDATE="$1"
	AGGREGATE=`echo $2|sed 's/:/ /g'`
    for P in "$AGGREGATE"; do
        if [ "$P" = "$CANDIDATE" ]; then
			RETVAL=0
			break
		fi
    done
    return $RETVAL
}

set_path() {
	for C in /usr /usr/bin /sbin /usr/sbin; do
		if inPath $C $PATH; then
			:
		else
			PATH=$PATH:$C
		fi
	done
}

cleanup_tmp() {
	[ "$TMPFILE" ] && rm -f $TMPFILE $TMPFILE-installed $TMPFILE-cd-guess $TMPFILE-cd $TMPFILE-hsm
}

initialise_globals() {

	export LIBSUFFIX
	export OSNAME
	export LINKTEST
	export IDPROG
	export TR
	export AWK
	export ECHO_NO_CR
	export ARCH
	export LIB64
	export LEGACY
	export LEGACY_LIBSUFIX
	export INSTALL_PROGRAM
	export UNINSTALL_PROGRAM
	export POSSIBLE_INSTALL_OPTIONS
	export POSSIBLE_UNINSTALL_OPTIONS
	export EXTRA_OPTIONS
	export SCREEN_HEIGHT
	export SCREEN_WIDTH
	export MAX_SCREEN_WIDTH
	export TERM
	export LEGAL
	export TMPFILE
	export POSTINSTALL

	REPAINT="Redraw"
	export REPAINT
	if [ -z "$PAGER" ]; then
		PAGER=more
	fi
	export PAGER

	TMPFILE=/tmp/install.sh.$$
	EXEC="eval"
	export EXEC
	if [ -z "$BASENAME" ]; then
		BASENAME="/opt"
	fi

	export ENABLE_TPUT

	DISPLAY="" # just in case ...
	export DISPLAY

	# Note: if sh(1) had the facility, LEGAL_CRYPTOKIS and CRYPTOKI_LABELS
	# would be asociative arrays. As it is, they have to be manually
	# defined as parallel lists - make sure they stay in sync!

	LEGAL_CRYPTOKIS="$BASENAME/ERACcp8k/lib/$ARCH/libctc8k.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcprc/lib/$ARCH/libctclient.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcpsw/lib/$ARCH/libctsw.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcprov/lib/$ARCH/libctcsa.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcpsdk/lib/$ARCH/libctc8k.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcpsdk/lib/$ARCH/libctclient.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcpsdk/lib/$ARCH/libctsw.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ERACcpsdk/lib/$ARCH/libctcsa.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ETcprt/lib/$ARCH/libcthsm.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ETcpsdk/lib/$ARCH/libctsw.$LIBSUFFIX"
	LEGAL_CRYPTOKIS="$LEGAL_CRYPTOKIS $BASENAME/ETcpsdk/lib/$ARCH/libcthsm.$LIBSUFFIX"
	export LEGAL_CRYPTOKIS

	CRYPTOKI_LABELS="ERACcp8k ERACcprc ERACcpsw ERACcprov ERACcp8k-sdk ERACcprc-sdk ERACcpsw-sdk ERACcprov-sdk ETcprt ETcpsw-sdk ETcprt-sdk"
	export CRYPTOKI_LABELS
	
	# simple check on that array (sigh):
	if [ `echo "$LEGAL_CRYPTOKIS" |wc -w` -ne `echo "$CRYPTOKI_LABELS" |wc -w` ]; then
		echo "Internal BUG in CRYPTOKI_LABELS"
		exit 1
	fi
	DEFAULT_CRYPTOKI_LINK="$BASENAME/PTK/lib/libcryptoki.$LIBSUFFIX"
	export DEFAULT_CRYPTOKI_LINK

	if [ "$LIB64" ]; then
		DEFAULT_CRYPTOKI_LINK64="$BASENAME/PTK/lib/$LIB64/libcryptoki.$LIBSUFFIX"
		export DEFAULT_CRYPTOKI_LINK64
	fi

	if [ "$LEGACY" ]; then
		DEFAULT_CRYPTOKI_LINK_LEGACY="$BASENAME/PTK/lib/$LEGACY/libcryptoki.$LEGACY_LIBSUFFIX"
		export DEFAULT_CRYPTOKI_LINK_LEGACY
	fi
		
	# Similarly, LEGAL_HSM_LINKS and HSM_LINK_LABELS should be
	# associative arrays but need to be kept syncronised manually:
	LEGAL_HSM_LINKS="$BASENAME/ETlhsm/lib/$ARCH/libetpso.$LIBSUFFIX"
	LEGAL_HSM_LINKS="$LEGAL_HSM_LINKS $BASENAME/ETpcihsm/lib/$ARCH/libetpso.$LIBSUFFIX"
	LEGAL_HSM_LINKS="$LEGAL_HSM_LINKS $BASENAME/ETpcihsm/lib/$ARCH/libetpcihsm.$LIBSUFFIX"
	LEGAL_HSM_LINKS="$LEGAL_HSM_LINKS $BASENAME/ETrhsm/lib/$ARCH/libetnetclient.$LIBSUFFIX"
	LEGAL_HSM_LINKS="$LEGAL_HSM_LINKS $BASENAME/ETnethsm/lib/$ARCH/libetnetclient.$LIBSUFFIX"
	export LEGAL_HSM_LINKS

	HSM_LINK_LABELS="ETlhsm ETpcihsm ETpcihsm ETrhsm ETnethsm"
	export HSM_LINK_LABELS
	
	# simple check on that array (sigh):
	if [ `echo "$LEGAL_HSM_LINKS" |wc -w` -ne `echo "$HSM_LINK_LABELS" |wc -w` ]; then
		echo "Internal BUG in HSM_LINK_LABELS"
		exit 1
	fi

	DEFAULT_HSM_LINK="$BASENAME/PTK/lib/libethsm.$LIBSUFFIX"
	export DEFAULT_HSM_LINK

	if [ "$LIB64" ]; then
		DEFAULT_HSM_LINK64="$BASENAME/PTK/lib/$LIB64/libethsm.$LIBSUFFIX"
		export DEFAULT_HSM_LINK64
	fi

	if [ "$LEGACY" ]; then
		DEFAULT_HSM_LINK_LEGACY="$BASENAME/PTK/lib/$LEGACY/libethsm.$LEGACY_LIBSUFFIX"
		export DEFAULT_HSM_LINK_LEGACY
	fi

	HAVE_PACKAGES=""
	export HAVE_PACKAGES
}

process_options() {
	PROGNAME="$0"
	PROG=`basename $0`
	PROG_DIR=`dirname $0`
	PROG_DIR=`fqn $PROG_DIR`
	CVS_VERSION='$Revision: 28 $'
	PROG_VERSION=`echo "$CVS_VERSION" | sed -e 's/^\$*Revision: \([0-9][0-9.]*\) \$$/\1/'`
	SCREEN_HEIGHT=""
	SCREEN_WIDTH=""
	ENABLE_TPUT="yes"
	BASENAME=""

	ARGS=`getopt hptVs: $@`
	STAT=$?
	if [ "$STAT" -ne 0 ]; then
		echo "$PROG: use -h for usage" >&2
		exit $STAT
	fi
	set -- $ARGS
	for I in $@; do
		case $I in
			-h) usage; exit 0; shift ;;
			-p) ENABLE_TPUT=""; shift;;
			-t) EXEC=test_mode;; # for testing
			-s) SCREEN_PARAM=$2; shift 2;;
			-V) echo $PROG_VERSION; exit 0;;
			--) shift; break;;
		esac
	done

	if [ "$EXEC" != "eval" ]; then
		TITLE="$TITLE - test mode"
	fi

	if [ -n "SCREEN_PARAM" ]; then
		SAVE_IFS=$IFS
		IFS=x
		set -- $SCREEN_PARAM
		IFS=$SAVE_IFS
		SCREEN_HEIGHT=$1
		SCREEN_WIDTH=$2
	fi
}

usage() {
	echo "Usage: $PROG [-hp] [-s size]"
	echo "SafeNet install and uninstall program for Unix supporting:"
	echo "$KNOWN_OS_DIRS"
	echo
	echo "You need to be 'root' to be able to install and uninstall packages."
	echo
	echo "Options:"
	echo "  -h       show this help"
	echo "  -p       plain mode (don't use 'tput' for video enhancements)"
	echo "  -s size  override the screensize (default = 'tput lines/cols' or 24x80)"
	echo "  -V       print the version of this script"
	echo
	echo "If TERM is not set correctly then this program's screens may be confused."
	echo "In this case you can use the -p and/or -s options."
	echo
	echo "If your 'backspace' key does not work properly then, before running this"
	echo "program, use:"
	echo "	stty erase <backspace><enter>"
	echo "... where '<backspace>' is the key you want to use."
	echo
	#echo "Support is available at support@eracom-tech.com"
}

############
# Main:

process_options $@
SIGEXIT=0
SIGHUP=1
SIGINTR=2
SIGQUIT=3
SIGTERM=15
trap "cleanup_tmp; exit 0" $SIGEXIT $SIGHUP $SIGINTR $SIGQUIT $SIGTERM

set_path
os_dependancies
initialise_globals

IS_ROOT=""
if [ `$IDPROG -u` -eq 0 ]; then
	IS_ROOT="yes"
fi

check_programs
check_term
check_install_basename

# We now know enough to be able to start outputing:
skip_lines 0

TITLE="SafeNet Unix Installation Utility (version $PROG_VERSION):"
SUBTITLE="Hostname: `hostname` ($OSNAME `uname -r`)"

echo "IMPORTANT:  The terms and conditions of use outlined in the software"
echo "license agreement (Document #008-010005-001_053110) shipped with the product"
echo "(\"License\") constitute a legal agreement between you and SafeNet Inc."
echo "Please read the License contained in the packaging of this"
echo "product in its entirety before installing this product."
echo ""
echo "Do you agree to the License contained in the product packaging? "
echo ""
echo "If you select 'yes' or 'y' you agree to be bound by all the terms"
echo "and conditions set out in the License."
echo ""
echo "If you select 'no' or 'n', this product will not be installed."
echo ""
echo "(y/n) "

read LICENSE
if [ $LICENSE = 'y' ]  || [ $LICENSE = "yes" ]; then
    echo ""
else
    echo "You must agree to the license agreement before installing this software."
    echo "The install will now exit."
    exit 1
fi

print_bold "$TITLE"
echo
echo "$SUBTITLE"
echo
echo "Base for installation is $BASENAME"
echo

check_packages

please_wait "Checking links"
if [ "$IS_ROOT" ]; then
	check_links
fi
wait_over

main_menu
