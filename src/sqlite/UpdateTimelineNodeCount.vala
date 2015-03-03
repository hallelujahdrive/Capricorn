using Sqlite;

namespace SqliteUtil{
  //timeline_nodesの更新
  public void update_timeline_node_count(int get_tweet_nodes,int tweet_node_max,Database db){
        int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=update_timeline_node_count_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int get_tweet_nodes_param_position=stmt.bind_parameter_index("$GET_TWEET_NODES");
    int tweet_node_max_param_position=stmt.bind_parameter_index("$TWEET_NODE_MAX");
    
    //インサート
    stmt.bind_int(get_tweet_nodes_param_position,get_tweet_nodes);
    stmt.bind_int(tweet_node_max_param_position,tweet_node_max);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
