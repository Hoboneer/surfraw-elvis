# Intro

These are some elvi for sites I find interesting and/or useful.

## Dependencies

### General

* GNU Make
* POSIX-compliant shell and utilities (e.g., `grep`, `tr`, and friends)
* surfraw-tools (from [one of my repos](https://github.com/hoboneer/surfraw-elvis-generator))
* surfraw (required for running the generated elvi, but not for building)
* `rename` command from Perl (for installing)

### Additional dependencies for more complex elvi

* GNU Bash (a few elvi use bash as the interpreter for their `.sh-in` file)
* GNU Wget
* HTML Tidy
* HTML-XML-utils

## Quickstart

    $ make

Generate all elvi (`.elvis` extension).  Generated elvi will be placed in
elvi/.

    $ make install  # or make uninstall

Copy (or delete) elvi to ~/.config/surfraw/elvi.  Fails if an elvis may clobber
one already in the directory to install elvi.  Run `make uninstall install` if
you don't care about clobbering (or you are just reinstalling).

    $ make uninstall-partial

Delete partially-installed elvi (i.e., elvi installed locally but still have a
`.elvis` extension).  This runs at the same time as `make uninstall`.

    $ make elvi

Just generate elvi.

    $ make clean

Clean all elvi.

    $ make clean-gen

Remove generated, non-elvi files.

    $ make clean-all

An alias for `make clean clean-gen`.

## Descriptions

### Simple elvi

Some elvi are simpler than others, taking ~3 lines in their `.in` file.  These
are elvi that take no options and serve a similar function as surfraw bookmarks
with embedded "%s".

### Complex elvi

These may take options, and may have more complex build requirements than
other elvi (e.g., `stack` downloads the list of stackexchange sites and uses
it to populate its enum `-site=` option).  May run arbitrary code when
building with elvi using an `.sh-in` file.

### Manual elvi

These do not need building as they are written manually (hence the name).
Note: These are not installed by `make install`.
