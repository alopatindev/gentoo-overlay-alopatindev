# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg cmake optfeature flag-o-matic

#inherit patches
# ^ TODO: drop before moving to gentoo repo, and port to manual selection

inherit git-r3
# ^ TODO: conditional (only for 9999)? maybe port to tarballs before moving to gentoo repo.
EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
EGIT_SUBMODULES=(
	'*'
	-Telegram/ThirdParty/{xxHash,Catch,lz4,libdbusmenu-qt,fcitx{5,}-qt{,5},hime,hunspell,nimf,qt5ct,range-v3,jemalloc,wayland-protocols,plasma-wayland-protocols,xdg-desktop-portal,GSL,kimageformats,kcoreaddons}
	# 👆 buildsystem anyway uses system ms-gsl if it is installed, so, no need for bundled, imho 🤷
	-Telegram/ThirdParty/libtgvoip
	# 👆 devs said it is not used anymore (but I found that it's submodule is still in the repo)
)

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org https://github.com/telegramdesktop/tdesktop"

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"

if [[ "${PV}" = 9999* ]]; then
	EGIT_BRANCH="dev"
else
	# TODO: tarballs
	EGIT_COMMIT="v${PV}"
fi
# 👇 kludge for eix
[[ "${PV}" = 9999* ]] || KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
# 👆 kludge for eix

IUSE="+dbus debug enchant +fonts +hunspell +jemalloc +libdispatch lto pipewire pulseaudio qt6 qt6-imageformats +screencast test +wayland +webkit +X"
# +system-gsl

REQUIRED_USE="
	^^ ( enchant hunspell )
	qt6-imageformats? ( qt6 )
"

COMMON_DEPEND="
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	>=dev-cpp/abseil-cpp-20240116.2:=
	>=dev-libs/glib-2.77:2
	>=dev-libs/gobject-introspection-1.77
	dev-libs/libdispatch
	dev-libs/openssl:=
	>=dev-libs/protobuf-27.2
	dev-libs/xxhash
	media-libs/libjpeg-turbo:=
	media-libs/openal:=[pipewire=]
	media-libs/opus:=
	media-libs/rnnoise:=
	>=media-libs/tg_owt-0_pre20250501:=[pipewire(+)=,screencast=,X=]
	media-video/ffmpeg:=[opus,vpx]
	sys-libs/zlib:=[minizip]
	virtual/opengl
	enchant? ( app-text/enchant:= )
	hunspell? ( >=app-text/hunspell-1.7:= )
	jemalloc? ( dev-libs/jemalloc:=[-lazy-lock] )
	>=dev-qt/qtbase-6.5:6=[dbus?,gui,network,opengl,wayland?,widgets,X?]
	>=dev-qt/qtimageformats-6.5:6=
	>=dev-qt/qtsvg-6.5:6=
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-keysyms
	)
	dev-cpp/ada
	dev-libs/boost:=
	dev-libs/libfmt:=
	!fonts? ( media-fonts/open-sans )
	kde-frameworks/kcoreaddons:6=
	kde-frameworks/kimageformats:6=[avif,heif,jpegxl]
	media-libs/fontconfig:=
	pulseaudio? (
		!pipewire? ( media-sound/pulseaudio-daemon )
	)
	pipewire? (
		media-video/pipewire[sound-server(+)]
		!media-sound/pulseaudio-daemon
	)
	wayland? (
		>=dev-qt/qtwayland-6.5:6=[compositor,qml]
		kde-plasma/kwayland:=
		dev-libs/wayland-protocols:=
		dev-libs/plasma-wayland-protocols:=
	)
	webkit? ( wayland? (
		>=dev-qt/qtdeclarative-6.5:6
		>=dev-qt/qtwayland-6.5:6[compositor]
		) )
	sys-apps/xdg-desktop-portal:=
"
	# dev-libs/libsigc++:2
	# >=dev-cpp/glibmm-2.77:2.68

RDEPEND="
	${COMMON_DEPEND}
	webkit? (
		|| (
			net-libs/webkit-gtk:4.1
			net-libs/webkit-gtk:6
		)
	)
"
DEPEND="
	${COMMON_DEPEND}
	>=dev-cpp/cppgir-2.0_p20240315
	dev-cpp/range-v3
	net-libs/tdlib:=[e2e-private-stuff]
"
	# 👆tdlib builds static libs, and so tdesktop links statically, so, no need to be in RDEPEND
	#
	# system-expected? ( dev-cpp/expected-lite )
	# system-gsl? ( >=dev-cpp/ms-gsl-4.1 )
	# 👆 currently it's buildsystem anyway uses system one if it is anyhow installed
