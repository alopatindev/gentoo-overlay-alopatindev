# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DIST_VERSION="0.1.0-beta.5"

inherit cargo gnome2-utils meson ninja-utils xdg-utils

DESCRIPTION="Chat over Telegram on a modern and elegant client"
HOMEPAGE="https://github.com/paper-plane-developers/paper-plane"

CRATES="adler-1.0.2
	aho-corasick-1.1.2
	anyhow-1.0.75
	autocfg-1.1.0
	bindgen-0.68.1
	bitflags-1.3.2
	bitflags-2.4.1
	bytemuck-1.14.0
	byteorder-1.5.0
	cairo-rs-0.18.2
	cairo-sys-rs-0.18.2
	cc-1.0.83
	cexpr-0.6.0
	cfg-expr-0.15.5
	cfg-if-1.0.0
	clang-sys-1.6.1
	color_quant-1.1.0
	crc32fast-1.3.2
	darling-0.20.3
	darling_core-0.20.3
	darling_macro-0.20.3
	ellipse-0.2.0
	env_logger-0.10.0
	equivalent-1.0.1
	fdeflate-0.3.1
	field-offset-0.3.6
	flate2-1.0.28
	fnv-1.0.7
	futures-0.3.29
	futures-channel-0.3.29
	futures-core-0.3.29
	futures-executor-0.3.29
	futures-io-0.3.29
	futures-macro-0.3.29
	futures-sink-0.3.29
	futures-task-0.3.29
	futures-util-0.3.29
	gdk4-0.7.3
	gdk4-sys-0.7.2
	gdk-pixbuf-0.18.0
	gdk-pixbuf-sys-0.18.0
	gettext-rs-0.7.0
	gettext-sys-0.21.3
	gio-0.18.2
	gio-sys-0.18.1
	glib-0.18.2
	glib-macros-0.18.2
	glib-sys-0.18.1
	glob-0.3.1
	gobject-sys-0.18.0
	graphene-rs-0.18.1
	graphene-sys-0.18.1
	gsk4-0.7.3
	gsk4-sys-0.7.3
	gtk4-0.7.3
	gtk4-macros-0.7.2
	gtk4-sys-0.7.3
	hashbrown-0.14.2
	heck-0.4.1
	html-escape-0.2.13
	humantime-2.1.0
	ident_case-1.0.1
	image-0.24.7
	indexmap-2.1.0
	is-terminal-0.4.9
	itoa-1.0.9
	jpeg-decoder-0.3.0
	lazycell-1.3.0
	lazy_static-1.4.0
	libadwaita-0.5.3
	libadwaita-sys-0.5.3
	libc-0.2.149
	libloading-0.7.4
	libshumate-0.4.1
	libshumate-sys-0.4.0
	linux-raw-sys-0.4.10
	locale_config-0.3.0
	log-0.4.20
	memchr-2.6.4
	memoffset-0.9.0
	minimal-lexical-0.2.1
	miniz_oxide-0.7.1
	nom-7.1.3
	num-integer-0.1.45
	num-rational-0.4.1
	num-traits-0.2.17
	once_cell-1.18.0
	origami-0.1.0
	pango-0.18.0
	pango-sys-0.18.0
	peeking_take_while-0.1.2
	pin-project-lite-0.2.13
	pin-utils-0.1.0
	pkg-config-0.3.27
	png-0.17.10
	pretty_env_logger-0.5.0
	prettyplease-0.2.15
	proc-macro2-1.0.69
	proc-macro-crate-1.3.1
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	qrcodegen-1.8.0
	qrcode-generator-4.1.9
	quote-1.0.33
	regex-1.10.2
	regex-automata-0.4.3
	regex-syntax-0.8.2
	rgb-0.8.37
	rlottie-0.5.2
	rlottie-sys-0.2.9
	rustc-hash-1.1.0
	rustc_version-0.4.0
	rustix-0.38.21
	ryu-1.0.15
	semver-1.0.20
	serde-1.0.190
	serde_derive-1.0.190
	serde_json-1.0.108
	serde_spanned-0.6.4
	serde_with-3.4.0
	serde_with_macros-3.4.0
	shlex-1.2.0
	simd-adler32-0.3.7
	slab-0.4.9
	smallvec-1.11.1
	strsim-0.10.0
	syn-1.0.109
	syn-2.0.38
	system-deps-6.2.0
	target-lexicon-0.12.12
	tdlib-0.10.0
	tdlib-tl-gen-0.5.0
	tdlib-tl-parser-0.2.0
	temp-dir-0.1.11
	termcolor-1.3.0
	thiserror-1.0.50
	thiserror-impl-1.0.50
	toml-0.8.6
	toml_datetime-0.6.5
	toml_edit-0.19.15
	toml_edit-0.20.7
	unicode-ident-1.0.12
	unicode-segmentation-1.10.1
	utf8-width-0.1.6
	version_check-0.9.4
	version-compare-0.1.1
	winnow-0.5.18"

SRC_URI="https://github.com/paper-plane-developers/paper-plane/releases/download/v${DIST_VERSION}/${PN}-v${DIST_VERSION}.tar.xz
	$(cargo_crate_uris ${CRATES})"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=gui-libs/gtk-4.10[reversed-list]
	>=gui-libs/libadwaita-1.4
	>=media-libs/libshumate-1.0
	media-libs/rlottie"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/meson
	dev-build/ninja
	|| (
		dev-lang/rust
		dev-lang/rust-bin
	)
	=dev-libs/tdlib-1.8.19
	dev-util/blueprint-compiler"

S="${WORKDIR}"
BUILD_DIR="${WORKDIR}/${P}-build"

src_configure() {
	cargo_src_configure

	if [ -z "${TG_API_ID}" ] || [ -z "${TG_API_HASH}" ] ; then
		ewarn "Create API credentials at https://my.telegram.org/ -> API development tools"
		ewarn "Apply the credentials:"
		ewarn "  mkdir -p /etc/portage/env /etc/portage/package.env"
		ewarn "  echo 'TG_API_ID=\"<your App api_id>\"' > /etc/portage/env/paper-plane.conf"
		ewarn "  echo 'TG_API_HASH=\"<your App api_hash>\"' >> /etc/portage/env/paper-plane.conf"
		ewarn "  chmod og-r /etc/portage/env/paper-plane.conf"
		ewarn "  echo 'net-im/paper-plane paper-plane.conf' > /etc/portage/package.env/paper-plane"
		ewarn "And click 'Save changes'"
		ewarn
		ewarn "More info: https://github.com/paper-plane-developers/paper-plane/tree/v${DIST_VERSION}#installation-instructions"
		die "Provide Telegram API Credentials to avoid possible ban"
	fi

	local emesonargs=(
		-Dtg_api_id="${TG_API_ID}"
		-Dtg_api_hash="${TG_API_HASH}"
	)
	meson_src_configure
}

src_compile() {
	eninja -C "${BUILD_DIR}"
}

src_install() {
	export DESTDIR="${D}"
	eninja -C "${BUILD_DIR}" install
	chmod a-r "${D}"/usr/bin/paper-plane
}

pkg_postinst() {
	xdg_icon_cache_update
	gnome2_schemas_update
	ewarn "Never distribute the binary of this package, it contains your application credentials, which are forbidden to pass to third parties."
}

pkg_postrm() {
	xdg_icon_cache_update
	gnome2_schemas_update
}
