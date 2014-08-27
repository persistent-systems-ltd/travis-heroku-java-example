APP_FILE=$1
APP_NAME=$2

HK_TOKEN=`(echo -n ":" ; echo "${HEROKU_API_TOKEN}") | base64`

HK_SOURCES=$(curl -s -X POST https://api.heroku.com/apps/${APP_NAME}/sources -H "Authorization: ${HK_TOKEN}" -H 'Accept: application/vnd.heroku+json; version=3')
HK_GET_URL=$(expr "$HK_SOURCES" : ".*\"get_url\":\"\(https://.*\)\",")
HK_PUT_URL=$(expr "$HK_SOURCES" : ".*\"put_url\":\"\(https://.*\)\"")

echo "---> Uploading application package..."
curl "$HK_PUT_URL" -X PUT -H 'Content-Type:' --data-binary @${APP_FILE}

echo "---> Creating new release..."
curl -X POST https://api.heroku.com/apps/${APP_NAME}/builds \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Authorization: ${HK_TOKEN}" \
-H "Content-Type: application/json" \
-d "{ \"source_blob\": {
  \"url\": \"${HK_GET_URL}\",
  \"version\": \"v1.0.1\"
}}"
