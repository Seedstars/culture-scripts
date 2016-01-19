#!/usr/bin/env bash

# You can test this by running `deploy/notify_slack.sh pass 111 my_branch http://my-build-url.com`
# If it fails with permission denied, make sure you run `chmod u+x notify_slack.sh` first.

STATUS=$1
PROJECT=$2
BUILD_NUMBER=$3
BRANCH=$4
URL=$5
SLACK_URL=$6 # This should be a long URL like https://hooks.slack.com/services/AAAAA/BBBB/CCCC.


if [ "$STATUS" = "pass" ]; then
   curl -X POST --data-urlencode 'payload={"username": "happyshippy", "text": "PASSING '"$PROJECT"'/'"$BRANCH"' (Build '"$BUILD_NUMBER"'). --> '"$URL"'", "icon_emoji": ":sunglasses:"}' $SLACK_URL
else
   curl -X POST --data-urlencode 'payload={"username": "sadshippy", "text": "FAILING '"$PROJECT"'/'"$BRANCH"' (Build '"$BUILD_NUMBER"'). --> '"$URL"'", "icon_emoji": ":scream:"}' $SLACK_URL
fi
