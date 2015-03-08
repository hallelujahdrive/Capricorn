using Sqlite;

namespace SqliteUtil{
  //timeline_nodesの更新
  public void update_timeline_node_count(int init_node_count,int tl_node_count,Database db){
        int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_TIMELINE_NODE_COUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int init_node_count_param_position=stmt.bind_parameter_index("$INIT_NODE_COUNT");
    int tl_node_count_param_position=stmt.bind_parameter_index("$TL_NODE_COUNT");
    
    //インサート
    stmt.bind_int(init_node_count_param_position,init_node_count);
    stmt.bind_int(tl_node_count_param_position,tl_node_count);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
