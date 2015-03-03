using Sqlite;

namespace SqliteUtil{
  //fontのinsert
   void insert_font(int id,FontProfile font_profile,Database db){
    int ec;
    Sqlite.Statement stmt;
    
    string prepared_query_str=INSERT_FONT_QUERY;
    ec=db.prepare_v2(prepared_query_str,prepared_query_str.length,out stmt);
    if(ec!=Sqlite.OK){
      print("Error:%d:%s\n",db.errcode(),db.errmsg());
    }
    
    int id_param_position=stmt.bind_parameter_index("$ID");
    int use_default_param_position=stmt.bind_parameter_index("$USE_DEFAULT");
    int name_fd_param_position=stmt.bind_parameter_index("$NAME_FD");
    int name_fr_param_position=stmt.bind_parameter_index("$NAME_FR");
    int text_fd_param_position=stmt.bind_parameter_index("$TEXT_FD");
    int text_fr_param_position=stmt.bind_parameter_index("$TEXT_FR");
    int footer_fd_param_position=stmt.bind_parameter_index("$FOOTER_FD");
    int footer_fr_param_position=stmt.bind_parameter_index("$FOOTER_FR");
    int in_reply_fd_param_position=stmt.bind_parameter_index("$IN_REPLY_FD");
    int in_reply_fr_param_position=stmt.bind_parameter_index("$IN_REPLY_FR");
    
    //インサート
    stmt.bind_int(id_param_position,id);
    stmt.bind_text(use_default_param_position,font_profile.use_default.to_string());
    stmt.bind_text(use_default_param_position,font_profile.use_default.to_string());
    stmt.bind_text(name_fd_param_position,font_profile.name_font_desc.to_string());
    stmt.bind_text(name_fr_param_position,font_profile.name_font_rgba.to_string());
    stmt.bind_text(text_fd_param_position,font_profile.text_font_desc.to_string());
    stmt.bind_text(text_fr_param_position,font_profile.text_font_rgba.to_string());
    stmt.bind_text(footer_fd_param_position,font_profile.footer_font_desc.to_string());
    stmt.bind_text(footer_fr_param_position,font_profile.footer_font_rgba.to_string());
    stmt.bind_text(in_reply_fd_param_position,font_profile.in_reply_font_desc.to_string());
    stmt.bind_text(in_reply_fr_param_position,font_profile.in_reply_font_rgba.to_string());
    
    while(stmt.step()!=Sqlite.DONE);
    stmt.reset();
  }
}
