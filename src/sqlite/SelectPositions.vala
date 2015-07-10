using Sqlite;

namespace SqliteUtil{
  public int select_positions(ref position[] positions,Database db){
    int column_length=0;
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_POSITIONS_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
      int cols=stmt.column_count();
      for(int i=0;stmt.step()==Sqlite.ROW;i++){
        for(int j=0;j<cols;j++){
          switch(j){
            case 1:
            positions[i].column=stmt.column_int(j);
            column_length=column_length>stmt.column_int(j)?column_length:stmt.column_int(j);
            break;
            case 2:positions[i].tab=stmt.column_int(j);
            break;
          }
        }
      }
    stmt.reset();
    return column_length+1;
  }
}
