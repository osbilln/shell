echo "under testing mode, create GUI presentation of the parser tree"

if [ $# -eq 1 ]; then
  echo $1 | java org.antlr.v4.runtime.misc.TestRig ScimQueryFilter criterias -gui
fi
