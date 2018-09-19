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
	git submodule foreach git pull origin master
}

function merge_repos {
	mkdir -p build

	cp sources.toml build/sources.toml
	tail -n +6 cuda/sources.toml >> build/sources.toml

	rsync -avz --exclude='sources.toml' --exclude='README.md' cuda/ build/
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
