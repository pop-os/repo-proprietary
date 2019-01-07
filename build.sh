#!/usr/bin/env bash

set -ex

function install_debrep {
	LATEST=$(git ls-remote https://github.com/pop-os/debrepbuild | grep HEAD | cut -c-7)

	if type debrep; then
		CURRENT=$(debrep --version | cut -d' ' -f5 | cut -c2- | cut -c-7)
	    if [ ! $CURRENT ] || [ $CURRENT != $LATEST ]; then
	    	INSTALL=1
	    fi
	else
		INSTALL=1
	fi

	if [ $INSTALL ]; then
		cargo install --git https://github.com/pop-os/debrepbuild --force
	fi
}

function update_submodules {
	git submodule update --init --recursive --remote
}

function merge_repo {
	tail -n +6 $1/suites/bionic.toml | grep -v extra_repos >> build/suites/bionic.toml
	tail -n +6 $1/suites/cosmic.toml | grep -v extra_repos >> build/suites/cosmic.toml
	rsync -avz --exclude='LICENSE' \
		--exclude='suites/' \
		--exclude='README.md' \
		$1/ \
		build/
}

function merge_repos {
	mkdir -p build/{keys,suites}

	cp keys/* build/keys/
	cp suites/bionic.toml build/suites/bionic.toml
	cp suites/cosmic.toml build/suites/cosmic.toml
	cp suites/disco.toml build/suites/disco.toml

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
