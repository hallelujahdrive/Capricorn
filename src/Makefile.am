AM_CPPFLAGS = $(CPR_CFLAGS)

AUTOMAKE_OPTIONS = subdir-objects
BUILT_SOURCES = libcapricorn_la_vala.stamp

bin_PROGRAMS = capricorn

noinst_LTLIBRARIES = libcapricorn.la

sources = \
			AccountComboBox.vala \
			AccountSettingsPage.vala \
			Capricorn.vala \
			Config.vala \
			DisplaySettingsPage.vala \
			DrawingBox.vala \
			EventDrawingBox.vala \
			EventNode.vala \
			EventNotifyListBox.vala \
			EventNotifyPage.vala \
			EventNotifySettingsPage.vala \
			FontProfile.vala \
			FooterDrawingBox.vala \
			HeaderDrawingBox.vala \
			IconButton.vala \
			ImageButton.vala \
			InReplyDrawingBox.vala \
			MainWindow.vala \
			MediaPage.vala \
			MediaWindow.vala \
			NetworkSettingsPage.vala \
			Node.vala \
			OAuth.vala \
			PhotoBox.vala \
			PostPage.vala \
			ProfileImageButton.vala \
			RetweetDrawingBox.vala \
			ScrolledListBox.vala \
			SettingsWindow.vala \
			SignalPipe.vala \
			TextDrawingBox.vala \
			TimeLine.vala \
			TimeLineSettingsPage.vala \
			TLNode.vala \
			TweetNode.vala \
			bitly/ShortingURL.vala \
			bitly/Strings.vala \
			sqlite/CountRecords.vala \
			sqlite/CreateTables.vala \
			sqlite/DeleteAccount.vala \
			sqlite/GetID.vala \
			sqlite/InsertAccount.vala \
			sqlite/InsertColor.vala \
			sqlite/InsertEventNotifySettings.vala \
			sqlite/InsertFont.vala \
			sqlite/InsertTimeLineSettings.vala \
			sqlite/Query.vala \
			sqlite/SelecAccount.vala \
			sqlite/SelectColor.vala \
			sqlite/SelectEventNotifySettings.vala \
			sqlite/SelectFont.vala \
			sqlite/SelectTimeLineSettings.vala \
			sqlite/UpdateAccountListID.vala \
			sqlite/UpdateColor.vala \
			sqlite/UpdateEventNotifySettings.vala \
			sqlite/UpdateFont.vala \
			sqlite/UpdateTimeLineSettings.vala \
			utils/DirPath.vala \
			utils/FileUtil.vala \
			utils/IconName.vala \
			utils/ImageUtil.vala \
			utils/Keys.vala \
			utils/RotateSueface.vala \
			utils/StringUtil.vala \
			utils/UriUtil.vala \
			twitter/Account.vala \
			twitter/AccountVerifyCredential.vala \
			twitter/Enums.vala \
			twitter/FavoritesCreate.vala \
			twitter/FavoritesDestroy.vala \
			twitter/MonthStrToNum.vala \
			twitter/OauthAccessToken.vala \
			twitter/ParseProfileJson.vala \
			twitter/ParsedJsonObj.vala \
			twitter/RequestToken.vala \
			twitter/StatusesDestroy.vala \
			twitter/StatusesHomeTimeline.vala \
			twitter/StatusesMentionTimeline.vala \
			twitter/StatusesRetweet.vala \
			twitter/StatusesShow.vala \
			twitter/StatusesTimeline.vala \
			twitter/StatusesUpdate.vala \
			twitter/Strings.vala \
			twitter/Struct.vala \
			twitter/User.vala \
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


CLEANFILES = *.h *.c *.o *.stamp libcapricorn.la capricorn.vapi capricorn.h utils/*.c twitter/*.c
EXTRA_DIST = $(sources) \
						 capricorn.h
