using Gdk;
using Rest;
using Sqlite;

using ContentsObj;
using FileOpr;
using Twitter;
namespace SqliteOpr{
  //文字列定数.てかsql文の雛形
  private const string CREATE_TABLE_ACCOUNT_QUERY="""
  CREATE TABLE ACCOUNT(
  list_id INT PRIMARY KEY NOT NULL,
  id  INT NOT NULL,
  token_key TEXT  NOT NULL,
  token_secret  TEXT  NOT NULL
  );""";
  private const string CREATE_TABLE_IMAGE_PATH_QUERY="""
  CREATE TABLE IMAGE_PATH(
  id  INT PRIMARY KEY NOT NULL,
  path  TEXT NOT NULL
  );""";
  private const string CREATE_TABLE_ICON_PATH_QUERY="""
  CREATE TABLE ICON_PATH(
  id  INT PRIMARY KEY NOT NULL,
  path  TEXT NOT NULL
  );""";
  private const string INSERT_ACCOUNT_QUERY="INSERT INTO ACCOUNT VALUES($LIST_ID,$ID,$TOKEN,$TOKEN_SECRET);";
  private const string INSERT_IMAGE_PATH_QUERY="INSERT INTO IMAGE_PATH VALUES($ID,$PATH);";
  private const string INSERT_ICON_PATH_QUERY="INSERT INTO ICON_PATH VALUES($ID,$PATH);";
  private const string SELECT_FROM_ACCOUNT="SELECT * FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string SELECT_FROM_IMAGE_PATH="SELECT * FROM IMAGE_PATH WHERE id=$ID;";
  private const string SELECT_FROM_ICON_PATH="SELECT * FROM ICON_PATH WHERE id=$ID;";
  private const string DELETE_FROM_ACCOUNT="DELETE FROM ACCOUNT WHERE list_id=$LIST_ID;";
  private const string DELETE_ALL_RECORD_FROM_IMAGE_PATH="DELETE FROM IMAGE_PATH";
  private const string DELETE_ALL_RECORD_FROM_ICON_PATH="DELETE FROM ICON_PATH";
  private const string UPDATE_ACCOUNT_ID="UPDATE ACCOUNT SET list_id=$NEW_LIST_ID WHERE list_id=$OLD_LIST_ID;";
  
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
      for(int i=0;i<3;i++){
        switch(i){
          case 0:query=CREATE_TABLE_ACCOUNT_QUERY;
          break;
          case 1:query=CREATE_TABLE_IMAGE_PATH_QUERY;
          break;
          case 2:query=CREATE_TABLE_ICON_PATH_QUERY;
          break;
        }
        ec=db.exec(query,null,out errmsg);
        //エラー処理
        if(ec!=Sqlite.OK){
          print("Sqlite error:%s\n",errmsg);
        }
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
  
  //profile_imageのインサート
  public void insert_image_path(int id,string image_path,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_IMAGE_PATH_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int path_param_position=stmt.bind_parameter_index("$PATH");
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(path_param_position,image_path);
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
  
  //iconのインサート
  public void insert_icon_path(int id,string icon_path,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_ICON_PATH_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    //パラメータの設定
    int id_param_position=stmt.bind_parameter_index("$ID");
    int path_param_position=stmt.bind_parameter_index("$PATH");
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(path_param_position,icon_path);
    
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
  
  //image_pathの読み出し
  public  string? select_image_path(int id,Sqlite.Database db){
    //tableに存在しなかった場合cache_dirを返す
    string image_path=null;
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=SELECT_FROM_IMAGE_PATH;
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
          case 1:image_path=stmt.column_text(i);
          break;
        }
      }
    }
    stmt.reset();
    
    return image_path;
  }
  
    //icon_pathの読み出し
  public  string? select_icon_path(int id,Sqlite.Database db){
    //tableに存在しなかった場合cache_dirを返す
    string icon_path=null;
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=SELECT_FROM_IMAGE_PATH;
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
          case 1:icon_path=stmt.column_text(i);
          break;
        }
      }
    }
    stmt.reset();
    
    return icon_path;
  }
  
  //pathの全削除
  public void delete_all(Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=DELETE_ALL_RECORD_FROM_IMAGE_PATH;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    while(stmt.step()!=Sqlite.DONE);
    
    prepared_query_str=DELETE_ALL_RECORD_FROM_ICON_PATH;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();  
  }
  
  //アカウントの削除
  public void delete_account(int list_id,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=DELETE_FROM_ACCOUNT;
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
  public void update_account(int new_list_id,int old_list_id,Sqlite.Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=UPDATE_ACCOUNT_ID;
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
}
