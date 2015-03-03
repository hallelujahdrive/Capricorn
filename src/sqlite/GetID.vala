using Sqlite;

namespace SqliteUtil{
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
