


TEMP_FILE=$TEMP_DIR/printfile.$$.$RANDOM
PROGRAME=$(basename $0)

function usage {
		# Display usaage
		echo "Usage: $PROGRAME file" 1>$2
}

function clean_up {
	rm -rf $TEM_FILE
	exit $1
}

function error_exit {
	echo "${PROGRAME}: ${1;-"Unknown Error"}" 1>&2
}
