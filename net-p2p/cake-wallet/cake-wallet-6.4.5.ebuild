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

#src_prepare() {
#	default
#
#	# Keep Flutter/Dart caches inside the Portage build directory.
#	export PUB_CACHE="${T}/pub-cache"
#
#	git config --global --add safe.directory /opt/flutter
#
#	addwrite /opt/flutter
#
#	flutter config --enable-linux-desktop --no-analytics || die
#}
#
#src_compile() {
#	cd "${S}" || die
#
#	# This is intentionally done after git-r3 has checked out EGIT_COMMIT.
#	#flutter pub get || die
#
#	# Generate project files when provided by this release.
#	#if [[ -f tool/generate_localization.dart ]]; then
#	#	dart --disable-analytics run tool/generate_localization.dart || die
#	#fi
#
#	flutter build linux --release || die
#}
#
#src_install() {
#	local appdir="/opt/${PN}"
#
#	insinto "${appdir}"
#	doins -r build/linux/x64/release/bundle/*
#
#	fperms +x "${appdir}/cake_wallet"
#
#	dosym "${appdir}/cake_wallet" /usr/bin/cake-wallet
#
#	make_desktop_entry \
#		cake-wallet \
#		"Cake Wallet" \
#		"" \
#		"Finance;Utility;" \
#		"Non-custodial cryptocurrency wallet"
#}



src_prepare() {
	default

	addwrite /opt/flutter

	# Prevent Flutter/Dart from attempting analytics during the build.
	export PUB_ENVIRONMENT="flutter_cli:disable_analytics"
	export FLUTTER_SUPPRESS_ANALYTICS=true

	# The repository intentionally ignores this generated file.
	# The build scripts will regenerate the required configuration.
	git config --global --add safe.directory "${S}"

	# Do not build the Flatpak inside the ebuild. The installed Linux
	# bundle is sufficient and avoids requiring a privileged sandbox.
	#sed -i \
	#	-e 's/^version: .*/version: 0.0.0/' \
	#	pubspec.yaml || die
}

src_compile() {
	export HOME="${T}"
	export PUB_CACHE="${T}/pub-cache"
	export CARGO_HOME="${T}/cargo"
	export GOPATH="${T}/go"

	# Generate the native cryptocurrency dependencies used by Cake Wallet.
	#if [[ -x scripts/gen_android_manifest.sh ]]; then
	#	./scripts/gen_android_manifest.sh || die
	#fi

	if [[ -x scripts/prepare_moneroc.sh ]]; then
		./scripts/prepare_moneroc.sh || die
	fi

	if [[ -x scripts/prepare_torch.sh ]]; then
		./scripts/prepare_torch.sh || die
	fi

	if [[ -x scripts/prepare_zcash.sh ]]; then
		./scripts/prepare_zcash.sh || die
	fi

	if [[ -x scripts/prepare_reown.sh ]]; then
		./scripts/prepare_reown.sh || die
	fi

	if [[ -x scripts/build_bitbox_flutter.sh ]]; then
		./scripts/build_bitbox_flutter.sh || die
	fi

	if [[ -x scripts/linux/build_monero_all.sh ]]; then
		pushd scripts/linux >/dev/null || die
		./build_monero_all.sh || die
		./build_zcash.sh || die
		source ./app_env.sh cakewallet
		./app_config.sh
		popd >/dev/null || die
	fi

	flutter --disable-analytics pub get || die

	if [[ -x model_generator.sh ]]; then
		./model_generator.sh || die
	fi

	dart --disable-analytics run tool/generate_localization.dart || die
	dart --disable-analytics run tool/generate_new_secrets.dart || die

	flutter --disable-analytics build linux --release || die
}

src_install() {
	local bundle="${S}/build/linux/x64/release/bundle"

	if [[ ! -d ${bundle} ]]; then
		die "Flutter Linux bundle was not produced: ${bundle}"
	fi

	insinto "/opt/${PN}"
	doins -r "${bundle}"/*

	# Main executable.
	dosym "/opt/${PN}/cake_wallet" "/usr/bin/cake-wallet"

	newicon -s 256 "${S}/assets/images/app_logo.png" cake-wallet.png

	domenu "${FILESDIR}/cake-wallet.desktop"

	make_desktop_entry \
		cake-wallet \
		"Cake Wallet" \
		cake-wallet \
		"Finance;Qt;" \
		"Cryptocurrency wallet"
}
