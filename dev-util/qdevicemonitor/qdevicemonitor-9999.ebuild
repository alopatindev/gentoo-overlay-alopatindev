# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop git-r3 qmake-utils xdg

DESCRIPTION="Crossplatform log viewer for Android, iOS and text files"
HOMEPAGE="https://github.com/alopatindev/qdevicemonitor"
EGIT_REPO_URI="https://github.com/alopatindev/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-qt/qtbase:6[gui,widgets]
	virtual/libudev:="
RDEPEND="${DEPEND}
	app-pda/usbmuxd
	dev-util/android-tools"

DOCS=( ../README.md )

src_configure() {
	export VERSION_WITH_BUILD_NUMBER="${PV}-${COMMIT:0:8}"
	eqmake6
}

src_install() {
	dobin "${PN}"
	einstalldocs
	newicon -s scalable "../icons/app_icon.svg" "${PN}.svg"
	domenu "../icons/${PN}.desktop"
}
