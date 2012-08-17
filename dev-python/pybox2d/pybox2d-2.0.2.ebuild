# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

PV="${PV}b2"

MY_P="Box2D-${PV}"

DESCRIPTION="Python binding for Box2D physics library"
HOMEPAGE="http://code.google.com/p/pybox2d/"
SRC_URI="http://pybox2d.googlecode.com/files/pybox2d-${PV}.zip"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/swig"
RDEPEND="${DEPEND}"

RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="Box2D"

src_install() {
	distutils_src_install
}
