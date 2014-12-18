using Sqlite;

namespace SqliteUtils{
  //アカウント情報のインサート
  public void insert_account(Account account,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=INSERT_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    int id_param_position=stmt.bind_parameter_index("$ID");
    int token_param_position=stmt.bind_parameter_index("$TOKEN");
    int token_secret_param_position=stmt.bind_parameter_index("$TOKEN_SECRET");
    
    //インサート
    stmt.bind_int(list_id_param_position,account.my_list_id);
    stmt.bind_int(id_param_position,account.my_id);
    stmt.bind_text(token_param_position,account.api_proxy.get_token());
    stmt.bind_text(token_secret_param_position,account.api_proxy.get_token_secret());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
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
  
  //アカウントの削除
  public void delete_account(int list_id,Database db){
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
  
  //list_idの更新
  public void update_account_list_id(int new_list_id,int old_list_id,Database db){
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
  
  //list_idからidを取得する
  public int get_id(int my_list_id,Database cpr_db){
    int ec;
    int? id=null;
    Statement stmt;
    string prepared_query_str=SELECT_ID_FORM_ACCOUNT_QUERY;
    ec=cpr_db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",cpr_db.errcode(),cpr_db.errmsg());
    }
    int list_id_param_position=stmt.bind_parameter_index("$LIST_ID");
    stmt.bind_int(list_id_param_position,my_list_id);
    while(stmt.step()==Sqlite.ROW){
      id=stmt.column_int(0);
    }
    stmt.reset();
    return id;
  }
}
