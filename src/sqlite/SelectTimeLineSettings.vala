using Sqlite;

namespace SqliteUtil{
    //node_countのselect
  public void select_time_line_settings(Config config){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_TIME_LINE_SETTINGS_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:config.init_time_line_node_count=stmt.column_int(i);
          break;
          case 1:config.time_line_node_count=stmt.column_int(i);
          break;
        }
      }
    }
    stmt.reset();
  }
}
