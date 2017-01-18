NAME=docker-compose
VERSION=1.10.0
EPOCH=1
ITERATION=1
PREFIX=/usr/local/bin
LICENSE=BSD
VENDOR="Docker"
MAINTAINER="Ryan Parman"
DESCRIPTION="Docker Compose is a tool for defining and running multi-container Docker applications."
URL=https://docs.docker.com/compose/
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean extract package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "EPOCH:       $(EPOCH)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir*

#-------------------------------------------------------------------------------

.PHONY: extract
extract:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION);
	wget -O /tmp/installdir-$(NAME)-$(VERSION)/docker-compose https://github.com/docker/compose/releases/download/$(VERSION)/docker-compose-Linux-x86_64
	cd /tmp/installdir-$(NAME)-$(VERSION) && ln -s docker-compose compose

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix $(PREFIX) \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrfile 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-auto-add-directories \
		--template-scripts \
		docker-compose \
		compose \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
