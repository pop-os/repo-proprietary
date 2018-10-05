# Pop!\_OS Proprietary Software Repo

APT repository configuration for building the proprietary repo for Pop!\_OS.
Currently, this repo also includes free software as well, for convenience &
inclusion in Pop!\_OS by default for those on 18.04.

> This repo is built by running `debrep build` in the directory of the provided
`sources.toml` file. On a successful build, the GPG key from the provided email
will be requested for signing the repo. The generated `repo/` directory can be
hosted on a web server for other systems to fetch packages from.

