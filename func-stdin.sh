func-stdin.sh
# Instead of:
Function ()
{
 ...
 } < file

# Try this:
Function ()
{
  {
    ...
   } < file
}

# Similarly,

Function ()  # This works.
{
  {
   echo $*
  } | tr a b
}

Function ()  # This doesn't work.
{
  echo $*
} | tr a b   # A nested code block is mandatory here.


return_val
t

# Thanks, S.C.