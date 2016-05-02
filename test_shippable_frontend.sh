#!/usr/bin/env bash

set -e

# javascript static analysis
./node_modules/.bin/eslint -c .eslintrc -f junit src/static tests/js > shippable/testresults/eslint.xml

# scss static analysis
./node_modules/.bin/sass-lint -f junit --verbose --no-exit > shippable/testresults/sasslint.xml

# javascript tests
./node_modules/.bin/istanbul cover --report cobertura --dir shippable/codecoverage node_modules/mocha/bin/_mocha -- --require tests/require --recursive --compilers js:babel-core/register --reporter mocha-junit-reporter --reporter-options mochaFile=shippable/testresults/mocha.xml tests/js/
