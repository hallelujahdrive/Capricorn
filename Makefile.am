ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}

SUBDIRS = data icons src ui

EXTRA_DIST = gresources.xml

AUTOMAKE_OPTIONS = subdir-objects

install-data-hook:
	gtk-update-icon-cache @datadir@/icons/hicolor

uninstall-hook:
	gtk-update-icon-cache @iconsdir@
	if test -d @pkgdatadir@;then rm -r @pkgdatadir@; fi
