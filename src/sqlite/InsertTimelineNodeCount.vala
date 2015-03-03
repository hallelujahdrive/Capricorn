using Sqlite;

namespace SqliteUtil{
  //get_timeline_nodesのinsert
  public void insert_timeline_node_count(int get_tweet_nodes,int tweet_node_max,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=insert_timeline_node_count_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int get_tweet_nodes_param_position=stmt.bind_parameter_index("$GET_TWEET_NODES");
    int tweet_node_max_param_position=stmt.bind_parameter_index("$TWEET_NODE_MAX");
    
    //インサート
    stmt.bind_int(get_tweet_nodes_param_position,get_tweet_nodes);
    stmt.bind_int(tweet_node_max_param_position,tweet_node_max);

    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //timeline_nodesのselect
  public void select_timeline_nodes(ref int get_tweet_nodes,ref int tweet_node_max,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_TIMELINE_NODES_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:get_tweet_nodes=stmt.column_int(i);
          break;
          case 1:tweet_node_max=stmt.column_int(i);
          break;
        }
      }
    }
    stmt.reset();
  }
}
