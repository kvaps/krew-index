# Update krew-index from submodules
#
# Copyright 2020 Andrei Kvapil
# SPDX-License-Identifier: Apache-2.0

# Source directory with submodules
SRC = sources
# Destination directory with public repository
DST = plugins
# Specify which sources should be updated
WHAT ?= $(shell git ls-files ${SRC})
# Force regenerate packages if no changes detected
FORCE ?= 0
# Specify commit message
MSG = UPD $(shell date -R)


# Detect which submodules were changed
ALLSUBS = $(shell git ls-files ${SRC} --stage | awk '$$1 = "160000" {print $$NF}')
CHANGED = $(shell git status --short ${ALLSUBS} | awk '$$1 == "A" || $$1 == "M" {$$1 = ""; print $$0}')

ifdef WHAT
	ALLTARGETS = $(filter ${WHAT}%,${ALLSUBS})
	ifeq (${FORCE}, 1)
		TARGETS = $(filter ${WHAT}%,${ALLSUBS})
	else
		TARGETS = $(filter ${WHAT}%,${CHANGED})
	endif
else
	ALLTARGETS = ${ALLSUBS}
	ifeq (${FORCE}, 1)
		TARGETS = ${ALLSUBS}
	else
		TARGETS = ${CHANGED}
	endif
endif

.PHONY: all pull index commit push

all: pull index commit push

check:
	[ -n "${ALLTARGETS}" ]

pull: check
	git submodule update --init --remote ${ALLTARGETS}

index: check
	@for src in ${TARGETS}; do \
		dst=$$(echo "$$(echo "$$src" | sed 's|^${SRC}/kubectl-|${DST}/|').yaml"); \
		tag=$$(set -x; cd $$src; git describe --tags --abbrev=0); \
		(set -x; sed -i -e "s/\(  version: \).*/\1$$tag/" -e "/    uri: / s|/[^/]*$$|/$$tag.tar.gz|" $$dst); \
		url=$$(awk -F': ' '$$1 == "    uri" {print $$2}' $$dst); \
		tmp=$$(mktemp); \
    curl -Lo "$$tmp" "$$url"; \
		sha256=$$(sha256sum "$$tmp" | awk '{print $$1}'); \
		(set -x; sed -i -e "s/\(    sha256: \).*/\1$$sha256/" "$$dst"); \
	done

commit:
	git add .gitmodules ${SRC} ${DST}
	git diff --quiet --exit-code --cached && exit 0 || git commit -m "${MSG}"

push:
	git push
