# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

DESCRIPTION="A font viewer with character table"
HOMEPAGE="http://qfontviewer.sourceforge.net"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="git://github.com/alopatindev/qfontviewer"
else
	SRC_URI="http://sourceforge.net/projects/qfontviewer/files/${P}.tar.bz2"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5"
RDEPEND=""

src_compile() {
	cd "${WORKDIR}/${PN}"

	econf || die "configure failure"
	emake || die "make failure"
}

src_install() {
	mv "${P}" "${PN}"
	dodoc ChangeLog README HACKING TODO
	insinto /usr/bin
	doins qfontviewer
	fperms 755 /usr/bin/qfontviewer
}
