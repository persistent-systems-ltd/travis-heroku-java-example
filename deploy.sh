APP_NAME="rocky-ocean-6373"
APP_FILE="${APP_NAME}.tar.gz"

echo "---> Creating the release package..."
tar cvf ${APP_FILE} target/dependency target/*.war Procfile

# create the Auth token
HK_TOKEN=`(echo -n ":" ; echo "${1:-$HEROKU_API_TOKEN}") | base64`

# retrieve the URLs for putting and getting the archive
HK_SOURCES=$(curl -s -X POST https://api.heroku.com/apps/${APP_NAME}/sources -H 'Accept: application/vnd.heroku+json; version=3' -H "Authorization: ${HK_TOKEN}")
HK_GET_URL=$(expr "$HK_SOURCES" : ".*\"get_url\":\"\(https://.*\)\",")
HK_PUT_URL=$(expr "$HK_SOURCES" : ".*\"put_url\":\"\(https://.*\)\"")

echo "TOK: $HK_TOKEN"
echo "SRC: $HK_SOURCES"
echo "GET: $HK_GET_URL"
echo "PUT: $HK_GET_URL"

echo "---> Uploading release package..."
curl "$HK_PUT_URL" -X PUT -H 'Content-Type:' --data-binary @${APP_FILE}

echo "---> Creating new release..."
curl -X POST https://api.heroku.com/apps/${APP_NAME}/builds \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: ${HK_TOKEN}" \
-H "Content-Type: application/json" \
-d "{ \"source_blob\": {
  \"url\": \"${HK_GET_URL}\",
  \"version\": \"v1.0.0\"
}}"
