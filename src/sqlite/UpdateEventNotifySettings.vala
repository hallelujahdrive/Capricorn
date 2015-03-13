using Sqlite;

namespace SqliteUtil{
  //timeline_nodesの更新
  public void update_event_notify_settings(Config config){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_EVENT_NOTIFY_SETTINGS_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    //パラメータの設定
    int event_node_count_param_position=stmt.bind_parameter_index("$EVENT_NODE_COUNT");
    
    //インサート
    stmt.bind_int(event_node_count_param_position,config.event_node_count);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