BDEPEND="
	>=dev-cpp/ms-gsl-4.1
	>=dev-build/cmake-3.16
	>=dev-cpp/cppgir-2.0_p20240315
	dev-util/gdbus-codegen
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
	amd64? ( dev-lang/yasm )
"

RESTRICT="!test? ( test )"

# https://github.com/msva/mva-overlay/tree/master/net-im/telegram-desktop/files/patches/0/conditional
# https://github.com/rdnvndr/aurpkg/tree/master/telegram-desktop-patches-master
PATCHES=(
	#"${FILESDIR}"/tdesktop-4.2.4-jemalloc-only-telegram-r1.patch
	#"${FILESDIR}"/tdesktop-4.10.0-system-cppgir.patch
	"${FILESDIR}"/tdesktop-5.2.2-qt6-no-wayland.patch
	"${FILESDIR}"/tdesktop-5.2.2-libdispatch.patch
	"${FILESDIR}"/tdesktop-5.7.2-cstring.patch
	"${FILESDIR}"/tdesktop-5.8.3-cstdint.patch
	"${FILESDIR}"/tdesktop-5.12.3-fix-webview.patch
	#"${FILESDIR}"/tdesktop-5.12.3-qt-namechange.patch
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_hide-sponsored-messages/0000-data_data_sponsored_messages.cpp.patch"
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_chat-ids/chat_ids.patch"
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_hide-banned/0000_hide-messages-from-blocked-users.patch"
	#"${FILESDIR}/patches/0/0000_disable_saving_restrictions.patch"
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_ignore-restrictions/saving-restrictions.patch"
	"${FILESDIR}/patches/0/enable-all-chats-reordering.patch"
	"${FILESDIR}/patches/0/disable-folder-badge.patch"
	"${FILESDIR}/patches/0/disable-archive-badge.patch"
	#"${FILESDIR}/patches/0/0005-Option-to-disable-stories.patch"
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_allow-disable-stories/option-to-disable-stories.patch"
	#"${FILESDIR}/patches/0/conditional/tdesktop_patches_wide-baloons/0000_exploit_through_monospace.patch.d"
	#"${FILESDIR}/patches/0/conditional/tdesktop_patches_wide-baloons/wide_balloons_kotato2.patch"
	"${FILESDIR}/patches/0/conditional/tdesktop_patches_wide-baloons/style.patch"
)

pkg_pretend() {
	if ! use wayland || ! use qt6; then
		ewarn ""
		ewarn "Keep in mind that embedded webview (based on webkit), may not work in runtime."
		ewarn "Upstream has reworked it in sych way that it only guaranteed to work under Wayland+Qt6"
		ewarn ""
	fi

	# if use system-rlottie; then
	# 	eerror ""
	# 	eerror "Currently, ${PN} is totally incompatible with Samsung's rlottie, and uses custom bundled fork."
	# 	eerror "Build will definitelly fail. You've been warned!"
	# 	eerror "Even if you have custom patches to make it build, there is another issue:"
	# 	ewarn ""
	# 	ewarn "Unfortunately, ${PN} uses custom modifications over rlottie"
	# 	ewarn "(which aren't accepted by upstream, since they made it another way)."
	# 	ewarn "This leads to following facts:"
	# 	ewarn "  - Colors replacement maps are not working when you link against system rlottie package."
	# 	ewarn "      That means, for example, that 'giant animated emojis' will ignore skin-tone colors"
	# 	ewarn "      and will always be yellow"
	# 	ewarn "      Ref: https://github.com/Samsung/rlottie/pull/252"
	# 	ewarn "  - Crashes on some stickerpacks"
	# 	ewarn "      Probably related to: https://github.com/Samsung/rlottie/pull/262"
	# 	ewarn ""
	# fi
	if has ccache ${FEATURES}; then
		ewarn "ccache does not work with ${PN} out of the box"
		ewarn "due to usage of precompiled headers"
		ewarn "check bug https://bugs.gentoo.org/715114 for more info"
		ewarn
	fi
}

src_unpack() {
	# use system-gsl && EGIT_SUBMODULES+=(-Telegram/ThirdParty/GSL)

#	# XXX: maybe de-unbundle those? Anyway, they're header-only libraries...
#	#  Moreover, upstream recommends to use bundled versions to avoid artefacts 🤷
#	use system-expected && EGIT_SUBMODULES+=(-Telegram/ThirdParty/expected)

	( use arm && ! use arm64 ) || EGIT_SUBMODULES+=(-Telegram/ThirdParty/dispatch)

#	use system-rlottie && EGIT_SUBMODULES+=(-Telegram/{lib_rlottie,ThirdParty/rlottie})
	# ^ Ref: https://bugs.gentoo.org/752417

	git-r3_src_unpack
}

