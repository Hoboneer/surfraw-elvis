#!/bin/sh

PKG_MANAGER_CMD="${PKG_MANAGER_CMD:-pipx}"

yes | $PKG_MANAGER_CMD ${UNINSTALL_CMD:-uninstall} surfraw-tools || echo not installed... continuing anyway
$PKG_MANAGER_CMD ${INSTALL_CMD:-install --spec} git+https://github.com/hoboneer/surfraw-elvis-generator surfraw-tools
