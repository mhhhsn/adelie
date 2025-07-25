# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="a generic, highly customizable, and efficient menu for the X Window System"
HOMEPAGE="https://tools.suckless.org/dmenu/"
EGIT_REPO_URI="https://git.suckless.org/dmenu"

LICENSE="MIT"
SLOT="0"
IUSE="xinerama"

RDEPEND="
	media-libs/fontconfig
	x11-libs/libX11
	>=x11-libs/libXft-2.3.5
	xinerama? ( x11-libs/libXinerama )
"
DEPEND="${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-5.2-gentoo.patch
	"${FILESDIR}/51_theme.diff"
)

src_prepare() {
	default

	sed -i \
		-e 's|^	@|	|g' \
		-e '/^	echo/d' \
		Makefile || die
}

src_compile() {
	emake CC="$(tc-getCC)" \
		"FREETYPEINC=$($(tc-getPKG_CONFIG) --cflags x11 fontconfig xft 2>/dev/null)" \
		"FREETYPELIBS=$($(tc-getPKG_CONFIG) --libs x11 fontconfig xft 2>/dev/null)" \
		"X11INC=$($(tc-getPKG_CONFIG) --cflags x11 2>/dev/null)" \
		"X11LIB=$($(tc-getPKG_CONFIG) --libs x11 2>/dev/null)" \
		"XINERAMAFLAGS=$(
			usex xinerama "-DXINERAMA $(
				$(tc-getPKG_CONFIG) --cflags xinerama 2>/dev/null
			)" ''
		)" \
		"XINERAMALIBS=$(
			usex xinerama "$($(tc-getPKG_CONFIG) --libs xinerama 2>/dev/null)" ''
		)"
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
}
