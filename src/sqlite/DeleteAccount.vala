using Sqlite;

namespace SqliteUtil{
  //アカウントの削除
  public void deleteaccount(int list_id,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=DELETE_FROM_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    
    stmt.bind_int(list_id_param_position,list_id);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();  
  }
}
