using UriUtils;

namespace StringUtils{
  //textの整形(ほとんどurlだけ)
  public string parse_text(ref string text,media[] media_array,urls[] urls_array){
    string parsed_text=text;
    //urlを置換
    try{
      for(int i=0;i<urls_array.length;i++){
        var text_regex_replace=new Regex(urls_array[i].url);
        GLib.StringBuilder url_sb=new GLib.StringBuilder("<u>");
        url_sb.append(urls_array[i].display_url);
        url_sb.append("</u>");
        parsed_text=text_regex_replace.replace(parsed_text,-1,0,url_sb.str);
        text=text_regex_replace.replace(text,-1,0,urls_array[i].display_url);
      }
      for(int i=0;i<media_array.length;i++){
        var text_regex_replace=new Regex(media_array[i].url);
        GLib.StringBuilder url_sb=new GLib.StringBuilder("<u>");
        url_sb.append(media_array[i].display_url);
        url_sb.append("</u>");
        parsed_text=text_regex_replace.replace(parsed_text,-1,0,url_sb.str);
        text=text_regex_replace.replace(text,-1,0,media_array[i].display_url);
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return parsed_text+" ";
  }
    
  public void get_incides(string text,media[] media_array,urls[] urls_array){
   int start_index=0;
   for(int i=0;i<media_array.length;i++){
     media_array[i].start_indices=text.index_of(media_array[i].display_url,start_index);
     media_array[i].end_indices=media_array[i].start_indices+media_array[i].display_url.char_count();
     start_index=media_array[i].end_indices;
   }
   start_index=0;
    for(int i=0;i<urls_array.length;i++){
      urls_array[i].start_indices=text.index_of(urls_array[i].display_url,start_index);
      urls_array[i].end_indices=urls_array[i].start_indices+urls_array[i].display_url.char_count();
      start_index=urls_array[i].end_indices; 
    }
  }
}
