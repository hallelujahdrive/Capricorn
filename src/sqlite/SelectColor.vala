using Sqlite;

namespace SqliteUtil{
  //colorの読み出し
  public void select_color(int id,ColorProfile color_profile,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_COLOR_QUERY;
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
          case 1:color_profile.default_bg_rgba.parse(stmt.column_text(i));
          break;
          case 2:color_profile.reply_bg_rgba.parse(stmt.column_text(i));
          break;
          case 3:color_profile.retweet_bg_rgba.parse(stmt.column_text(i));
          break;
          case 4:color_profile.mine_bg_rgba.parse(stmt.column_text(i));
          break;
        }
      }
    }
    
    stmt.reset();
  }
}
