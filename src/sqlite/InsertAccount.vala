using Ruribitaki;
using Sqlite;

namespace SqliteUtil{
  //accountのinsert
  public void insert_account(CapricornAccount cpr_account,Database db){
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
    stmt.bind_int(list_id_param_position,cpr_account.list_id);
    stmt.bind_int64(id_param_position,cpr_account.id);
    stmt.bind_text(token_param_position,cpr_account.api_proxy.get_token());
    stmt.bind_text(token_secret_param_position,cpr_account.api_proxy.get_token_secret());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
