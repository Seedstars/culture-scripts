#!/usr/bin/env bash

# run python static validation
prospector  --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static

# run bandit - A security linter from OpenStack Security
bandit -r src
