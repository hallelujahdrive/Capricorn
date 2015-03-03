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
    
    query="SELECT * FROM SQLITE_MASTER WHERE TYPE='table'";
    //sql文の実行.tableが存在しない場合コールバックしないのでtrueの代入のみでok
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
      for(int i=0;i<4;i++){
        switch(i){
          case 0:query=CREATE_TABLE_ACCOUNT_QUERY;
          break;
          case 1:query=CREATE_TABLE_COLOR_QUERY;
          break;
          case 2:query=CREATE_TABLE_FONT_QUERY;
          break;
          case 3:query=CREATE_TABLE_TIMELINE_NODES_QUERY;
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
