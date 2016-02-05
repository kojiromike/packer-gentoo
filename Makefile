##
# Gentoo GPG Keys: https://www.gentoo.org/downloads/signatures/
BASE_URL := http://distfiles.gentoo.org/releases/amd64/autobuilds

all: packer-gentoo-hardened.box

clean:
	rm -f install-amd64-minimal-latest.iso
	rm -f install-amd64-minimal-latest.iso.DIGESTS.asc
	rm -f latest-iso.txt
	rm -f latest-stage3-amd64-hardened+nomultilib.txt
	rm -f packer-gentoo-hardened.box
	rm -f portage-latest.tar.xz
	rm -f portage-latest.tar.xz.gpgsig
	rm -f stage3-amd64-hardened+nomultilib-latest.tar.bz2
	rm -f stage3-amd64-hardened+nomultilib-latest.tar.bz2.DIGESTS.asc

portage-latest.tar.xz: portage-latest.tar.xz.gpgsig
	curl -sSLO http://distfiles.gentoo.org/releases/snapshots/current/$@
	gpg --verify $@.gpgsig $@

portage-latest.tar.xz.gpgsig:
	curl -sSLO http://distfiles.gentoo.org/releases/snapshots/current/$@

stage3-amd64-hardened+nomultilib-latest.tar.bz2: latest-stage3-amd64-hardened+nomultilib.txt stage3-amd64-hardened+nomultilib-latest.tar.bz2.DIGESTS.asc
	curl -sSLO $(BASE_URL)/$(shell awk '/hardened/{print $$1}' $<)
	fgrep -A1 '# SHA512 HASH' $@.DIGESTS.asc | fgrep -v CONTENTS | shasum -a 512 -c
	mv stage3-amd64-hardened+nomultilib-*.tar.bz2 $@

stage3-amd64-hardened+nomultilib-latest.tar.bz2.DIGESTS.asc: latest-stage3-amd64-hardened+nomultilib.txt
	curl -sSLo $@ $(BASE_URL)/$(shell awk '/hardened/{print $$1}' $<).DIGESTS.asc
	gpg --verify $@ || rm -f $@

latest-stage3-amd64-hardened+nomultilib.txt:
	curl -sSLO $(BASE_URL)/$@

packer-gentoo-hardened.box: install-amd64-minimal-latest.iso install-amd64-minimal-latest.iso.DIGESTS.asc stage3-amd64-hardened+nomultilib-latest.tar.bz2 portage-latest.tar.xz
	packer build -var iso_file=$< -var iso_checksum=$(shell awk '/install-amd64/{print $$1;exit}' install-amd64-minimal-latest.iso.DIGESTS.asc) -var build_tarball=stage3-amd64-hardened+nomultilib-latest.tar.bz2 -var portage_tarball=portage-latest.tar.xz gentoo.json

install-amd64-minimal-latest.iso: latest-iso.txt
	curl -sSLO $(BASE_URL)/$(shell awk '/install-amd64/{print $$1}' $<)
	mv install-amd64-minimal-*.iso $@

install-amd64-minimal-latest.iso.DIGESTS.asc: latest-iso.txt
	curl -sSLo $@ $(BASE_URL)/$(shell awk '/install-amd64/{ print $$1 }' $<).DIGESTS.asc
	gpg --verify $@ || rm -f $@

latest-iso.txt:
	curl -sSLO $(BASE_URL)/$@
