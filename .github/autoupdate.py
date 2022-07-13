#!/usr/bin/env python

import sys
import subprocess
from tkinter.tix import Tree
import requests

REPO = 'fopina/docker-octoprint'


def main():
    if len(sys.argv) < 2:
        print('missing token')
        exit(2)
    
    token = sys.argv[1]
    subprocess.check_call('pip-upgrade --skip-package-installation -p octoprint', shell=True)
    diff = subprocess.check_output('git diff', shell=True)
    if not diff:
        print('No updates were found')
        exit(0)
    
    with open('requirements.txt') as f:
        new_version = f.read().strip().splitlines()[-1].split('=')[-1]
    print(f'Update detected: {new_version}')
    subprocess.check_call('git config user.email updater@devnull.localhost', shell=True)
    subprocess.check_call('git config user.name Updater', shell=True)

    branch = f'dependency-update/octoprint-{new_version}'

    # check if branch already exists
    subprocess.check_call(['git', 'fetch'])
    branches = subprocess.check_output(['git', 'branch', '-a'], text=Tree)
    if f'{branch}\n' in branches:
        print('Branch already exists, skipping')
        exit(0)

    title = f'bump OctoPrint to {new_version}'
    subprocess.check_call(['git', 'checkout', '-b', branch])
    subprocess.check_call(['git', 'commit', '--signoff', '-a', '-m', title])
    subprocess.check_call(['git', 'push', 'origin', branch])

    r = requests.post(
        f"https://api.github.com/repos/{REPO}/pulls",
        headers={
            "Authorization": f'token {token}',
        },
        json={
            'title': title,
            'head': branch,
            'base': 'main',
            "body": "Auto-generated pull request.",
        }
    )
    r.raise_for_status()


if __name__ == '__main__':
    main()
