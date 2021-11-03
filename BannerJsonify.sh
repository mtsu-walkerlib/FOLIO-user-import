#!/bin/bash

dos2unix files/patronexport.txt

##remove top column
echo "$(tail -n +2 files/patronexport.txt)" > files/patronexport.txt
##use split command to break up files
split -l 50 files/patronexport.txt files/user
mv files/patronexport.txt /home/rwilson/folio_scripting
#after split add column to each file
sed -i '1s/^/username|externalSystemId|barcode|patronGroup|lastName|firstName|email|phone|mobilePhone|addressLine1|addressLine2|city|postalCode|region|expirationDate\n/' files/* 

dos2unix files/*
#you'll need this to strip all single qoute so jq can handle it. 
#sed -i "s='==g" files/*

#Add a Loop here that creates a var for filename, creates var for line count of each file -1, and does the jq and remaining sed commands until all files have been touched in files dir. 

files="files/*"
for f in $files
do
   echo "Processing $f file. . ."
   filename=$f
   usercount=`wc -l $filename`
   usercount1=${usercount:0:3}
   usercount2=$((usercount1-1))
   jsonfile=$f.json
   echo "Creating $jsonfile. . ."

#####will need to add to column above and to below and to the Null fix below "preferredFirstName": field

#jq for setting up structure. for addresses just further nest...
#for split you can use |  
   jq --slurp --raw-input --raw-output \
    'split("\n") | .[1:] | map(split("|")) |
        map({"username": .[0],
            "externalSystemId": .[1],
            "barcode": .[2],
	    "active": true,
            "patronGroup": .[3],
	    "personal":{
            	"lastName": .[4],
	    	"firstName": .[5],
	    	"email": .[6],
                "phone": .[7],
                "mobilePhone": .[8],
 		"addresses":[{
		  "addressLine1": .[9],
                  "addressLine2": .[10],
                  "city": .[11],
                  "postalCode": .[12],
                  "region": .[13],
                  "addressTypeId":"Main",
                  "primaryAddress":true}],	
	    "preferredContactTypeId": "email"},	
            "expirationDate": .[14]})' \
    $f > $jsonfile
#add to beginning of each jsonified file
#
   sed -i '1s/^/{\n"users" : \n/' "$jsonfile"
#add to end of each
   sed -i '$a,\n\"totalRecords" : usercount2,\n\"deactivateMissingUsers\" : false,\n\"updateOnlyPresentFields\" : false\n}' "$jsonfile"
   sed -i "s/usercount2/$usercount2/g" "$jsonfile"   
done
