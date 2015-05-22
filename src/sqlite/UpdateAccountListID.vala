using Sqlite;

namespace SqliteUtil{
  //list_idの更新
  public void update_account_list_id(int list_id,int64 id,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=UPDATE_ACCOUNT_ID_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    int id_param_position=stmt.bind_parameter_index("$ID");

    stmt.bind_int(list_id_param_position,list_id);
    stmt.bind_int64(id_param_position,id);
       
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
