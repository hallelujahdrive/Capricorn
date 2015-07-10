using Sqlite;

namespace SqliteUtil{
  //timeline_nodesの更新
  public void update_event_notify_settings(int event_node_count,bool event_show_on_timeline,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_EVENT_NOTIFY_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int event_node_count_param_position=stmt.bind_parameter_index("$EVENT_NODE_COUNT");
    int event_show_on_timeline_param_position=stmt.bind_parameter_index("$EVENT_SHOW_ON_TIME_LINE");
    
    //インサート
    stmt.bind_int(event_node_count_param_position,event_node_count);
    stmt.bind_text(event_show_on_timeline_param_position,event_show_on_timeline.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