src_prepare() {
	# use system-rlottie || (
	# # Ref: https://bugs.gentoo.org/752417
	# 	sed -i \
	# 		-e 's/DESKTOP_APP_USE_PACKAGED/0/' \
	# 		cmake/external/rlottie/CMakeLists.txt || die
	# )

	# # Bundle kde-frameworks/kimageformats for qt6, since it's impossible to
	# #   build in gentoo right now.
	# if use qt6-imageformats; then
	# 	sed -e 's/DESKTOP_APP_USE_PACKAGED_LAZY/TRUE/' -i \
	# 		cmake/external/kimageformats/CMakeLists.txt || die
	# 	printf "%s\n" \
	# 		'Q_IMPORT_PLUGIN(QAVIFPlugin)' \
	# 		'Q_IMPORT_PLUGIN(HEIFPlugin)' \
	# 		'Q_IMPORT_PLUGIN(QJpegXLPlugin)' \
	# 		>> cmake/external/qt/qt_static_plugins/qt_static_plugins.cpp || die
	# fi

	# Happily fail if libraries aren't found...
	find -type f \( -name 'CMakeLists.txt' -o -name '*.cmake' \) \
		\! -path './Telegram/lib_webview/CMakeLists.txt' \
		\! -path "./cmake/external/expected/CMakeLists.txt" \
		\! -path './cmake/external/kcoreaddons/CMakeLists.txt' \
		\! -path './cmake/external/lz4/CMakeLists.txt' \
		\! -path './cmake/external/opus/CMakeLists.txt' \
		\! -path './cmake/external/xxhash/CMakeLists.txt' \
		\! -path './cmake/external/qt/package.cmake' \
		\! -path './Telegram/lib_webview/CMakeLists.txt' \
		-print0 | xargs -0 sed -i \
		-e '/pkg_check_modules(/s/[^ ]*)/REQUIRED &/' \
		-e '/find_package(/s/)/ REQUIRED)/' || die
		# \! -path './cmake/external/kimageformats/CMakeLists.txt' \
	# Make sure to check the excluded files for new
	# CMAKE_DISABLE_FIND_PACKAGE entries.

	# Control QtDBus dependency from here, to avoid messing with QtGui.
	if ! use dbus; then
		sed -e '/find_package(Qt[^ ]* OPTIONAL_COMPONENTS/s/DBus *//' \
			-i cmake/external/qt/package.cmake || die
	fi

	# HACK: tmp (nothing is more persistent than temporary, hehe)
	sed -r \
		-e '1i#include <QJsonObject>' \
		-i "${S}/Telegram/SourceFiles/payments/smartglocal/smartglocal_card.h" \
			"${S}/Telegram/SourceFiles/payments/smartglocal/smartglocal_error.h" || die

	# Use system xdg-portal things
	sed -r \
		-e '/generate_dbus\([^ ]*\ org.freedesktop.portal/{s@\$\{third_party_loc\}/xdg-desktop-portal/data@/usr/share/dbus-1/interfaces@}' \
		-i "${S}/Telegram/lib_base/CMakeLists.txt" "${S}/Telegram/CMakeLists.txt" || die

	# Control automagic dep only needed when USE="webkit wayland"
	if ! use webkit || ! use wayland; then
		sed -e 's/QT_CONFIG(wayland_compositor_quick)/0/' \
			-i Telegram/lib_webview/webview/platform/linux/webview_linux_compositor.h || die
	fi

	cmake_src_prepare
}

