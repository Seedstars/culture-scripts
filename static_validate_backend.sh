#!/usr/bin/env bash

# run black - make sure everyone uses the same python style
black --skip-string-normalization --line-length 120 --check tests
black --skip-string-normalization --line-length 120 --check src

# run python static validation
prospector  --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# run bandit - A security linter from OpenStack Security
bandit -r src
