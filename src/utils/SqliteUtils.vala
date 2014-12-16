using Gdk;
using Pango;
using Sqlite;

namespace SqliteUtils{
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
  private const string CREATE_TABLE_TIMELINE_NODES_QUERY="""
  CREATE TABLE TIMELINE_NODES(
  get_tweet_nodes INT NOT NULL,
  tweet_node_max INT NOT NULL
  );""";
  private const string INSERT_ACCOUNT_QUERY="INSERT INTO ACCOUNT VALUES($LIST_ID,$ID,$TOKEN,$TOKEN_SECRET);";
  private const string INSERT_COLOR_QUERY="INSERT INTO COLOR VALUES($ID,$DEFAULT_BG,$REPLY_BG,$RETWEET_BG,$MINE_BG);";
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
  private const string INSERT_TIMELINE_NODES_QUERY="INSERT INTO TIMELINE_NODES VALUES($GET_TWEET_NODES,$TWEET_NODE_MAX);";
  private const string SELECT_FROM_ACCOUNT_QUERY="SELECT * FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string SELECT_FROM_COLOR_QUERY="SELECT * FROM COLOR WHERE id=$ID;";
  private const string SELECT_FROM_FONT_QUERY="SELECT * FROM FONT WHERE id=$ID;";
  private const string SELECT_FROM_TIMELINE_NODES_QUERY="SELECT * FROM TIMELINE_NODES;";
  private const string DELETE_FROM_ACCOUNT_QUERY="DELETE FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string UPDATE_ACCOUNT_ID_QUERY="UPDATE ACCOUNT SET list_id=$NEW_LIST_ID WHERE list_id=$OLD_LIST_ID;";
  private const string UPDATE_COLOR_QUERY="UPDATE COLOR SET default_bg=$DEFAULT_BG,reply_bg=$REPLY_BG,retweet_bg=$RETWEET_BG,mine_bg=$MINE_BG WHERE id=$ID;";
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
  private const string UPDATE_TIMELINE_NODES_QUERY="UPDATE TIMELINE_NODES SET get_tweet_nodes=$GET_TWEET_NODES,tweet_node_max=$TWEET_NODE_MAX;";
  private const string SELECT_ID_FORM_ACCOUNT_QUERY="SELECT id FROM ACCOUNT WHERE list_id=$LIST_ID;";
 
