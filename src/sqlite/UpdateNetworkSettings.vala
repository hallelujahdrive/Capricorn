using Soup;
using Sqlite;

namespace SqliteUtil{
  //network設定の更新
  public void update_network_settings(Config config){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_NETWORK_SETTINGS_QUERY;
    ec=config.db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    //パラメータの設定
    int use_proxy_param_position=stmt.bind_parameter_index("$USE_PROXY");
    int proxy_uri_param_position=stmt.bind_parameter_index("$PROXY_URI");
    int proxy_password_param_position=stmt.bind_parameter_index("$PROXY_PASSWORD");
    
    //パラメータのbind
    stmt.bind_int(use_proxy_param_position,config.use_proxy);
    stmt.bind_text(proxy_uri_param_position,config.proxy_uri==null?null:config.proxy_uri.to_string(false));
    stmt.bind_text(proxy_password_param_position,config.proxy_uri==null?null:config.proxy_uri.get_password());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
