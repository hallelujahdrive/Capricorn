using Sqlite;

namespace SqliteUtil{
  //node_countのselect
  public void select_time_line_settings(out int init_time_line_node_count,out int time_line_node_count,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_TIME_LINE_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:init_time_line_node_count=stmt.column_int(i);
          break;
          case 1:time_line_node_count=stmt.column_int(i);
          break;
        }
      }
    }
    stmt.reset();
  }
}
