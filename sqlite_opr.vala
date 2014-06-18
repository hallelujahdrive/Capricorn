using Rest;
using Sqlite;

using AccountInfo;
using Twitter;
namespace SqliteOpr{
  //文字列定数.てかsql文の雛形
  private const string CREATE_TABLE_ACCOUNT_QUERY="""
  CREATE TABLE ACCOUNT(
  id  INT PRIMARY KEY NOT NULL,
  token_key TEXT  NOT NULL,
  token_secret  TEXT  NOT NULL
  );""";
  private const string INSERT_ACCOUNT_QUERY="INSERT INTO ACCOUNT VALUES($ID,$TOKEN,$TOKEN_SECRET);";
  private const string SELECT_FROM_ACCOUNT="SELECT * FROM ACCOUNT WHERE id=$ID;";
  private const string DELETE_FROM_ACCOUNT="DELETE FROM ACCOUNT WHERE name=$NAME;";
  private const string GET_ID="SELECT id FROM ACCOUNT WHERE name=$NAME;";
  
  public bool create_tables(Sqlite.Database db){ //テーブルの作成
    //テーブルが存在するか
    bool no_table=true;
    
    //コールバック
    int ec;
    string errmsg;
    
    //sql文のquery
    string query;
    
    query="SELECT * FROM SQLITE_MASTER WHERE TYPE='table'";
    //sql文の実行.tableが存在しない場合コールバックしないのでfalse代入のみでok
    ec=db.exec(query,(n_columns,values,column_names)=>{
      no_table=false;
      return 0;
    },out errmsg);
    //エラー処理
    if(ec!=Sqlite.OK){
      print("Sqlite error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //tableが存在しなければ作る
    if(no_table){
      query=CREATE_TABLE_ACCOUNT_QUERY;
      ec=db.exec(query,null,out errmsg);
      //エラー処理
      if(ec!=Sqlite.OK){
        print("Sqlite error:%s\n",errmsg);
      }
    }
    //tableの有無を返す
    return no_table;
  }

  //テーブル内のレコード数のカウント
  public int record_count(Sqlite.Database db,string table_name){
    int ec;
    string errmsg;
    
    int records=0;
    
    GLib.StringBuilder query_sb=new GLib.StringBuilder("SELECT COUNT(*) FROM ");
    query_sb.append(table_name);
    query_sb.append(";");
    
    ec=db.exec(query_sb.str,(n_columns,values,column_names)=>{
      records=int.parse(values[0]);
      return 0;
    },out errmsg);
    if(ec!=Sqlite.OK){
      print("Error:%s\n",errmsg);
    }
    return records;
  }
  
  //アカウント情報のインサート
  public void insert_account(Account account,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_ACCOUNT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int token_param_position=stmt.bind_parameter_index("$TOKEN");
    int token_secret_param_position=stmt.bind_parameter_index("$TOKEN_SECRET");
    
    //インサート
    stmt.bind_int(id_param_position,account.my_id);
    stmt.bind_text(token_param_position,account.api_proxy.get_token());
    stmt.bind_text(token_secret_param_position,account.api_proxy.get_token_secret());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //accountの読み出し
  public void select_account(int id,Account account,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=SELECT_FROM_ACCOUNT;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    stmt.bind_int(id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=0;i<cols;i++){
        switch(i){
          case 0:account.my_id=stmt.column_int(i);
          break;
          case 1:account.api_proxy.set_token(stmt.column_text(i));
          break;
          case 2:account.api_proxy.set_token_secret(stmt.column_text(i));
          break;
        }
      }
    }
    account.stream_proxy.set_token(account.api_proxy.get_token());
    account.stream_proxy.set_token_secret(account.api_proxy.get_token_secret());
    
    stmt.reset();
  }
  public void delete_account(string my_screen_name,Sqlite.Database cpr_db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=DELETE_FROM_ACCOUNT;
    ec=cpr_db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",cpr_db.errcode(),cpr_db.errmsg());
    }
    //パラメータの設定
    int name_param_position=stmt.bind_parameter_index("$NAME");
    
    stmt.bind_text(name_param_position,my_screen_name);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();  
  }
}
