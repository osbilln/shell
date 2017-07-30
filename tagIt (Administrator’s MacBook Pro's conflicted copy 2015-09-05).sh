#!/bin/sh

function usage() {
  echo tagIt.sh SOURCE TAGNAME
  echo Creates tags based off a branch or tag.
  echo Use branches/MyBranch or tags/MyTag to reference a source.
}

function askContinueQuestion() {
  read -p "Continue [Y/n]? " CONT
  if [ "$CONT" != "y" -a "x$CONT" != "x" -a "$CONT" != "Y" ] ; then
    echo User requested quit
    exit 3
  fi
}

SOURCE=$1
TAGNAME=$2

if [ "x$SOURCE" = "x" ] ; then
  echo Source is necessary.
  usage
  exit 1
fi

if [ "x$TAGNAME" = "x" ] ; then
  echo Tagname is necessary.
  usage
  exit 1
fi

echo
echo "Creating tag, $TAGNAME, from source, $SOURCE."
echo
askContinueQuestion

SVN_ROOT=svn+ssh://svn.naehas.com/home/svn/repository

# base-dashboard must be last!
PROJECTS="core campaign-server workflow base-dashboard"

echo "SVN is $SVN_ROOT"
for PROJECT in $PROJECTS ; do 
  printf "Checking %-50s  " $PROJECT/$SOURCE
  svn info $SVN_ROOT/$PROJECT/$SOURCE &>/dev/null
  if [ $? != 0 ] ; then
    printf "%10s\n" "Missing"
    PROBLEMS=yes
  else
    svn info $SVN_ROOT/$PROJECT/tags/$TAGNAME &>/dev/null
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

echo Continuing


for PROJECT in $PROJECTS ; do 
  printf "[%20s] => " $PROJECT
  REV=`svn copy -m "Tagging $PROJECT from ${SOURCE}." \
           $SVN_ROOT/$PROJECT/$SOURCE \
           $SVN_ROOT/$PROJECT/tags/$TAGNAME 2> /dev/null | \
           grep Committed\ revision`
  if [ $? = 0 ] ; then
    REVNUM=`echo $REV | sed -e 's/[^0-9]//g' `
    echo Committed $REVNUM
  else
    echo Error creating tag!
    PROBLEM=yes
  fi
done

echo "Create Module Revision(s) with ${REVNUM}? "
askContinueQuestion

for DBHOST in devim im ; do
  echo
  echo Creating MODULE REVISION on $DBHOST?
  askContinueQuestion
  mysql -h $DBHOST -A nadb <<EOF
set @tag := "${TAGNAME}";
set @name := @tag;
set @rev := "${REVNUM}";
select @ilp := max(id) from N_MODULE_REVISIONS where source = 'base-ilp';
insert into N_MODULE_REVISIONS(API_VERSION, TYPE, TAG, DEPLOY_MODULE_REVISION_ID, SOURCE, 
                               NAME, REVISION_NUMBER, CREATED_DATE, LAST_MODIFIED_DATE) 
                       values (1, 1, @tag, @ilp, 'base-dashboard', 
                               @name, @rev, now(), now());
select * from N_MODULE_REVISIONS where id = last_insert_id() \G
EOF
  echo

done
