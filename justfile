set shell := ["bash", "-euo", "pipefail", "-c"]

[private]
default:
    @just --list

# Init so we can work here
[group('init')]
init:
    git submodule update --init
    git -C pretalx fetch
    git -C pretalx status
    @echo 'Available Tags:'
    git -C pretalx tag|tail -5

# Release a new pretalx-docker version
[group('release')]
[confirm("This will push tags to origin. Continue?")]
[arg('version', pattern='v\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?')]
release version:
    git pull
    git -C pretalx fetch
    git -C pretalx checkout {{ version }}
    git commit -am "Release {{ version }}" || true
    git tag -m "Release {{ version }}" {{ version }}
    git push --recurse-submodules=no
    git push --tags --recurse-submodules=no
    @echo '{{ GREEN }}Release {{ version }} complete{{ NORMAL }}'
