using Ruribitaki;
using Sqlite;

namespace SqliteUtil{
  //accountの読み出し
  public void select_account(int id,Account account,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    stmt.bind_int(list_id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:account.my_list_id=stmt.column_int(i);
          break;
          case 1:account.my_id=stmt.column_int(i);
          break;
          case 2:account.api_proxy.set_token(stmt.column_text(i));
          break;
          case 3:account.api_proxy.set_token_secret(stmt.column_text(i));
          break;
        }
      }
    }
    account.stream_proxy.set_token(account.api_proxy.get_token());
    account.stream_proxy.set_token_secret(account.api_proxy.get_token_secret());
    
    stmt.reset();
  }
}
