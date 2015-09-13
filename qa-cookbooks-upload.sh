

for i in `cat qa-cookbooks`
 do
  echo $i
   knife cookbook upload $i
done 
  
