AM_CPPFLAGS = $(CPR_CFLAGS)

AUTOMAKE_OPTIONS = subdir-objects
BUILT_SOURCES = libcapricorn_la_vala.stamp

bin_PROGRAMS = capricorn

noinst_LTLIBRARIES = libcapricorn.la

sources = \
			Account.vala \
			AccountSettingsPage.vala \
			Capricorn.vala \
			Config.vala \
			DisplaySettingsPage.vala \
			DrawingBox.vala \
			FavoriteImageButton.vala \
			FontProfile.vala \
			FooterDrawingBox.vala \
			HeaderDrawingBox.vala \
			ImageButton.vala \
			InReplyDrawingBox.vala \
			MainWindow.vala \
			OAuth.vala \
			PostPage.vala \
			ProfileImageButton.vala \
			ReplyImageButton.vala \
			RetweetDrawingBox.vala \
			RetweetImageButton.vala \
			SettingsImageButton.vala \
			SettingsWindow.vala \
			SignalPipe.vala \
			TextDrawingBox.vala \
			TLNode.vala \
			TLPage.vala \
			TweetNode.vala \
			utils/DateTimeUtils.vala \
			utils/DirPath.vala \
			utils/FileUtils.vala \
			utils/ImageUtils.vala \
			utils/JsonUtils.vala \
			utils/SqliteUtils.vala \
			utils/StringUtils.vala \
			utils/TwitterUtils.vala \
			utils/UriUtils.vala

capricorn.vapi libcapricorn_la_vala.stamp capricorn.h : $(sources)
	@$(VALAC) $^ --vapi=capricorn.vapi -C --header capricorn.h @CPR_VALA_FLAGS@
	touch capricorn.vapi libcapricorn_la_vala.stamp capricorn.h

libcapricorn_la_LIBADD = @CPR_LIBS@
libcapricorn_la_VALASOURCES = $(sources)
libcapricorn_la_SOURCES = libcapricorn_la_vala.stamp \
													$(sources:.vala=.c)

capricorn_SOURCES = main.vala resources.c
capricorn_LDADD = libcapricorn.la
capricorn_VALAFLAGS = capricorn.vapi @CPR_VALA_FLAGS@
main.vala : capricorn.vapi capricorn.h

resources_deps = $(top_srcdir)/gresources.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir) $(top_srcdir)/gresources.xml)
resources.c : $(resources_deps)
	$(GLIB_COMPILE_RESOURCES) $(top_srcdir)/gresources.xml --target=$@ --generate-source --sourcedir=$(top_srcdir)


CLEANFILES = *.h *.c *.o *.stamp libcapricorn.la capricorn.vapi capricorn.h utils/*.c
EXTRA_DIST = $(sources) \
						 capricorn.h