  //テーブルの作成
  public bool create_tables(Database db){
    //テーブルが作成されたか
    bool res=true;
    
    //コールバック
    int ec;
    string errmsg;
    
    //sql文のquery
    string query;
    
    query="SELECT * FROM SQLITE_MASTER WHERE TYPE='table'";
    //sql文の実行.tableが存在しない場合コールバックしないのでtrueの代入のみでok
    ec=db.exec(query,(n_columns,values,column_names)=>{
      res=false;
      return 0;
    },out errmsg);
    //エラー処理
    if(ec!=Sqlite.OK){
      print("Sqlite error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //tableが存在しなければ作る
    if(res){
      for(int i=0;i<4;i++){
        switch(i){
          case 0:query=CREATE_TABLE_ACCOUNT_QUERY;
          break;
          case 1:query=CREATE_TABLE_COLOR_QUERY;
          break;
          case 2:query=CREATE_TABLE_FONT_QUERY;
          break;
          case 3:query=CREATE_TABLE_TIMELINE_NODES_QUERY;
          break;
        }
        ec=db.exec(query,null,out errmsg);
        //エラー処理
        if(ec!=Sqlite.OK){
          print("Sqlite error:%s\n",errmsg);
        }
      }
    }
    //tableを作成したかどうかを返す
    return res;
  }

  //テーブル内のレコード数のカウント
  public int record_count(Sqlite.Database db,string table_name){
    int ec;
    string errmsg;
    
    //戻り値
    int records=0;
    
    StringBuilder query_sb=new StringBuilder("SELECT COUNT(*) FROM ");
    query_sb.append(table_name);
    query_sb.append(";");
    
    ec=db.exec(query_sb.str,(n_columns,values,column_names)=>{
      records=int.parse(values[0]);
      return 0;
    },out errmsg);
    if(ec!=Sqlite.OK){
      print("Error:%s\n",errmsg);
    }
    return records;
  }
  
  //アカウント情報のインサート
  public void insert_account(Account account,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=INSERT_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    int id_param_position=stmt.bind_parameter_index("$ID");
    int token_param_position=stmt.bind_parameter_index("$TOKEN");
    int token_secret_param_position=stmt.bind_parameter_index("$TOKEN_SECRET");
    
    //インサート
    stmt.bind_int(list_id_param_position,account.my_list_id);
    stmt.bind_int(id_param_position,account.my_id);
    stmt.bind_text(token_param_position,account.api_proxy.get_token());
    stmt.bind_text(token_secret_param_position,account.api_proxy.get_token_secret());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //colorのinsert
  public void insert_color(int id,Config config){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_COLOR_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int default_bg_param_position=stmt.bind_parameter_index("$DEFAULT_BG");
    int reply_bg_param_position=stmt.bind_parameter_index("$REPLY_BG");
    int retweet_bg_param_position=stmt.bind_parameter_index("$RETWEET_BG");
    int mine_bg_param_position=stmt.bind_parameter_index("$MINE_BG");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(default_bg_param_position,config.default_bg_rgba.to_string());
    stmt.bind_text(reply_bg_param_position,config.reply_bg_rgba.to_string());
    stmt.bind_text(retweet_bg_param_position,config.retweet_bg_rgba.to_string());
    stmt.bind_text(mine_bg_param_position,config.mine_bg_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //fontのinsert
  public void insert_font(int id,FontProfile font_profile,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_FONT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    int use_default_param_position=stmt.bind_parameter_index("$USE_DEFAULT");
    int name_fd_param_position=stmt.bind_parameter_index("$NAME_FD");
    int name_fr_param_position=stmt.bind_parameter_index("$NAME_FR");
    int text_fd_param_position=stmt.bind_parameter_index("$TEXT_FD");
    int text_fr_param_position=stmt.bind_parameter_index("$TEXT_FR");
    int footer_fd_param_position=stmt.bind_parameter_index("$FOOTER_FD");
    int footer_fr_param_position=stmt.bind_parameter_index("$FOOTER_FR");
    int in_reply_fd_param_position=stmt.bind_parameter_index("$IN_REPLY_FD");
    int in_reply_fr_param_position=stmt.bind_parameter_index("$IN_REPLY_FR");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(use_default_param_position,font_profile.use_default.to_string());
    stmt.bind_text(use_default_param_position,font_profile.use_default.to_string());
    stmt.bind_text(name_fd_param_position,font_profile.name_font_desc.to_string());
    stmt.bind_text(name_fr_param_position,font_profile.name_font_rgba.to_string());
    stmt.bind_text(text_fd_param_position,font_profile.text_font_desc.to_string());
    stmt.bind_text(text_fr_param_position,font_profile.text_font_rgba.to_string());
    stmt.bind_text(footer_fd_param_position,font_profile.footer_font_desc.to_string());
    stmt.bind_text(footer_fr_param_position,font_profile.footer_font_rgba.to_string());
    stmt.bind_text(in_reply_fd_param_position,font_profile.in_reply_font_desc.to_string());
    stmt.bind_text(in_reply_fr_param_position,font_profile.in_reply_font_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //timeline_nodesのinsert
  public void insert_timeline_nodes(int get_tweet_nodes,int tweet_node_max,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_TIMELINE_NODES_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int get_tweet_nodes_param_position=stmt.bind_parameter_index("$GET_TWEET_NODES");
    int tweet_node_max_param_position=stmt.bind_parameter_index("$TWEET_NODE_MAX");
    
    //インサート
    stmt.bind_int(get_tweet_nodes_param_position,get_tweet_nodes);
    stmt.bind_int(tweet_node_max_param_position,tweet_node_max);

    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //accountの読み出し
  public void select_account(int id,Account account,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    stmt.bind_int(list_id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:account.my_list_id=stmt.column_int(i);
          break;
          case 1:account.my_id=stmt.column_int(i);
          break;
          case 2:account.api_proxy.set_token(stmt.column_text(i));
          break;
          case 3:account.api_proxy.set_token_secret(stmt.column_text(i));
          break;
        }
      }
    }
    account.stream_proxy.set_token(account.api_proxy.get_token());
    account.stream_proxy.set_token_secret(account.api_proxy.get_token_secret());
    
    stmt.reset();
  }
  
  //colorの読み出し
  public void select_color(int id,Config config){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_COLOR_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    stmt.bind_int(id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=1;i<cols;i++){
        switch(i){
          case 1:config.default_bg_rgba.parse(stmt.column_text(i));
          break;
          case 2:config.reply_bg_rgba.parse(stmt.column_text(i));
          break;
          case 3:config.retweet_bg_rgba.parse(stmt.column_text(i));
          break;
          case 4:config.mine_bg_rgba.parse(stmt.column_text(i));
          break;
        }
      }
    }
    
    stmt.reset();
  }
  
  //fontの読み出し
  public void select_font(int id,FontProfile font_profile,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_FONT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    stmt.bind_int(id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=1;i<cols;i++){
        switch(i){
          case 1:font_profile.use_default=bool.parse(stmt.column_text(i));
          break;
          case 2:font_profile.name_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 3:font_profile.name_font_rgba.parse(stmt.column_text(i));
          break;
          case 4:font_profile.text_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 5:font_profile.text_font_rgba.parse(stmt.column_text(i));
          break;
          case 6:font_profile.footer_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 7:font_profile.footer_font_rgba.parse(stmt.column_text(i));
          break;
          case 8:font_profile.in_reply_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 9:font_profile.in_reply_font_rgba.parse(stmt.column_text(i));
          break;
        }
      }
    }
    
    stmt.reset();
  }
  
  //timeline_nodesのselect
  public void select_timeline_nodes(ref int get_tweet_nodes,ref int tweet_node_max,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_TIMELINE_NODES_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:get_tweet_nodes=stmt.column_int(i);
          break;
          case 1:tweet_node_max=stmt.column_int(i);
          break;
        }
      }
    }
    stmt.reset();
  }
  
  //アカウントの削除
  public void delete_account(int list_id,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=DELETE_FROM_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    
    stmt.bind_int(list_id_param_position,list_id);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();  
  }
  
  //list_idの更新
  public void update_account_list_id(int new_list_id,int old_list_id,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=UPDATE_ACCOUNT_ID_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int new_list_id_param_position=stmt.bind_parameter_index("$NEW_LIST_ID");
    stmt.bind_int(new_list_id_param_position,new_list_id);
    int old_list_id_param_position=stmt.bind_parameter_index("$OLD_LIST_ID");
    stmt.bind_int(old_list_id_param_position,old_list_id);
       
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //colorの更新
  public void update_color(int id,Config config){
    int ec;
    Statement stmt;
    
    string prepared_query_str=UPDATE_COLOR_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int default_bg_param_position=stmt.bind_parameter_index("$DEFAULT_BG");
    int reply_bg_param_position=stmt.bind_parameter_index("$REPLY_BG");
    int retweet_bg_param_position=stmt.bind_parameter_index("$RETWEET_BG");
    int mine_bg_param_position=stmt.bind_parameter_index("$MINE_BG");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(default_bg_param_position,config.default_bg_rgba.to_string());
    stmt.bind_text(reply_bg_param_position,config.reply_bg_rgba.to_string());
    stmt.bind_text(retweet_bg_param_position,config.retweet_bg_rgba.to_string());
    stmt.bind_text(mine_bg_param_position,config.mine_bg_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //fontの更新
  public void update_font(int id,FontProfile font_profile,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_FONT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int use_default_param_position=stmt.bind_parameter_index("$USE_DEFAULT");
    int name_fd_param_position=stmt.bind_parameter_index("$NAME_FD");
    int name_fr_param_position=stmt.bind_parameter_index("$NAME_FR");
    int text_fd_param_position=stmt.bind_parameter_index("$TEXT_FD");
    int text_fr_param_position=stmt.bind_parameter_index("$TEXT_FR");
    int footer_fd_param_position=stmt.bind_parameter_index("$FOOTER_FD");
    int footer_fr_param_position=stmt.bind_parameter_index("$FOOTER_FR");
    int in_reply_fd_param_position=stmt.bind_parameter_index("$IN_REPLY_FD");
    int in_reply_fr_param_position=stmt.bind_parameter_index("$IN_REPLY_FR");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(use_default_param_position,font_profile.use_default.to_string());
    stmt.bind_text(name_fd_param_position,font_profile.name_font_desc.to_string());
    stmt.bind_text(name_fr_param_position,font_profile.name_font_rgba.to_string());
    stmt.bind_text(text_fd_param_position,font_profile.text_font_desc.to_string());
    stmt.bind_text(text_fr_param_position,font_profile.text_font_rgba.to_string());
    stmt.bind_text(footer_fd_param_position,font_profile.footer_font_desc.to_string());
    stmt.bind_text(footer_fr_param_position,font_profile.footer_font_rgba.to_string());
    stmt.bind_text(in_reply_fd_param_position,font_profile.in_reply_font_desc.to_string());
    stmt.bind_text(in_reply_fr_param_position,font_profile.in_reply_font_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //timeline_nodesの更新
  public void update_timeline_nodes(int get_tweet_nodes,int tweet_node_max,Database db){
        int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_TIMELINE_NODES_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int get_tweet_nodes_param_position=stmt.bind_parameter_index("$GET_TWEET_NODES");
    int tweet_node_max_param_position=stmt.bind_parameter_index("$TWEET_NODE_MAX");
    
    //インサート
    stmt.bind_int(get_tweet_nodes_param_position,get_tweet_nodes);
    stmt.bind_int(tweet_node_max_param_position,tweet_node_max);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }

  
  //list_idからidを取得する
  public int get_id(int my_list_id,Database cpr_db){
    int ec;
    int? id=null;
    Statement stmt;
    string prepared_query_str=SELECT_ID_FORM_ACCOUNT_QUERY;
    ec=cpr_db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",cpr_db.errcode(),cpr_db.errmsg());
    }
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    stmt.bind_int(list_id_param_position,my_list_id);
    while(stmt.step()==Sqlite.ROW){
      id=stmt.column_int(0);
    }
    stmt.reset();
    return id;
  }
}
