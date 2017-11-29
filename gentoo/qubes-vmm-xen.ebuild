# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit eutils flag-o-matic mount-boot multilib python-any-r1 toolchain-funcs

MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}

KEYWORDS="amd64"
SRC_URI="https://downloads.xenproject.org/release/xen/${MY_PV}/xen-${MY_PV}.tar.gz"
DESCRIPTION="The Xen virtual machine monitor"
HOMEPAGE="https://www.xenproject.org"
HOMEPAGE="https://www.qubes-os.org/"
LICENSE="GPL-2"

SLOT="0"
IUSE=""

DEPEND="${PYTHON_DEPS}
	efi? ( >=sys-devel/binutils-2.22[multitarget] )
	!efi? ( >=sys-devel/binutils-2.22 )"
RDEPEND="!!app-emulation/xen"
PDEPEND=""

RESTRICT="test splitdebug strip"

S="${WORKDIR}/xen-${MY_PV}"

pkg_setup() {
	python-any-r1_pkg_setup
    XEN_TARGET_ARCH="x86_64"
}

src_prepare() {
	# QubesOS patchset
	einfo "Apply QubesOS patch set"
    EPATCH_SUFFIX="patch" \
    EPATCH_FORCE="yes" \
    EPATCH_OPTS="-p1" \
    epatch "${FILESDIR}"

	# Drop .config
	sed -e '/-include $(XEN_ROOT)\/.config/d' -i Config.mk || die "Couldn't	drop"

	default
}

src_compile() {
	# Send raw LDFLAGS so that --as-needed works
	emake V=1 CC="$(tc-getCC)" LDFLAGS="$(raw-ldflags)" LD="$(tc-getLD)" -C xen ${myopt}
}

src_install() {
	emake LDFLAGS="$(raw-ldflags)" DESTDIR="${D}" -C xen ${myopt} install
}
