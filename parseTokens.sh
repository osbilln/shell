echo "under testing mode, parse tokens from input"

if [ $# -eq 1 ]; then
  echo $1 | java org.antlr.v4.runtime.misc.TestRig ScimQueryFilter criterias -tokens
fi
