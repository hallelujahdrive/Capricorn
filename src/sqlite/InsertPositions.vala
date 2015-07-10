using Sqlite;

namespace SqliteUtil{
  public void insert_positions(position[] positions,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=INSERT_POSITIONS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    int column_param_position=stmt.bind_parameter_index("$COLUMN");
    int tab_param_position=stmt.bind_parameter_index("$TAB");

    for(int i=0;i<5;i++){
      //インサート
      stmt.bind_int(id_param_position,i);
      stmt.bind_int(column_param_position,positions[i].column);
      stmt.bind_int(tab_param_position,positions[i].tab);
    
      while(stmt.step()!=Sqlite.DONE);
      stmt.reset();
    }
  }
}
