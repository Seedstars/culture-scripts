#!/usr/bin/env bash

set -e

# python static analysis
prospector --profile-path=. --profile=.prospector.yml --path=src --ignore-patterns=static --output-format=xunit > shippable/testresults/python.xml

# python tests
py.test -c pytest_ci.ini --cov=src --cov-report=xml tests/

# run bandit - A security linter from OpenStack Security
bandit -r src


# Example pytest_ini.py
#
# [pytest]
# norecursedirs = scripts node_modules py-requirements webpack .* {args}
# DJANGO_SETTINGS_MODULE=yourprojectname.settings.ci
# python_paths = src tests
