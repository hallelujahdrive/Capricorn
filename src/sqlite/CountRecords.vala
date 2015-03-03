using Sqlite;

namespace SqliteUtil{
  //テーブル内のレコード数のカウント
  public int count_records(Sqlite.Database db,string table_name){
    int ec;
    string errmsg;
    
    //戻り値
    int records=0;
    
    StringBuilder query_sb=new StringBuilder("SELECT COUNT(*) FROM ");
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
}
