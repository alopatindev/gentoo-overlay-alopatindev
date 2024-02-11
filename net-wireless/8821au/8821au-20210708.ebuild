# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 linux-mod-r1

DESCRIPTION="Optimized for TP-Link Archer T2U PLUS used on Raspberry Pi B4 as AP"
HOMEPAGE="https://github.com/morrownr/8821au-20210708"

EGIT_REPO_URI="${HOMEPAGE}"
EGIT_VERSION="6cd61cfce48218c26b57db4733aa0d3cbf9a2f2c"

KEYWORDS="~amd64 ~arm64 ~x86"

LICENSE="GPL-2"
SLOT="0"

PDEPEND=""
BDEPEND=""

REQUIRED_USE="kernel_linux"

PATCHES=(
	"${FILESDIR}"/fix-channels-whitelist.patch
)

src_compile() {
	local modlist=( 8821au=kernel/drivers/net/wireless )
	local modargs=( "KVER=${KV_FULL}" )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	insinto /etc/modprobe.d
	doins "${FILESDIR}"/8821au.conf
}
