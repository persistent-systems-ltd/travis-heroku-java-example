APP_FILE=$1
APP_NAME=$2

HK_SOURCES=$(curl -ns -X POST https://api.heroku.com/apps/${APP_NAME}/sources -H 'Accept: application/vnd.heroku+json; version=3')
HK_GET_URL=$(expr "$HK_SOURCES" : ".*\"get_url\":\"\(https://.*\)\",")
HK_PUT_URL=$(expr "$HK_SOURCES" : ".*\"put_url\":\"\(https://.*\)\"")

echo "---> Uploading application package..."
curl "$HK_PUT_URL" -X PUT -H 'Content-Type:' -d @${APP_FILE}

SOURCE_BLOB_URL="{
  \"source_blob\": {
    \"url\": \"${HK_GET_URL}\",
    \"version\": \"v1.0.0\"
  }
}"

echo "---> Creating new release..."
curl -n -X POST https://api.heroku.com/apps/${APP_NAME}/builds \
-H "Accept: application/vnd.heroku+json; version=3" \
-H "Content-Type: application/json" \
-d "$SOURCE_BLOB_URL"
