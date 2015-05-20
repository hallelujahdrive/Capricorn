using Sqlite;

namespace SqliteUtil{
  //timelineの設定のinsert
  public void insert_time_line_settings(int init_time_line_node_count,int time_line_node_count,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_TIME_LINE_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int init_time_line_node_count_param_position=stmt.bind_parameter_index("$INIT_TIME_LINE_NODE_COUNT");
    int time_line_node_count_param_position=stmt.bind_parameter_index("$TIME_LINE_NODE_COUNT");
    
    //インサート
    stmt.bind_int(init_time_line_node_count_param_position,init_time_line_node_count);
    stmt.bind_int(time_line_node_count_param_position,time_line_node_count);

    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
