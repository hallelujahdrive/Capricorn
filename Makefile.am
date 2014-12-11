ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}

SUBDIRS = src ui icons

EXTRA_DIST = gresources.xml

AUTOMAKE_OPTIONS = subdir-objects

uninstall-hook:
	if test -d @pkgdatadir@;then rm -r @pkgdatadir@; fi
