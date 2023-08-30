# Todd Goldfinger <goldfita@signalsguru.net>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#This is a live build of 7.X.X
#echo 'PORTDIR_OVERLAY="/usr/local/portage" >> /etc/make.conf'
#mkdir -p /usr/local/portage/sys-apps/lkcdutils/
#mv lkcdutils-7_alpha.ebuild /usr/local/portage/sys-apps/lkcdutils
#ebuild /usr/local/portage/sys-apps/lkcdutils/lkcdutils-7_alpha.ebuild digest
#emerge lkcdutils

inherit eutils cvs

DESCRIPTION="Linux Kernel Crash Dumps (LKCD) Utilities"
SRC_URI=""
HOMEPAGE="http://lkcd.sourceforge.net/"
LICENSE="GPL-2"
KEYWORDS="~x86"
IUSE=""
SLOT="0"
DEPEND="libelf"
my_d=${WORKDIR}/../image

src_unpack() {
	ECVS_SERVER="cvs.sourceforge.net:/cvsroot/lkcd"
	ECVS_MODULE="lkcd/7.X.X/lkcdutils"
	cvs_src_unpack
}

src_compile() {
 	cd ${WORKDIR}/lkcd/7.X.X/lkcdutils
	./configure \
		--arch=i386 \
		--target-arch=i386 \
		--prefix=${my_d} || die "configure failed"
	emake || die "make failed"
}

src_install() {
	cd ${WORKDIR}/lkcd/7.X.X/lkcdutils
	mkdir -p ${my_d}/usr/local/bin
	mkdir -p ${my_d}/usr/local/man/man1
	mkdir -p ${my_d}/dev
	emake install \
		exec_prefix=${my_d}/usr/local \
		mandir=${my_d}/usr/local/man || die "install failed"
	prepall
}

