# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 fcaps toolchain-funcs

DESCRIPTION="simple X display locker"
HOMEPAGE="https://tools.suckless.org/slock/"
EGIT_REPO_URI="https://git.suckless.org/slock"

LICENSE="MIT"
SLOT="0"

RDEPEND="
	virtual/libcrypt:=
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"

PATCHES=(
	"${FILESDIR}"/01-slock-fix-link-paths.patch
	"${FILESDIR}"/02-slock-dpms-1.4.patch
	"${FILESDIR}"/50-colors.patch
)

src_prepare() {
	default

	sed -i \
		-e '/^CFLAGS/{s: -Os::g; s:= :+= :g}' \
		-e '/^CC/d' \
		-e '/^LDFLAGS/{s:-s::g; s:= :+= :g}' \
		config.mk || die
	sed -i \
		-e 's|@${CC}|$(CC)|g' \
		Makefile || die

	tc-export CC
}

src_compile() {
	emake slock
}

src_install() {
	dobin slock
}

pkg_postinst() {
	# cap_dac_read_search used to be enough for shadow access
	# but now slock wants to write to /proc/self/oom_score_adj
	# and for that it needs:
	fcaps \
		cap_dac_override,cap_setgid,cap_setuid,cap_sys_resource \
		/usr/bin/slock
}
