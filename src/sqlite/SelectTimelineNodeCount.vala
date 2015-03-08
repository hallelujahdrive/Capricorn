using Sqlite;

namespace SqliteUtil{
    //timeline_nodesのselect
  public void select_timeline_nodes(ref int init_node_count,ref int tl_node_count,Database db){
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
          case 0:init_node_count=stmt.column_int(i);
          break;
          case 1:tl_node_count=stmt.column_int(i);
          break;
        }
      }
    }
    stmt.reset();
  }
}
