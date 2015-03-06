AM_CPPFLAGS = $(CPR_CFLAGS)

AUTOMAKE_OPTIONS = subdir-objects
BUILT_SOURCES = libcapricorn_la_vala.stamp

bin_PROGRAMS = capricorn

noinst_LTLIBRARIES = libcapricorn.la

sources = \
			AccountSettingsPage.vala \
			Capricorn.vala \
			Config.vala \
			DisplaySettingsPage.vala \
			DrawingBox.vala \
			FontProfile.vala \
			FooterDrawingBox.vala \
			HeaderDrawingBox.vala \
			IconButton.vala \
			ImageButton.vala \
			InReplyDrawingBox.vala \
			MainWindow.vala \
			MediaPage.vala \
			MediaWindow.vala \
			OAuth.vala \
			PhotoBox.vala \
			PostPage.vala \
			ProfileImageButton.vala \
			RetweetDrawingBox.vala \
			SettingsWindow.vala \
			SignalPipe.vala \
			TextDrawingBox.vala \
			TLNode.vala \
			TLPage.vala \
			TLSettingsPage.vala \
			TweetNode.vala \
			bitly/ShortingURL.vala \
			bitly/Strings.vala \
			sqlite/CountRecords.vala \
			sqlite/CreateTables.vala \
			sqlite/DeleteAccount.vala \
			sqlite/GetID.vala \
			sqlite/InsertAccount.vala \
			sqlite/InsertColor.vala \
			sqlite/InsertFont.vala \
			sqlite/InsertTimelineNodeCount.vala \
			sqlite/Query.vala \
			sqlite/SelecAccount.vala \
			sqlite/SelectColor.vala \
			sqlite/SelectFont.vala \
			sqlite/UpdateAccountListID.vala \
			sqlite/UpdateColor.vala \
			sqlite/UpdateFont.vala \
			sqlite/UpdateTimelineNodeCount.vala \
			utils/DirPath.vala \
			utils/FileUtil.vala \
			utils/IconName.vala \
			utils/ImageUtil.vala \
			utils/Keys.vala \
			utils/RotateSueface.vala \
			utils/StringUtil.vala \
			utils/UriUtil.vala \
			twitter/Account.vala \
			twitter/Favorite.vala \
			twitter/GetAccountInfo.vala \
			twitter/GetTimelineJson.vala \
			twitter/GetTokenAndTokenSecret.vala \
			twitter/GetTokenURL.vala \
			twitter/GetTweetJson.vala \
			twitter/MonthStrToNum.vala \
			twitter/ParseProfileJson.vala \
			twitter/ParsedJsonObj.vala \
			twitter/PostTweet.vala \
			twitter/Retweet.vala \
			twitter/Strings.vala \
			twitter/Struct.vala \
			twitter/UserStream.vala

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
