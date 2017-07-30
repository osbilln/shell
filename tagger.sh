#!/bin/bash -x

function usage() {
  echo "tagger v0.1"
  echo ""
  echo "tagger.sh OPTIONS TAG_NAME"
  echo ""
  echo "Valid options:"
  echo "     -b --branch        Branch Name (Default: trunk)"
  echo "     -r --revision      SVN Revision Number to tag (Default: HEAD)"
  echo "     -m --baserevision  SVN Revision Number to start log from (Default: none, no Jira updates performed)"
  echo "     -s --svnroot       SVN Repository home (Default: svn+ssh://svn.naehas.com/home/svn/repository)"
  echo "     -u --uselast       Use the last run SVN revision number as the baserevision"
  echo "     -d --debug         Display commands which would be run, but don't make any changes"
  echo "     -h --help          Display this help."
  exit 0
}

while getopts ":duhb:r:m:s:-:" opt; do
 case $opt in
  -)
     case "${OPTARG}" in
       branch)
         BRANCH_NAME="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       revision)
         MAX_REVISION="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       baserevision)
         BASE_REVISION="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       svnroot)
         SVN_ROOT="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       uselast)
         USELAST=1
         ;;
       debug)
         DEBUG="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
         ;;
       help)
         usage
         ;;
       *)
         echo "Unknown parameter: $OPTARG" >&2 && exit 1;
         ;;
     esac
     ;;
  b) BRANCH_NAME=$OPTARG
     ;;
  r) MAX_REVISION=$OPTARG
     ;;
  m) BASE_REVISION=$OPTARG
     ;;
  s) SVN_ROOT=$OPTARG
     ;;
  u) USELAST=1
     ;;
  d) DEBUG=1
     ;;
  h) usage
     ;;
 esac
done

TAG_NAME=${!OPTIND}

if [[ $BRANCH_NAME = '' ]]; then BRANCH_NAME='trunk'; fi
#if [[ $BRANCH_NAME != 'trunk' ]]; then BRANCH_NAME="branches/$BRANCH_NAME"; fi

if [[ $MAX_REVISION = '' ]]; then MAX_REVISION='HEAD'; fi

if [[ $BASE_REVISION = '' && USELAST != '1' ]]; then echo "No BASE_REVISION set, no jira updates to perform"; fi

if [[ $TAG_NAME = '' ]]; then echo "TAG_NAME is required" && exit 1; fi

if [[ $SVN_ROOT = '' ]]; then SVN_ROOT='svn+ssh://svn.naehas.com/home/svn/repository'; fi

if [[ $DEBUG = '' ]]; then DEBUG=0; fi

if [[ $USELAST = '1' ]]; then
  if [[ $BASE_REVISION != '' ]]; then
    echo "Cannot use last revision if baserevision is set.  Using baserevision."
  else
    BASE_REVISION=`grep -E "$BRANCH_NAME." last_run.txt | grep -o -E "[[:digit:]]+"`
    if [[ $BASE_REVISION != '' ]]; then
      let BASE_REVISION+=1
    fi
  fi
fi

echo "Creating tag $TAG_NAME from $BRANCH_NAME revision $MAX_REVISION with logs since $BASE_REVISION (Debug: $DEBUG Use Last: $USELAST)"

# grab the current revision
# TODO: make this be a parameter if desired
if [[ $MAX_REVISION = 'HEAD' ]]; then CURRENT_REVISION=`svn info $SVN_ROOT/base-dashboard/$BRANCH_NAME/ |grep "Last Changed Rev" | grep -E '[[:digit:]]+' -o`; else CURRENT_REVISION=$MAX_REVISION; fi

echo "Set CURRENT_REVISION to $CURRENT_REVISION"

if [[ $CURRENT_REVISION -lt $BASE_REVISION ]]; then echo "Current Revision ($CURRENT_REVISION) must be greater than Base Revision ($BASE_REVISION)" && exit 1; fi

# base-dashboard must be last!
PROJECTS="core campaign-server base-dashboard"

for PROJECT in $PROJECTS ; do
  printf "Checking %-50s  " $PROJECT/$SOURCE
  svn info $SVN_ROOT/$PROJECT/$BRANCH_NAME &>/dev/null
  if [ $? != 0 ] ; then
    printf "%10s\n" "Missing"
    PROBLEMS=yes
  else
    svn info $SVN_ROOT/$PROJECT/tags/$TAG_NAME &>/dev/null
    if [ $? != 0 ] ; then
      printf "%10s\n" "Good"
    else
      printf "%10s\n" "Tag Exists"
      PROBLEMS=yes
    fi
  fi
done

if [ "$PROBLEMS" = "yes" ] ; then
  exit 2
fi

if [[ $BASE_REVISION != '' ]]; then

for PROJECT in $PROJECTS ; do
  REV=`svn log $SVN_ROOT/$PROJECT/$BRANCH_NAME/ -r $BASE_REVISION:$CURRENT_REVISION -v >> svn.log.$TAG_NAME`
  if [ $? != 0 ] ; then
    echo Error getting log for $PROJECT!
    PROBLEMS=yes
  fi
done

if [ "$PROBLEMS" = "yes" ] ; then
  exit 3
fi

# grab all FRED issue numbers
grep -E 'FRED-[[:digit:]]+' -o svn.log.$TAG_NAME |sort -u > issue_list.$TAG_NAME.txt
paste -s -d, issue_list.$TAG_NAME.txt > issue_list.$TAG_NAME.csv;

fi

# make the new tags

for PROJECT in $PROJECTS ; do
  CMD="svn copy -m "$BUILD_TAG" -r $CURRENT_REVISION $SVN_ROOT/$PROJECT/$BRANCH_NAME $SVN_ROOT/$PROJECT/tags/$TAG_NAME"
  if [[ $DEBUG = '1' ]]; then CMD="echo $CMD"; fi
  #echo $CMD
  $CMD
  if [ $? != 0 ] ; then
    echo Error creating tag for $PROJECT!
    PROBLEM=yes
  fi
done

if [ "$PROBLEMS" = "yes" ] ; then
  exit 4
fi

# save this revision number
echo `date`:$BRANCH_NAME.$BASE_REVISION.$CURRENT_REVISION >> history.txt

# keep track of last run
if [[ -f last_run.txt && $DEBUG = '0' ]]; then
  echo "Updating last_run.txt"
  sed -i "s/$BRANCH_NAME.[0-9]*/$BRANCH_NAME.$CURRENT_REVISION/" last_run.txt;
else
  echo "Creating last_run.txt"
  echo $BRANCH_NAME.$CURRENT_REVISION >> last_run.txt;
fi


#create build tag in jira
# not available in current rest api

#loop through issues and add fixVersion
if [[ $BASE_REVISION != '' ]]; then
  LIST=`cat issue_list.$TAG_NAME.txt`
  for issue in $LIST;
  do
    if [[ $DEBUG != '1' ]]; then
      curl -f -u tagger:j1r@n@#h@s123 -H 'Content-Type: application/json' -X PUT --data "{\"update\":{\"fixVersions\":[{\"add\":{\"name\":\"$TAG_NAME\"}}]}}" https://jira.naehas.com/rest/api/2/issue/$issue ;
    else
      echo curl -f -u tagger:j1r@n@#h@s123 -H 'Content-Type: application/json' -X PUT --data "{\"update\":{\"fixVersions\":[{\"add\":{\"name\":\"$TAG_NAME\"}}]}}" https://jira.naehas.com/rest/api/2/issue/$issue ;
    fi
  done;
fi
