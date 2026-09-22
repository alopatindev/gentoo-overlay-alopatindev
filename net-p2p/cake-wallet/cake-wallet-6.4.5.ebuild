EAPI=8

inherit desktop git-r3

DESCRIPTION="Non-custodial multi-currency cryptocurrency wallet"
HOMEPAGE="https://cakewallet.com"
EGIT_REPO_URI="https://github.com/cake-tech/cake_wallet.git"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-lang/flutter
	dev-libs/openssl:0
	media-libs/mesa
	media-libs/libglvnd
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxkbcommon
"
RDEPEND="${DEPEND}"

src_prepare() {
	default

	# Keep Flutter/Dart caches inside the Portage build directory.
	export PUB_CACHE="${T}/pub-cache"

	git config --global --add safe.directory /opt/flutter

	addwrite /opt/flutter

	flutter config --enable-linux-desktop --no-analytics || die
}

src_compile() {
	cd "${S}" || die

	# This is intentionally done after git-r3 has checked out EGIT_COMMIT.
	#flutter pub get || die

	# Generate project files when provided by this release.
	#if [[ -f tool/generate_localization.dart ]]; then
	#	dart --disable-analytics run tool/generate_localization.dart || die
	#fi

	flutter build linux --release || die
}

src_install() {
	local appdir="/opt/${PN}"

	insinto "${appdir}"
	doins -r build/linux/x64/release/bundle/*

	fperms +x "${appdir}/cake_wallet"

	dosym "${appdir}/cake_wallet" /usr/bin/cake-wallet

	make_desktop_entry \
		cake-wallet \
		"Cake Wallet" \
		"" \
		"Finance;Utility;" \
		"Non-custodial cryptocurrency wallet"
}
