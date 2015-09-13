#!/bin/bash
#
#
# SEID=/users/billnguyen/Documents/workspace/Sequent-CouchDB/utils/secureElementData.json
#
curl -X POST https://ourdata:33whUybbOXPf@ourdata.cloudant.com/cms/_bulk_docs -H "Content-Type:application/json" -d @/Users/billnguyen/Documents/workspace/Sequent-CouchDB/utils/secureElementData.json 
