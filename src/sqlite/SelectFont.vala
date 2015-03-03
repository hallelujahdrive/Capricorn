using Pango;
using Sqlite;

namespace SqliteUtil{
  //fontの読み出し
  public void select_font(int id,FontProfile font_profile,Database db){
    int ec;
    Statement stmt;
    
    string prepared_query_str=SELECT_FROM_FONT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    stmt.bind_int(id_param_position,id);
    
    int cols=stmt.column_count();
    while(stmt.step()==Sqlite.ROW){
      for(int i=1;i<cols;i++){
        switch(i){
          case 1:font_profile.use_default=bool.parse(stmt.column_text(i));
          break;
          case 2:font_profile.name_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 3:font_profile.name_font_rgba.parse(stmt.column_text(i));
          break;
          case 4:font_profile.text_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 5:font_profile.text_font_rgba.parse(stmt.column_text(i));
          break;
          case 6:font_profile.footer_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 7:font_profile.footer_font_rgba.parse(stmt.column_text(i));
          break;
          case 8:font_profile.in_reply_font_desc=FontDescription.from_string(stmt.column_text(i));
          break;
          case 9:font_profile.in_reply_font_rgba.parse(stmt.column_text(i));
          break;
        }
      }
    }
    
    stmt.reset();
  }
}
