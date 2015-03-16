namespace SqliteUtil{
  //文字列定数.てかsql文の雛形
  private const string CREATE_TABLE_ACCOUNT_QUERY="""
  CREATE TABLE ACCOUNT(
  list_id INT PRIMARY KEY NOT NULL,
  id  INT NOT NULL,
  token_key TEXT  NOT NULL,
  token_secret  TEXT  NOT NULL
  );""";
  private const string CREATE_TABLE_COLOR_QUERY="""
  CREATE TABLE COLOR(
  id  INT PRIMARY KEY NOT NULL,
  default_bg  TEXT NOT NULL,
  reply_bg TEXT NOT NULL,
  retweet_bg TEXT NOT NULL,
  mine_bg TEXT NOT NULL
  );""";
  private const string CREATE_TABLE_EVENT_NOTIFY_SETTINGS="""
  CREATE TABLE EVENT_NOTIFY_SETTINGS(
  event_node_count INT PRIMARY KEY NOT NULL,
  event_show_on_time_line TEXT NOT NULL
  );""";
  private const string CREATE_TABLE_FONT_QUERY="""
  CREATE TABLE FONT(
  id INT PRIMARY KEY NOT NULL,
  use_default TEXT NOT NULL,
  name_font_desc TEXT NOT NULL,
  name_font_rgba TEXT NOT NULL,
  text_font_desc TEXT NOT NULL,
  text_font_rgba TEXT NOT NULL,
  footer_font_desc TEXT NOT NULL,
  footer_font_rgba TEXT NOT NULL,
  in_reply_font_desc TEXT NOT NULL,
  in_reply_font_rgba TEXT NOT NULL
  );""";
  private const string CREATE_TABLE_TIME_LINE_SETTINGS_QUERY="""
  CREATE TABLE TIME_LINE_SETTINGS(
  init_time_line_node_count INT NOT NULL,
  time_line_node_count INT NOT NULL
  );""";
  private const string INSERT_ACCOUNT_QUERY="INSERT INTO ACCOUNT VALUES($LIST_ID,$ID,$TOKEN,$TOKEN_SECRET);";
  private const string INSERT_COLOR_QUERY="INSERT INTO COLOR VALUES($ID,$DEFAULT_BG,$REPLY_BG,$RETWEET_BG,$MINE_BG);";
  private const string INSERT_EVENT_NOTIFY_SETTINGS_QUERY="INSERT INTO EVENT_NOTIFY_SETTINGS VALUES($EVENT_NODE_COUNT,$EVENT_SHOW_ON_TIME_LINE);";
  private const string INSERT_FONT_QUERY="""
  INSERT INTO FONT VALUES(
  $ID,
  $USE_DEFAULT,
  $NAME_FD,
  $NAME_FR,
  $TEXT_FD,
  $TEXT_FR,
  $FOOTER_FD,
  $FOOTER_FR,
  $IN_REPLY_FD,
  $IN_REPLY_FR
  );""";
  private const string INSERT_TIME_LINE_SETTINGS_QUERY="INSERT INTO TIME_LINE_SETTINGS VALUES($INIT_TIME_LINE_NODE_COUNT,$TIME_LINE_NODE_COUNT);";
  private const string SELECT_FROM_ACCOUNT_QUERY="SELECT * FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string SELECT_FROM_COLOR_QUERY="SELECT * FROM COLOR WHERE id=$ID;";
  private const string SELECT_FROM_EVENT_NOTIFY_SETTINGS_QUERY="SELECT * FROM EVENT_NOTIFY_SETTINGS;";
  private const string SELECT_FROM_FONT_QUERY="SELECT * FROM FONT WHERE id=$ID;";
  private const string SELECT_FROM_TIME_LINE_SETTINGS_QUERY="SELECT * FROM TIME_LINE_SETTINGS;";
  private const string DELETE_FROM_ACCOUNT_QUERY="DELETE FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string UPDATE_ACCOUNT_ID_QUERY="UPDATE ACCOUNT SET list_id=$NEW_LIST_ID WHERE list_id=$OLD_LIST_ID;";
  private const string UPDATE_COLOR_QUERY="UPDATE COLOR SET default_bg=$DEFAULT_BG,reply_bg=$REPLY_BG,retweet_bg=$RETWEET_BG,mine_bg=$MINE_BG WHERE id=$ID;";
  private const string UPDATE_EVENT_NOTIFY_SETTINGS_QUERY="UPDATE EVENT_NOTIFY_SETTINGS SET event_node_count=$EVENT_NODE_COUNT,event_show_on_time_line=$EVENT_SHOW_ON_TIME_LINE;";
  private const string UPDATE_FONT_QUERY="""
  UPDATE FONT SET 
  use_default=$USE_DEFAULT,
  name_font_desc=$NAME_FD,
  name_font_rgba=$NAME_FR,
  text_font_desc=$TEXT_FD,
  text_font_rgba=$TEXT_FR,
  footer_font_desc=$FOOTER_FD,
  footer_font_rgba=$FOOTER_FR,
  in_reply_font_desc=$IN_REPLY_FD,
  in_reply_font_rgba=$IN_REPLY_FR 
  WHERE id=$ID;
  """;
  private const string UPDATE_TIMELINE_TIME_LINE_SETTINGS_QUERY="UPDATE TIME_LINE_SETTINGS SET init_time_line_node_count=$INIT_TIME_LINE_NODE_COUNT,time_line_node_count=$TIME_LINE_NODE_COUNT;";
  private const string SELECT_ID_FORM_ACCOUNT_QUERY="SELECT id FROM ACCOUNT WHERE list_id=$LIST_ID;";
}
