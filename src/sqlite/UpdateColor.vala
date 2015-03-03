using Sqlite;

namespace SqliteUtil{
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
