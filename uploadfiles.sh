#!/bin/bash

FILES=$1

curl -X PUT -T $FILES \
  -H "X-Storage-Token: 70b2287e-dfc4-4b8a-a9a1-cfed84fdebf4" \
   https://storage101.ord1.clouddrive.com/v1/MossoCloudFS_f5c6e9de-8f1a-4860-a806-b20f307e6bfe/user_uploads_bill/$FILES
   
