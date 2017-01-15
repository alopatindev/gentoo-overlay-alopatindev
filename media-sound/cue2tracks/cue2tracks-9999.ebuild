# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

inherit eutils git-r3

DESCRIPTION="Bash script for split audio CD image files with cue sheet to tracks and write tags."
HOMEPAGE="http://code.google.com/p/cue2tracks/"
EGIT_REPO_URI="git://github.com/ar-lex/cue2tracks"

LICENSE="GPL-2"
SLOT="0"
IUSE="flake mac tta shorten wavpack mp3 m4a vorbis"

DEPEND=""

RDEPEND="
	>=media-sound/shntool-3.0.0
	app-shells/bash
	media-libs/flac
	app-cdr/cuetools
	flake? ( media-sound/flake )
	mac? ( media-sound/mac media-sound/apetag )
	tta? ( media-sound/ttaenc )
	shorten? ( media-sound/shorten )
	wavpack? ( media-sound/wavpack media-sound/apetag )
	mp3? ( media-sound/lame media-sound/id3v2 )
	vorbis? ( media-sound/vorbis-tools )
	m4a? ( media-video/mpeg4ip media-libs/faac media-libs/faad2 )
	"

src_install() {
	dobin "${PN}" || die
	dodoc AUTHORS INSTALL ChangeLog README TODO
}

pkg_postinst() {
	echo ""
	einfo 'To get help about usage run "$ cue2tracks -h"'
	echo ""
}
