# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils gnome2-utils wxwidgets xdg-utils

DOC_PV="${PV}"
DESCRIPTION="Free crossplatform audio editor"
HOMEPAGE="http://web.audacityteam.org/"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="git://github.com/audacity/audacity"
else
	MY_P="${PN}-minsrc-${PV}"
	SRC_URI="https://dev.gentoo.org/~polynomial-c/dist/${MY_P}.tar.xz
		doc? ( https://dev.gentoo.org/~polynomial-c/dist/${PN}-manual-${DOC_PV}.zip )"
		# wget doesn't seem to work on FossHub links, so we mirror
	S="${WORKDIR}/${MY_P}-rc1"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~mips ~ppc ~ppc64 ~x86"
IUSE="alsa cpu_flags_x86_sse +customizations +debug doc ffmpeg +flac id3tag jack +ladspa +lame libav
	+lv2 mad +midi -mod-script-pipe nls +portmixer sbsms +soundtouch -system-libs twolame vamp +vorbis +vst"
RESTRICT="test"

RDEPEND=">=app-arch/zip-2.3
	dev-libs/expat
	>=media-libs/libsndfile-1.0.0
	=media-libs/portaudio-19*
	media-libs/soxr
	=x11-libs/wxGTK-9999[X]
	alsa? ( media-libs/alsa-lib )
	ffmpeg? ( libav? ( media-video/libav:= )
		!libav? ( >=media-video/ffmpeg-1.2:= ) )
	flac? ( >=media-libs/flac-1.3.1[cxx] )
	id3tag? ( media-libs/libid3tag )
	jack? ( virtual/jack )
	lame? ( >=media-sound/lame-3.70 )
	lv2? ( media-libs/lv2 )
	mad? ( >=media-libs/libmad-0.14.2b )
	midi? ( media-libs/portmidi )
	sbsms? ( media-libs/libsbsms )
	soundtouch? ( >=media-libs/libsoundtouch-1.3.1 )
	twolame? ( media-sound/twolame )
	vamp? ( >=media-libs/vamp-plugin-sdk-2.0 )
	vorbis? ( >=media-libs/libvorbis-1.0 )"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

REQUIRED_USE="soundtouch? ( midi )"

CUSTOMIZATION_PATCHES=(
	"${FILESDIR}/audacity-9999-xsystem.patch" # https://forum.audacityteam.org/viewtopic.php?p=346798#p346798
	"${FILESDIR}/audacity-9999-trim-button-clicks.patch"
	"${FILESDIR}/audacity-9999-auto-punch.patch" # https://forum.audacityteam.org/viewtopic.php?f=39&t=103670
	"${FILESDIR}/audacity-9999-select-tracks-reversed.patch"
	"${FILESDIR}/audacity-9999-non-interactive-noise-reduction.patch"
	"${FILESDIR}/audacity-9999-sort-macros.patch"
	"${FILESDIR}/audacity-9999-disable-default-macros.patch"
	"${FILESDIR}/audacity-9999-snd-avg-workaround.patch" # possible workaround https://forum.audacityteam.org/viewtopic.php?f=39&t=75738#p228219
)

src_prepare() {
	use customizations && epatch "${CUSTOMIZATION_PATCHES[@]}"
	eautoreconf
	eapply_user
}

src_configure() {
	local WX_GTK_VER="3.1"
	need-wxwidgets unicode

	local LIB_PREFERENCE="local system"
	use system-libs && LIB_PREFERENCE="system local"

	local myeconfargs=(
		--with-lib-preference="${LIB_PREFERENCE}"
		#--disable-dynamic-loading
		$(use_enable debug)
		--enable-nyquist
		--enable-unicode
		$(use_with mod-script-pipe)
		--with-portaudio
		--with-wx-version=${WX_GTK_VER}
		$(use_enable cpu_flags_x86_sse sse)
		$(use_enable ladspa)
		$(use_enable nls)
		$(use_enable vst)
		#$(use_with alsa)
		$(use_with ffmpeg)
		$(use_with flac libflac)
		$(use_with id3tag libid3tag)
		#$(use_with jack)
		$(use_with lame)
		$(use_with lv2)
		$(use_with mad libmad)
		$(use_with midi)
		$(use_with sbsms)
		$(use_with soundtouch)
		$(use_with twolame libtwolame)
		$(use_with vamp libvamp)
		$(use_with vorbis libvorbis)
		$(use_with portmixer)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	# Remove bad doc install
	rm -r "${D%/}"/usr/share/doc || die

	# Install our docs
	dodoc README.txt

	if use doc ; then
		docinto html
		dodoc -r "${WORKDIR}"/help/manual/{m,man,manual}
		dodoc "${WORKDIR}"/help/manual/{favicon.ico,index.html,quick_help.html}
		dosym ../../doc/${PF}/html /usr/share/${PN}/help/manual
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
