# Intro

These are some elvi for sites I find interesting and/or useful.

## Dependencies

### General

* GNU Make
* POSIX-compliant shell and utilities (e.g., `grep`, `tr`, and friends)
* surfraw-tools (from [one of my repos](https://github.com/hoboneer/surfraw-elvis-generator))

### Simple elvi (i.e., elvi found under simple-elvi/)

Nothing in addition to the general requirements.

### Complex elvi (i.e., elvi found under complex-elvi/)

* GNU Bash (a few elvi use bash as the interpreter for their `.sh-in` file)
* GNU Wget
* HTML Tidy
* HTML-XML-utils

## Quickstart

    $ make

Generate all elvi (simple and complex; `.elvis` extension) as well as their
completions (`.completion` extension).  Also works in the simple- and
complex-elvi directories.

    $ make install  # or make uninstall

Copy (or delete) elvi to ~/.config/surfraw/elvi.  Fails if an elvis may
clobber one already in the directory to install elvi.  Run `make uninstall
install` if you don't care about clobbering (or you are just reinstalling).
Works in repo root, or in the simple- or complex-elvi drectories.

    $ make elvi  # or make completions

In repo root, or in the simple- or complex-elvi directories, just generate
elvi or their completions.

    $ make simple  # or make complex

Shorthand for running a plain `make` invocation in either directory.

    $ make clean

Clean all elvi and completions.

    $ make clean-gen  # under complex-elvi/

Remove generated, non-elvi files.

    $ make clean-all  # under complex-elvi/

An alias for `make clean clean-gen`.

## Descriptions

### Simple elvi

These are elvi that take no options and serve a similar function as surfraw
bookmarks with embedded "%s".

### Complex elvi

These may take options, and may have more complex build requirements than
other elvi (e.g., `stack` downloads the list of stackexchange sites and uses
it to populate its enum `-site=` option).  May run arbitrary code when
building with elvi using an `.sh-in` file.

### Manual elvi (i.e., elvi found under manual-elvi/)

These do not need building as they are written manually (hence the name).
Note: These are not installed by `make install`.
