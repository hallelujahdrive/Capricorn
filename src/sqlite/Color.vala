using Gdk;
using Sqlite;

namespace SqliteUtils{
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
}
