using Sqlite;

namespace SqliteUtil{
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
}
