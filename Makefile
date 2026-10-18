.PHONY: setup lint links check changelog clean

LYCHEE_IMAGE := lycheeverse/lychee:0.24.2

setup:
	npm ci

lint:
	npx markdownlint-cli2

# Relative links and anchors only (--offline): external pages change without
# notice and must not fail a build. Needs Docker; CI runs the same version.
links:
	docker run --rm -v "$(CURDIR):/input:ro" -w /input $(LYCHEE_IMAGE) --offline --no-progress --include-fragments --exclude-path node_modules '**/*.md'

check: lint links

# Usage: make changelog VERSION=v0.2.0
changelog:
	@test -n "$(VERSION)" || { echo "usage: make changelog VERSION=vX.Y.Z"; exit 2; }
	npx git-cliff --tag $(VERSION) --output CHANGELOG.md

clean:
	rm -rf node_modules
