#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([capricorn],[beta-1.0], [halleluajhdrive@gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([foreign])



# Checks for programs.
LT_INIT
AC_PROG_CC
AC_PROG_CC_STDC
AM_PROG_VALAC([0.26])
AC_PROG_INSTALL
#IT_PROG_INTLTOOL([0.50])

# Checks for libraries.
pkg_modules="
	cairo
	gdk-3.0
	glib-2.0
	gtk+-3.0
	json-glib-1.0
	libsoup-2.4
	pango
	rest-0.7
	sqlite3
	"

PKG_CHECK_MODULES(CPR,[$pkg_modules])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
CPR_VALA_FLAGS=" \
	--pkg cairo \
	--pkg gdk-3.0 \
	--pkg glib-2.0 \
	--pkg gmodule-2.0 \
	--pkg gtk+-3.0 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg pango \
	--pkg rest-0.7 \
	--pkg sqlite3 \
	--target-glib=2.38 \
	--gresources=\$(top_srcdir)/gresources.xml
"

AC_SUBST(CPR_CFLAGS)
AC_SUBST(CPR_LIBS)
AC_SUBST(CPR_VALA_FLAGS)

AC_CONFIG_FILES([Makefile
                 src/Makefile
                 ui/Makefile])

AC_PATH_PROG(GLIB_COMPILE_RESOURCES,glib-compile-resources)

AC_OUTPUT
