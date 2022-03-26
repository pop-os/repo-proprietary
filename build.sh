#!/usr/bin/env bash

set -ex

SUITES=(bionic focal hirsute impish jammy)

function install_debrep {
	LATEST="$(git ls-remote https://github.com/pop-os/debrepbuild | grep HEAD | cut -c-7)"

	if type debrep; then
		CURRENT="$(debrep --version | cut -d' ' -f5 | cut -c2- | cut -c-7)"
	    if [ ! "$CURRENT" ] || [ "$CURRENT" != "$LATEST" ]; then
	    	INSTALL=1
	    fi
	else
		INSTALL=1
	fi

	if [ "$INSTALL" ]; then
		rustup run stable cargo install --git https://github.com/pop-os/debrepbuild --force
	fi
}

function update_submodules {
	git submodule update --init --recursive --remote
}

function merge_repo {
	for suite in "${SUITES[@]}"; do
		tail -n +6 "$1/suites/$suite.toml" | grep -v extra_repos >> "build/suites/$suite.toml"
	done
	rsync -avz --exclude='LICENSE' \
		--exclude='suites/' \
		--exclude='README.md' \
		$1/ \
		build/
}

function merge_repos {
	mkdir -p build/{keys,suites}

	cp keys/* build/keys/
	for suite in "${SUITES[@]}"; do
		cp "suites/$suite.toml" "build/suites/$suite.toml"
	done

	merge_repo cuda
	merge_repo repo-curated-free
	merge_repo natron
}

function copy_assets {
	rsync -avz assets build/
}

install_debrep
update_submodules
merge_repos
copy_assets

cd build
bash acquire_assets.sh # fetches files needed to create CUDA packages
debrep build
cd ..
