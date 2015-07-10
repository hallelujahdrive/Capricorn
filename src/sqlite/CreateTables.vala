using Sqlite;

namespace SqliteUtil{
  //テーブルの作成
  public bool create_tables(Database db){
    //テーブルが作成されたか
    bool res=true;
    
    //コールバック
    int ec;
    string errmsg;
    
    //sql文のquery
    string query;
    
    query=SELECT_FROM_SQLITE_MASTER;
    //sql文の実行.tableが存在しない場合コールバックしないのでfalseの代入のみでok
    ec=db.exec(query,(n_columns,values,column_names)=>{
      res=false;
      return 0;
    },out errmsg);
    //エラー処理
    if(ec!=Sqlite.OK){
      print("Sqlite error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //tableが存在しなければ作る
    if(res){
      for(int i=0;i<7;i++){
        switch(i){
          case 0:query=CREATE_TABLE_ACCOUNT_QUERY;
          break;
          case 1:query=CREATE_TABLE_COLOR_QUERY;
          break;
          case 2:query=CREATE_TABLE_EVENT_NOTIFY_SETTINGS;
          break;
          case 3:query=CREATE_TABLE_FONT_QUERY;
          break;
          case 4:query=CREATE_TABLE_NETWORK_SETTINGS_QUERY;
          break;
          case 5:query=CREATE_TABLE_POSITIONS_QUERY;
          break;
          case 6:query=CREATE_TABLE_TIME_LINE_SETTINGS_QUERY;
          break;
        }
        ec=db.exec(query,null,out errmsg);
        //エラー処理
        if(ec!=Sqlite.OK){
          print("Sqlite error:%s\n",errmsg);
        }
      }
    }
    //tableを作成したかどうかを返す
    return res;
  }
}
