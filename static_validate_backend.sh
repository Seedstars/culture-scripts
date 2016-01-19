#!/usr/bin/env bash

# run python static validation
prospector  --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static
