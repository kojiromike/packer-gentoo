all: prep build

prep:
	touch packer_cache/build_tarball.tbz
	touch packer_cache/portage-latest.tar.xz

build: gentoo.json
	packer build gentoo.json
