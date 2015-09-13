echo "under testing mode, generate parse tree from input"
if [ $# -eq 1 ]; then
  echo $1 | java org.antlr.v4.runtime.misc.TestRig ScimQueryFilter criterias -tree
fi
