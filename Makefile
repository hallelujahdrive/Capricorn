VALAC = valac

SRC = \
			src/Account.vala \
			src/AccountSettingsPage.vala \
			src/Capricorn.vala \
			src/Config.vala\
			src/DisplaySettingsPage.vala \
			src/DrawingBox.vala \
			src/FontProfile.vala \
			src/FooterDrawingBox.vala \
			src/InReplyDrawingBox.vala \
			src/MainWindow.vala \
			src/NameDrawingBox.vala \
			src/OAuth.vala \
			src/PostPage.vala \
			src/RetweetDrawingBox.vala \
			src/SettingsWindow.vala \
			src/SignalPipe.vala \
			src/TextDrawingBox.vala \
			src/TLNode.vala \
			src/TLPage.vala \
			src/TweetNode.vala \
			src/utils/DateTimeUtils.vala \
			src/utils/FileUtils.vala \
			src/utils/ImageUtils.vala \
			src/utils/JsonUtils.vala \
			src/utils/SqliteUtils.vala \
			src/utils/StringUtils.vala \
			src/utils/TwitterUtils.vala \
			src/utils/UriUtils.vala \
			resource.c

OBJECT = \
				Account.vala.o \
				AccountSettingsPage.vala.o \
				Capricorn.vala.o \
				Config.vala.o \
				DisplaySettingsPage.vala.o \
				DrawingBox.vala.o \
				FontProfile.vala.o \
				FooterDrawingBox.vala.o \
				InReplyDrawingBox.vala.o \
				MainWindow.vala.o \
				NameDrawingBox.vala.o \
				OAuth.vala.o \
				PostPage.vala.o \
				RetweetDrawingBox.vala.o \
				SettingsWindow.vala.o \
				SignalPipe.vala.o \
				TextDrawingBox.vala.o \
				TLNode.vala.o \
				TLPage.vala.o \
				TweetNode.vala.o \
				DateTimeUtils.vala.o \
				FileUtils.vala.o \
				ImageUtils.vala.o \
				JsonUtils.vala.o \
				SqliteUtils.vala.o \
				StringUtils.vala.o \
				TwitterUtils.vala.o \
				UriUtils.vala.o \
				resource.o


UI = \
		 ui/account_settings_page.ui \
		 ui/display_settings_page.ui \
		 ui/drawing_box.ui \
		 ui/main_window.ui \
		 ui/oauth_window.ui \
		 ui/post_page.ui \
		 ui/settings_window.ui \
		 ui/tl_page.ui \
		 ui/tweet_node.ui

PKG = \
			--pkg cairo \
			--pkg gdk-3.0 \
			--pkg gmodule-2.0 \
			--pkg gtk+-3.0 \
			--pkg json-glib-1.0 \
			--pkg pango \
			--pkg rest-0.7 \
			--pkg libsoup-2.4 \
			--pkg sqlite3 

all:main.vala libcpr.a resource.c
	@$(VALAC) \
	$(PKG) \
	-X -L. \
	-X -lcpr \
	main.vala \
	a.vapi \
	resource.c \
	-o capricorn

main.vala:src/main.vala
	@cp src/main.vala ./

libcpr.a:$(OBJECT)
	@ar rcsv libcpr.a $(OBJECT)

$(OBJECT):$(SRC) gresources.xml
	@$(VALAC) \
	$(PKG) \
	--target-glib=2.38 \
	--gresources gresources.xml \
	-H mainwindow.h --internal-header=internal.h --internal-vapi=a.vapi \
	-c $(SRC)

resource.c:gresources.xml $(UI)
	@glib-compile-resources \
	gresources.xml \
	--target=resource.c \
	--generate-source

clean:
	@rm *.c *.o *.h *.a *.vapi *.vala src/*.c src/utils/*.c
