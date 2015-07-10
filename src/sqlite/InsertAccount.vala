using Ruribitaki;
using Sqlite;

namespace SqliteUtil{
  //accountのinsert
  public void insert_account(int list_id,Account account,position home_pos,position mention_pos,Database db){
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
    int home_column_pos_param_position=stmt.bind_parameter_index("$HOME_COLUMN_POS");
    int home_tab_pos_param_position=stmt.bind_parameter_index("$HOME_TAB_POS");
    int mention_column_pos_param_position=stmt.bind_parameter_index("$MENTION_COLUMN_POS");
    int mention_tab_pos_param_position=stmt.bind_parameter_index("$MENTION_TAB_POS");
    
    //インサート
    stmt.bind_int(list_id_param_position,list_id);
    stmt.bind_int64(id_param_position,account.id);
    stmt.bind_text(token_param_position,account.api_proxy.get_token());
    stmt.bind_text(token_secret_param_position,account.api_proxy.get_token_secret());
    stmt.bind_int(home_column_pos_param_position,home_pos.column);
    stmt.bind_int(home_tab_pos_param_position,home_pos.tab);
    stmt.bind_int(mention_column_pos_param_position,mention_pos.column);
    stmt.bind_int(mention_tab_pos_param_position,mention_pos.tab);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
