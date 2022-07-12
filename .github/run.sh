#!/bin/bash

set -e

pip install pip-upgrader
pip-upgrade --skip-package-installation -p octoprint
