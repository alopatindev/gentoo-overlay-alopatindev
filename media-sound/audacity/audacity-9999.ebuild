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
	+lv2 mad +midi -mod-script-pipe nls +portmixer sbsms +soundtouch +system-libs twolame vamp +vorbis +vst"
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

PATCHES=(
	#"${FILESDIR}/${PN}-2.2.1-portmixer.patch" #624264
	"${FILESDIR}/${PN}-2.2.2-automake.patch" # or else eautoreconf breaks
	#"${FILESDIR}/${PN}-2.2.2-midi.patch" #637110
)

CUSTOMIZATION_PATCHES=(
	"${FILESDIR}/audacity-9999-xsystem.patch" # https://forum.audacityteam.org/viewtopic.php?p=346798#p346798
	"${FILESDIR}/audacity-9999-trim-button-clicks.patch"
)

src_prepare() {
	epatch "${PATCHES[@]}"
	use customizations && epatch "${CUSTOMIZATION_PATCHES[@]}"

	# needed because of portmixer patch
	eautoreconf

	eapply_user
}

src_configure() {
	local WX_GTK_VER="3.1"
	need-wxwidgets unicode

	local LIB_LOCATION=local
	use system-libs && LIB_LOCATION=system

	# * always use system libraries if possible
	# * options listed in the order that configure --help lists them
	local myeconfargs=(
		#--disable-dynamic-loading
		--with-expat=${LIB_LOCATION}
		--with-libsndfile=${LIB_LOCATION}
		--with-libsoxr=${LIB_LOCATION}
		--with-widgetextra=local
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
		$(use_with ffmpeg)=${LIB_LOCATION}
		$(use_with flac libflac)=${LIB_LOCATION}
		$(use_with id3tag libid3tag)=${LIB_LOCATION}
		#$(use_with jack)
		$(use_with lame)=${LIB_LOCATION}
		$(use_with lv2)
		$(use_with mad libmad)=${LIB_LOCATION}
		$(use_with midi)
		$(use_with sbsms)
		$(use_with soundtouch)=${LIB_LOCATION}
		$(use_with twolame libtwolame)=${LIB_LOCATION}
		$(use_with vamp libvamp)=${LIB_LOCATION}
		$(use_with vorbis libvorbis)=${LIB_LOCATION}
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
