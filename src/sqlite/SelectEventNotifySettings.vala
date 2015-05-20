using Sqlite;

namespace SqliteUtil{
    //node_countのselect
  public void select_event_notify_settings(out int event_node_count,out bool event_show_on_time_line,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_EVENT_NOTIFY_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:event_node_count=stmt.column_int(i);
          break;
          case 1:event_show_on_time_line=bool.parse(stmt.column_text(i));
          break;
        }
      }
    }
    stmt.reset();
  }
}
