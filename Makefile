VAGRANT_BOX_NAME:='kojiromike/gentoo'
DUMMY_TARBALLS:=packer_cache/build_tarball.tbz packer_cache/portage-latest.tar.xz
BOX_FILE='packer_virtualbox-iso_virtualbox.box'

.PHONY: all cache clean install

all: cache $(BOX_FILE)

cache: $(DUMMY_TARBALLS)

packer_cache/build_tarball.tbz:
	touch packer_cache/build_tarball.tbz

packer_cache/portage-latest.tar.xz:
	touch packer_cache/portage-latest.tar.xz

$(BOX_FILE):
	packer build gentoo.json

install: $(BOX_FILE)
	vagrant box add -f --name $(VAGRANT_BOX_NAME) $(BOX_FILE)

clean:
	vagrant destroy -f; \
	rm -rf .vagrant $(BOX_FILE)
