all:
	@valac	\
	--pkg gtk+-3.0 \
	--pkg gdk-3.0 \
	--pkg json-glib-1.0 \
	--pkg rest-0.7 \
	--pkg gmodule-2.0 \
	--pkg pango \
	--pkg cairo \
	--pkg sqlite3 \
	main.vala \
	capricorn.vala	\
	twitter.vala \
	tl_object.vala \
	ui.vala \
	oauth.vala \
	file_opr.vala \
	sqlite_opr.vala \
	contents_obj.vala \
	json_opr.vala \
	-o Capricorn_BETA 
