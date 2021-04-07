#!/usr/bin/env bash

set -e

# run black - make sure everyone uses same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run mypy for the configured modules in the src directory
cd src
mypy $MYPY_ENABLED_MODULES
cd ..

# run bandit - A security linter from OpenStack Security
bandit -r src

# python static analysis
prospector --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# python tests
py.test -c pytest_ci.ini -x --disable-socket -W error::RuntimeWarning --cov=src --cov-fail-under=100
