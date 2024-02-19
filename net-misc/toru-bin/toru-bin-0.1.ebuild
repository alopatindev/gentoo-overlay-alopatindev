EAPI="8"

DESCRIPTION="Bittorrent streaming CLI tool. Stream anime torrents, real-time with no waiting for downloads."
HOMEPAGE="https://github.com/sweetbbak/toru"
SRC_URI="https://github.com/sweetbbak/toru/releases/download/v${PV}/toru_Linux_x86_64.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_install() {
	dobin toru
}
