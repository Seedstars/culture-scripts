#!/usr/bin/env bash

# You can test this by running `deploy/notify_slack.sh pass 111 my_branch http://my-build-url.com`
# If it fails with permission denied, make sure you run `chmod u+x notify_slack.sh` first.

STATUS=$1
GROUP=$2
PROJECT=$3
PIPELINE_ID=$4
BRANCH=$5
URL=$6
SLACK_URL=$7 # This should be a long URL like https://hooks.slack.com/services/AAAAA/BBBB/CCCC.

if [ "$STATUS" = "pass" ]; then
   curl -X POST --data-urlencode 'payload={"username": "happyshippy", "text": "PASSING '"$GROUP"'/'"$PROJECT"'/'"$BRANCH"' (Pipeline '"$PIPELINE_ID"'). --> '"$URL"'/pipelines/'"$PIPELINE_ID"'", "icon_emoji": ":sunglasses:"}' $SLACK_URL
else
   curl -X POST --data-urlencode 'payload={"username": "sadshippy", "text": "FAILING '"$GROUP"'/'"$PROJECT"'/'"$BRANCH"' (Pipeline '"$PIPELINE_ID"'). --> '"$URL"'/pipelines/'"$PIPELINE_ID"'", "icon_emoji": ":scream:"}' $SLACK_URL
fi
