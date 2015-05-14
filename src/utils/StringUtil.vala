using Ruribitaki;
using Soup;

using BitlyUtil;
using URIUtil;

namespace StringUtil{
  //nameの&の置換(やらないとmark upでコケる
  public string parse_name(string get_name){
    string name_regex=null;
    try{  //セイキヒョウゲンカッコバクショウでクライアント名とURLを解析
      var name_regex_replace=new Regex("(&)");
      name_regex=name_regex_replace.replace(get_name,-1,0,"&amp;");
    }catch(Error e){
      print("%s\n",e.message);
    }
    return name_regex;
  }
    
  //textの整形(ほとんどurlだけ)
  public string parse_text(ref string text,hashtag[] hashtags,medium[] media,url[] urls){
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
  public void update_indices(string text,hashtag[] hashtags,medium[] media,url[] urls){
    int start_index=0;
    for(int i=0;i<hashtags.length;i++){
      hashtags[i].indices[0]=text.index_of("#%s".printf(hashtags[i].text),start_index);
      start_index=hashtags[i].indices[0]+hashtags[i].text.char_count();
      int end_indices=text.index_of(" ",start_index);
      hashtags[i].indices[1]=end_indices>0?end_indices:text.index_of_char('\0',start_index);
      //print("%d: %d \n",hashtags[i].indices[0],hashtags[i].indices[1]);
    }
    start_index=0;
    for(int i=0;i<media.length;i++){
      media[i].indices[0]=text.index_of(media[i].display_url,start_index);
      media[i].indices[1]=media[i].indices[0]+media[i].display_url.char_count();
      start_index=media[i].indices[1];
    }
    start_index=0;
    for(int i=0;i<urls.length;i++){
      urls[i].indices[0]=text.index_of(urls[i].display_url,start_index);
      urls[i].indices[1]=urls[i].indices[0]+urls[i].display_url.char_count();
      start_index=urls[i].indices[1];
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
  
  //URIの整形
  public string parse_uri(URI proxy_uri){
    string proxy_uri_str=proxy_uri.to_string(false);
    try{
      var port_regex=new Regex(":%u/".printf(proxy_uri.get_port()));
      proxy_uri_str=port_regex.replace(proxy_uri_str,-1,0,"");
    }catch(Error e){
      print("%s\n",e.message);
    }
    return proxy_uri_str;
  }
}
