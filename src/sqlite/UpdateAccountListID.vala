using Sqlite;

namespace SqliteUtil{
  //list_idの更新
  public void updateaccount_list_id(int new_list_id,int old_list_id,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=UPDATE_ACCOUNT_ID_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int new_list_id_param_position=stmt.bind_parameter_index("$NEW_LIST_ID");
    stmt.bind_int(new_list_id_param_position,new_list_id);
    int old_list_id_param_position=stmt.bind_parameter_index("$OLD_LIST_ID");
    stmt.bind_int(old_list_id_param_position,old_list_id);
       
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
