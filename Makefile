all: prep build

prep:
	touch packer_cache/build_tarball.tbz

build: gentoo.json
	packer build gentoo.json
