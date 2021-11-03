### If a user doesn't update, the rest of the batch still will.  
### 
### Users also won't update if the combination of unique ID points changes. In other words,
### you're not overlaying on a single field but rather the combo. So if the username or 
### external ID changes, that user won't overlay
###
### Number of users is a required parameter, recommended to send in batches of 1000 or fewer

okapi_url="https://okapi-YOURSITE.folio.ebsco.com"
tenant="yourtenant"
username="youruser"
pwd='yourpw'

### these must correspond to what's in FOLIO
mainAddrType="Main"
otherAddrType="Home"

### first get an authentication token -- you can use the same one for as many 
### calls as you want
IFS='' read -r -d '' okapi_login << EndOfAuth
{
  "tenant": "${tenant}",
  "username": "${username}",
  "password": "${pwd}"
}
EndOfAuth

auth=$(curl -s -w '\n' -X POST -D - \
  -H "Content-type: application/json" \
  -H "X-Okapi-Tenant: ${tenant}" \
  -d "${okapi_login}" \
  "${okapi_url}/authn/login")

okapi_token=$(echo "${auth}" | grep 'x-okapi-token: ' |sed 's/^.* //')

files="files/*json"
for f in $files
do
   echo "Processing $f file. . ."
   jsonfile=`cat $f`

### just stick your data into a structure. If you have custom fields
### to pass through, this will need to be modified

IFS='' read -r -d '' users << EndOfUsers
$jsonfile
EndOfUsers

apicall=$(curl --http1.0 -s -w '\n' -X POST -H "Content-type: application/json" -H "X-Okapi-Tenant: ${tenant}" -H "x-okapi-token: ${okapi_token}" -d "${users}" "${okapi_url}/user-import")

echo "${apicall}"

done
