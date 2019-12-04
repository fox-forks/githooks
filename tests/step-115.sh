#!/bin/sh
# Test:
#   Disable, enable and accept a shared hook (no .githooks directory)

if ! sh /var/lib/githooks/install.sh; then
    echo "! Failed to execute the install script"
    exit 1
fi

mkdir -p /tmp/test115.shared/shared-repo.git/pre-commit &&
    cd /tmp/test115.shared/shared-repo.git &&
    git init &&
    echo 'echo "Shared invoked" > /tmp/test115.out' >pre-commit/test-shared &&
    git add pre-commit &&
    git commit -m 'Initial commit' ||
    exit 2

mkdir -p /tmp/test115.repo &&
    cd /tmp/test115.repo &&
    git init ||
    exit 3

sh /var/lib/githooks/cli.sh shared add --local /tmp/test115.shared/shared-repo.git &&
    sh /var/lib/githooks/cli.sh shared list | grep "shared_repo" | grep "pending" &&
    sh /var/lib/githooks/cli.sh shared pull ||
    exit 4

if ! sh /var/lib/githooks/cli.sh list | grep 'test-shared' | grep 'shared:local' | grep 'pending'; then
    sh /var/lib/githooks/cli.sh list
    exit 5
fi

sh /var/lib/githooks/cli.sh disable --shared 'test-shared' ||
    exit 6

if ! sh /var/lib/githooks/cli.sh list | grep 'test-shared' | grep 'shared:local' | grep 'disabled'; then
    sh /var/lib/githooks/cli.sh list
    exit 7
fi

sh /var/lib/githooks/cli.sh enable --shared 'test-shared' ||
    exit 8

if ! sh /var/lib/githooks/cli.sh list | grep 'test-shared' | grep 'shared:local' | grep 'pending'; then
    sh /var/lib/githooks/cli.sh list
    exit 9
fi

sh /var/lib/githooks/cli.sh accept --shared pre-commit 'test-shared' ||
    exit 10

if ! sh /var/lib/githooks/cli.sh list | grep 'test-shared' | grep 'shared:local' | grep 'active'; then
    sh /var/lib/githooks/cli.sh list
    exit 11
fi
