# Copyright 2019-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake git-r3

DESCRIPTION="Cross-platform library for building Telegram clients"
HOMEPAGE="https://core.telegram.org/tdlib"
EGIT_REPO_URI="https://github.com/tdlib/td.git"
EGIT_COMMIT="2589c3fd46925f5d57e4ec79233cd1bd0f5d0c09"
EGIT_CHECKOUT_DIR="${WORKDIR}/td"

LICENSE="Boost-1.0"
SLOT="0"
#KEYWORDS="~amd64 ~x86"

DEPEND="sys-devel/gcc
	dev-libs/openssl
	sys-libs/zlib
	dev-util/gperf
	dev-build/cmake
"
RDEPEND="${DEPEND}"

S="${EGIT_CHECKOUT_DIR}"
BUILD_DIR="${S}/build"
