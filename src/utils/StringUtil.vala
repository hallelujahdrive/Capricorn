using BitlyUtil;
using TwitterUtil;
using URIUtil;

namespace StringUtil{
  //textの整形(ほとんどurlだけ)
  public string parse_text(ref string text,hashtag[] hashtags,url[] media,url[] urls){
    string parsed_text=text;
    //urlを置換
    try{
      for(int i=0;i<hashtags.length;i++){
        string hashtag="#%s".printf(hashtags[i].text);
        var text_regex_replace=new Regex(hashtag);
        GLib.StringBuilder sb=new GLib.StringBuilder("<u>");
        sb.append(hashtag);
        sb.append("</u>");
        parsed_text=text_regex_replace.replace(parsed_text,-1,0,sb.str);
        text=text_regex_replace.replace(text,-1,0,hashtag);
      }
      for(int i=0;i<media.length;i++){
        var text_regex_replace=new Regex(media[i].url);
        GLib.StringBuilder sb=new GLib.StringBuilder("<u>");
        sb.append(media[i].display_url);
        sb.append("</u>");
        parsed_text=text_regex_replace.replace(parsed_text,-1,0,sb.str);
        text=text_regex_replace.replace(text,-1,0,media[i].display_url);
      }
      for(int i=0;i<urls.length;i++){
        var text_regex_replace=new Regex(urls[i].url);
        GLib.StringBuilder sb=new GLib.StringBuilder("<u>");
        sb.append(urls[i].display_url);
        sb.append("</u>");
        parsed_text=text_regex_replace.replace(parsed_text,-1,0,sb.str);
        text=text_regex_replace.replace(text,-1,0,urls[i].display_url);
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return parsed_text+" ";
  }
  
  //urlのincidesを取得
  public void get_incides(string text,url[] media_array,url[] urls_array){
   int start_index=0;
   for(int i=0;i<media_array.length;i++){
     media_array[i].indices[0]=text.index_of(media_array[i].display_url,start_index);
     media_array[i].indices[1]=media_array[i].indices[0]+media_array[i].display_url.char_count();
     start_index=media_array[i].indices[1];
   }
   start_index=0;
    for(int i=0;i<urls_array.length;i++){
      urls_array[i].indices[0]=text.index_of(urls_array[i].display_url,start_index);
      urls_array[i].indices[1]=urls_array[i].indices[0]+urls_array[i].display_url.char_count();
      start_index=urls_array[i].indices[1]; 
    }
  }
  
  //urlの短縮
  public string parse_post_text(string old_text){
    string parsed_text=old_text;
    MatchInfo match_info;
    try{
      var text_regex=new Regex("https?://[-_.!~*\'a-zA-Z0-9;/?:@&=+$,%#]+");
      if(text_regex.match(old_text,0,out match_info)){
        //ひたすら置換
        do{
          //URL中に"?"が入っていると正常に置換できないのでどうにかする
          var sign_regex=new Regex("\\?");
          string long_url=sign_regex.replace(match_info.fetch(0),-1,0,"\\\\?");
          //URL中に"+"が入っていると正常に置換できないのでどうにかする
          sign_regex=new Regex("\\+");
          long_url=sign_regex.replace(long_url,-1,0,"\\\\+");
          var text_regex_replace=new Regex(long_url,0,0);
          string url=shorting_url(match_info.fetch(0));
          parsed_text=text_regex_replace.replace_literal(parsed_text,-1,0,url);
        }while(match_info.next());
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return parsed_text;
  }
}
