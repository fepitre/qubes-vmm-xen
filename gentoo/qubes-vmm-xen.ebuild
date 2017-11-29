# Maintainer: Frédéric Pierret <frederic.epitre@orange.fr>

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
    >=sys-devel/binutils-2.22
    sys-devel/bin86
    sys-devel/dev86
    sys-power/iasl
    x11-libs/pixman
    sys-apps/pciutils
    dev-libs/lzo:2
    dev-libs/glib:2
    dev-libs/yajl
    dev-libs/libaio
    dev-libs/libgcrypt:0
    sys-libs/zlib
    net-misc/bridge-utils
    "
RDEPEND="!!app-emulation/xen !!app-emulation/xen-tools"
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

    default
}

src_configure() {
    local myconf="--prefix=${PREFIX}/usr \
        --disable-ocamltools \
        --disable-blktap2
        "

    econf ${myconf}
}

src_compile() {
    emake V=1 CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" -C tools
}

src_install() {
    emake LDFLAGS="$(raw-ldflags)" DESTDIR="${D}" install-tools
}
