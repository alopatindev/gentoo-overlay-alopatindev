# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

DESCRIPTION="Crossplatform log viewer for Android, iOS and text files"
HOMEPAGE="https://github.com/alopatindev/qdevicemonitor"

if [[ ${PV} == "9999" ]] ; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/alopatindev/qdevicemonitor"
else
	SRC_URI="https://github.com/alopatindev/qdevicemonitor/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtgui:5
	dev-util/android-tools
	app-pda/usbmuxd
	app-pda/libimobiledevice"
RDEPEND="dev-qt/qtcore:5"

src_compile() {
	cd "${WORKDIR}/${PF}/${PN}"
	PATH="/usr/lib/qt5/bin:${PATH}"
	qmake
	emake
}

src_install() {
	cd "${WORKDIR}/${PF}"
	dodoc README.md
	insinto /usr/bin
	newicon -s scalable "icons/app_icon.svg" "${PN}.svg"
	domenu "icons/${PN}.desktop"
	doins "${PN}/${PN}"
	fperms 755 "/usr/bin/${PN}"
}
