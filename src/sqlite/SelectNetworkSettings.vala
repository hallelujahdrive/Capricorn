using Soup;
using Sqlite;

namespace SqliteUtil{
  //network設定(proxy)のselect
  public void select_network_settings(out int use_proxy,out URI proxy_uri,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_NETWORK_SETTINGS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:use_proxy=stmt.column_int(i);
          break;
          case 1:proxy_uri=new URI(stmt.column_text(i));
          break;
          case 2:proxy_uri.set_password(stmt.column_text(i));
          break;
        }
      }
    }
    stmt.reset();
  }
}
