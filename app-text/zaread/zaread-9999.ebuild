# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3

DESCRIPTION="A (very) lightweight MS Office files reader"
HOMEPAGE="https://github.com/paoloap/zaread"
EGIT_REPO_URI="https://github.com/paoloap/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="zathura"

#libreoffice + optionally zathura
DEPEND="
	virtual/ooo
	zathura? ( app-text/zathura )
"
RDEPEND="${DEPEND}"
BDEPEND=""

DOCS=( README.md )

src_install() {
	exeinto "/usr/bin"
	doexe ${PN}
	#dodoc ${DOCS}
}
