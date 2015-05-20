using Soup;
using Sqlite;

namespace SqliteUtil{
  //network設定の更新
  public void update_network_settings(int use_proxy,URI proxy_uri,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_NETWORK_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int use_proxy_param_position=stmt.bind_parameter_index("$USE_PROXY");
    int proxy_uri_param_position=stmt.bind_parameter_index("$PROXY_URI");
    int proxy_password_param_position=stmt.bind_parameter_index("$PROXY_PASSWORD");
    
    //パラメータのbind
    stmt.bind_int(use_proxy_param_position,use_proxy);
    stmt.bind_text(proxy_uri_param_position,proxy_uri==null?null:proxy_uri.to_string(false));
    stmt.bind_text(proxy_password_param_position,proxy_uri==null?null:proxy_uri.get_password());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
