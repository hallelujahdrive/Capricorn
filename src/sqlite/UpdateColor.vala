using Sqlite;

namespace SqliteUtil{
  //colorの更新
  public void update_color(int id,ColorProfile color_profile,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=UPDATE_COLOR_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int default_bg_param_position=stmt.bind_parameter_index("$DEFAULT_BG");
    int reply_bg_param_position=stmt.bind_parameter_index("$REPLY_BG");
    int retweet_bg_param_position=stmt.bind_parameter_index("$RETWEET_BG");
    int mine_bg_param_position=stmt.bind_parameter_index("$MINE_BG");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(default_bg_param_position,color_profile.default_bg_rgba.to_string());
    stmt.bind_text(reply_bg_param_position,color_profile.reply_bg_rgba.to_string());
    stmt.bind_text(retweet_bg_param_position,color_profile.retweet_bg_rgba.to_string());
    stmt.bind_text(mine_bg_param_position,color_profile.mine_bg_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