src_configure() {
	append-flags '-fpch-preprocess' # ccache compatibility.
	# ^ see https://bugs.gentoo.org/715114

	# Having user paths sneak into the build environment through the
	# XDG_DATA_DIRS variable causes all sorts of weirdness with cppgir:
	# - bug 909038: can't read from flatpak directories (fixed upstream)
	# - bug 920819: system-wide directories ignored when variable is set
	export XDG_DATA_DIRS="${EPREFIX}/usr/share"

	# Evil flag (bug #919201)
	filter-flags -fno-delete-null-pointer-checks

	# The ABI of media-libs/tg_owt breaks if the -DNDEBUG flag doesn't keep
	# the same state across both projects.
	# See https://bugs.gentoo.org/866055
	filter-flags '-DDEBUG' # produces bugs in bundled forks of 3party code
	append-cppflags '-DNDEBUG' # Telegram sets that in code

	use lto && (
		append-flags '-flto'
		append-ldflags '-flto'
	)
	local mycxxflags=(
		${CXXFLAGS}
		-Wno-error=deprecated-declarations
		-Wno-deprecated-declarations
		-Wno-switch
		-DLIBDIR="$(get_libdir)"
		-DTDESKTOP_DISABLE_AUTOUPDATE
		# XXX: temp (I hope) kludge (until abseil-cpp-2025+ will be in tree)
		-I/usr/include/tg_owt/third_party/abseil-cpp
	)

	local use_webkit_wayland=$(use !webkit || use !wayland && echo yes || echo no)
	local mycmakeargs=(
		-DQT_VERSION_MAJOR=6

		# Override new cmake.eclass defaults (https://bugs.gentoo.org/921939)
		# Upstream never tests this any other way
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF

		# Control automagic dependencies on certain packages
		## Header-only lib, some git version.
		-DCMAKE_DISABLE_FIND_PACKAGE_tl-expected=ON
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6Quick=${use_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets=${use_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandClient=$(usex !wayland)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandCompositor=${use_webkit_wayland}
		# -DCMAKE_DISABLE_FIND_PACKAGE_KF6CoreAddons=ON

		-DDESKTOP_APP_USE_LIBDISPATCH=$(usex libdispatch)

		-DCMAKE_CXX_FLAGS:="${mycxxflags[*]}"

		# Upstream does not need crash reports from custom builds anyway
		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=ON

		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)  # enables enchant and disables hunspell

		# Unbundling:
		-DDESKTOP_APP_USE_PACKAGED=ON # Main

		-DDESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X)
		# -DDESKTOP_APP_DISABLE_WAYLAND_INTEGRATION="$(usex !wayland)"
		-DDESKTOP_APP_DISABLE_JEMALLOC=$(usex !jemalloc)

		$(usex lto "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON" '')

		-DTDESKTOP_API_TEST=$(usex test)

		## Use system fonts instead of bundled ones
		-DDESKTOP_APP_USE_PACKAGED_FONTS=$(usex !fonts)


		-DDESKTOP_APP_DISABLE_QT_PLUGINS=ON

#		-DDESKTOP_APP_LOTTIE_USE_CACHE=NO
#		# in case of caching bugs. Maybe also useful with system-rlottie[cache]. TODO: test that idea.
	)

	if [[ -n ${MY_TDESKTOP_API_ID} && -n ${MY_TDESKTOP_API_HASH} ]]; then
		einfo "Found custom API credentials"
		mycmakeargs+=(
			-DTDESKTOP_API_ID="${MY_TDESKTOP_API_ID}"
			-DTDESKTOP_API_HASH="${MY_TDESKTOP_API_HASH}"
		)
	else
		# https://github.com/telegramdesktop/tdesktop/blob/dev/snap/snapcraft.yaml
		# Building with snapcraft API credentials by default
		# Custom API credentials can be obtained here:
		# https://github.com/telegramdesktop/tdesktop/blob/dev/docs/api_credentials.md
		# After getting credentials you can export variables:
		#  export MY_TDESKTOP_API_ID="17349""
		#  export MY_TDESKTOP_API_HASH="344583e45741c457fe1862106095a5eb"
		# and restart the build"
		# you can set above variables (without export) in /etc/portage/env/net-im/telegram-desktop
		# portage will use custom variable every build automatically
		mycmakeargs+=(
			-DTDESKTOP_API_ID="611335"
			-DTDESKTOP_API_HASH="d524b414d21f4d37f08684c1df41ac9c"
		)
	fi

	cmake_src_configure
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
	if ! use X && ! use screencast; then
		ewarn "both the 'X' and 'screencast' USE flags are disabled, screen sharing won't work!"
		ewarn
	fi
	if ! use jemalloc && use elibc_glibc; then
		# https://github.com/telegramdesktop/tdesktop/issues/16084
		# https://github.com/desktop-app/cmake_helpers/pull/91#issuecomment-881788003
		ewarn "Disabling USE=jemalloc on glibc systems may cause very high RAM usage!"
		ewarn "Do NOT report issues about RAM usage without enabling this flag first."
		ewarn
	fi
	if use wayland && ! use qt6; then
		ewarn "Wayland-specific integrations have been deprecated with Qt5."
		ewarn "The app will continue to function under wayland, but some"
		ewarn "functionality may be reduced."
		ewarn "These integrations are only supported when built with Qt6."
		ewarn
	fi
	if use qt6 && ! use qt6-imageformats; then
		elog "Enable USE=qt6-imageformats for AVIF, HEIF and JpegXL support"
		elog
	fi
	optfeature_header
	optfeature "AVIF, HEIF and JpegXL image support" kde-frameworks/kimageformats[avif,heif,jpegxl]
}

pkg_postrm() {
	xdg_pkg_postrm
}
