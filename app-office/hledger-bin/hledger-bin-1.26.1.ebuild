EAPI=8

DESCRIPTION="Command-line interface for the hledger accounting system"
HOMEPAGE="https://hledger.org"
SRC_URI="https://github.com/simonmichael/hledger/releases/download/${PV}/hledger-linux-x64.zip -> hledger-linux-x64-${PV}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="app-arch/unzip"

S="${WORKDIR}"

src_install() {
	for i in *; do
		#out="${ED}/$(echo $i | sed 's/-linux-x64$//')"
		out="$(echo $i | sed 's/-linux-x64$//')"
		mv "${i}" "${out}"
		insinto "/usr/bin"
		dobin "${out}"
	done
}
