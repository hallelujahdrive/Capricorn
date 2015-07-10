using Sqlite;

namespace SqliteUtil{
  //timeline_nodesの更新
  public void update_timeline_settings(int init_timeline_node_count,int timeline_node_count,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_TIMELINE_TIME_LINE_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int init_timeline_node_count_param_position=stmt.bind_parameter_index("$INIT_TIME_LINE_NODE_COUNT");
    int timeline_node_count_param_position=stmt.bind_parameter_index("$TIME_LINE_NODE_COUNT");
    
    //インサート
    stmt.bind_int(init_timeline_node_count_param_position,init_timeline_node_count);
    stmt.bind_int(timeline_node_count_param_position,timeline_node_count);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
