#!/usr/bin/env bash

set -e

# run bandit - A security linter from OpenStack Security
bandit -r src

# python static analysis
prospector --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# python tests
py.test -c pytest_ci.ini --cov=src
