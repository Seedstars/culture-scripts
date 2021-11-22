#!/usr/bin/env bash
# Note: when first run this script or migrations are updated, please remove the options --nomigrations and --reuse-db

py.test -n 4 --disable-socket --nomigrations --reuse-db -W error::RuntimeWarning --cov=src --cov-report=html tests/
