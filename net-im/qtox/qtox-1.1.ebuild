# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils qmake-utils git-2

DESCRIPTION="Most feature-rich GUI for net-libs/tox using Qt5"
HOMEPAGE="https://github.com/tux3/qtox"
SRC_URI=""
EGIT_REPO_URI="git://github.com/tux3/qtox.git
	https://github.com/tux3/qtox.git"
EGIT_COMMIT="e3dd2dc9e11ff5208e6ead39139c64e0f20db6d9"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+filter_audio gtk X"

DEPEND="
	dev-qt/linguist-tools:5
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5[gif,jpeg,png,xcb]
	dev-qt/qtnetwork:5
	dev-qt/qtopengl:5
	dev-qt/qtsql:5
	dev-qt/qtsvg:5
	dev-qt/qtxml:5
	filter_audio? ( media-libs/libfilteraudio )
	media-gfx/qrencode
	media-libs/openal
	>=media-video/ffmpeg-2.6.3[webp,v4l]
	gtk? (	dev-libs/atk
			dev-libs/glib:2
			x11-libs/gdk-pixbuf[X]
			x11-libs/gtk+:2
			x11-libs/cairo[X]
			x11-libs/pango[X] )
	net-libs/tox[av]
	X? ( x11-libs/libX11
		x11-libs/libXScrnSaver )"
RDEPEND="${DEPEND}"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ $(tc-getCXX) == *g++ ]] ; then
			if [[ $(gcc-major-version) == 4 && $(gcc-minor-version) -lt 8 || $(gcc-major-version) -lt 4 ]] ; then
				eerror "You need at least sys-devel/gcc-4.8.3"
				die "You need at least sys-devel/gcc-4.8.3"
			fi
		fi
	fi
}

src_prepare() {
	epatch_user
}

src_configure() {
	use filter_audio || NO_FILTER_AUDIO="DISABLE_FILTER_AUDIO=YES"
	use gtk || NO_GTK_SUPPORT="ENABLE_SYSTRAY_STATUSNOTIFIER_BACKEND=NO ENABLE_SYSTRAY_GTK_BACKEND=NO"
	use X || NO_X_SUPPORT="DISABLE_PLATFORM_EXT=YES"
	eqmake5 \
			${NO_FILTER_AUDIO} \
			${NO_GTK_SUPPORT} \
			${NO_X_SUPPORT}
}

src_install() {
	dobin "${S}/qtox"
	doicon -s scalable "${S}/img/icons/qtox.svg"
	domenu "${S}/qTox.desktop"
}
