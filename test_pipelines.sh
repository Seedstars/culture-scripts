#!/usr/bin/env bash

BackendTests () {
    py.test -n 8 --nomigrations --reuse-db tests
}

FrontendTests () {
    ./node_modules/.bin/istanbul cover --report cobertura --dir shippable/codecoverage node_modules/mocha/bin/_mocha -- --require tests/require --recursive --compilers js:babel-core/register --reporter mocha-junit-reporter tests/js/
}

BackendStaticValidation () {
    prospector  --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

    # bandit - A security linter from OpenStack Security
    bandit -r src
}

FrontendStaticValidation () {
    ./node_modules/.bin/eslint -c .eslintrc -f junit src/static tests/js

    ./node_modules/.bin/sass-lint -f junit --verbose --no-exit
}

NotifySlack () {
    ./scripts/notify_slack.sh $1 $BITBUCKET_REPO_SLUG $BITBUCKET_COMMIT $BITBUCKET_BRANCH https://bitbucket.org/seedstarsdev/$BITBUCKET_REPO_SLUG/addon/pipelines/home https://hooks.slack.com/services/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

    if [ "$1" = "pass" ]; then
        exit 0
    else
        exit 1
    fi
}

set +e

BackendTests; EXIT_STATUS=$?
if [ "$EXIT_STATUS" -ne "0" ]; then NotifySlack fail; fi
FrontendTests; EXIT_STATUS=$?
if [ "$EXIT_STATUS" -ne "0" ]; then NotifySlack fail; fi
BackendStaticValidation; EXIT_STATUS=$?
if [ "$EXIT_STATUS" -ne "0" ]; then NotifySlack fail; fi
FrontendStaticValidation; EXIT_STATUS=$?
if [ "$EXIT_STATUS" -ne "0" ]; then NotifySlack fail; fi

if [ "$EXIT_STATUS" -eq "0" ]; then NotifySlack pass; fi
