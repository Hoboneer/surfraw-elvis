#!/bin/sh

PKG_MANAGER_CMD="${PKG_MANAGER_CMD:-pipsi}"
UNINSTALL_CMD="$PKG_MANAGER_CMD uninstall"
INSTALL_CMD="$PKG_MANAGER_CMD install"

yes | $UNINSTALL_CMD surfraw-tools
$INSTALL_CMD git+git://github.com/hoboneer/surfraw-elvis-generator.git@list-enum-options#egg=surfraw_tools
