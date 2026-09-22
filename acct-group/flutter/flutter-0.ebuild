# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

DESCRIPTION="Group allowed to write to the shared Flutter SDK tree in /opt"

SLOT="0"
KEYWORDS="-* ~amd64"

# No reserved GID in the Gentoo GID/UID assignment table for flutter,
# so let the system pick the next free one.
ACCT_GROUP_ID=-1
