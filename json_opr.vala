using Gdk;
using Rest;
using Sqlite;

using SqliteOpr;

namespace JsonOpr{
  public class ParseJson{
    //コンストラクタ
    public bool obj_not_null=false;
    public bool retweet=false;
    
    public string created_at;
    public string name;
    public string screen_name;
    public string profile_image_url;
    public string text;
    public string source_label;
    public string source_url;
    public int user_id;
    public int tweet_id;
    public string tweet_id_str;
    
    public string rt_name;
    public string rt_screen_name;
    public string rt_profile_image_url;
    public int rt_user_id;
      
    public bool reply=false;
    public ParseJson(string json_str,string my_screen_name,int[] time_deff,Sqlite.Database db){
      //json_obj
      Json.Parser json_parser=new Json.Parser();
      try{
        json_parser.load_from_data(json_str);
        Json.Node json_node=json_parser.get_root();
        if(json_node!=null){
          Json.Object json_obj=json_node.get_object();
          Json.Object json_main_obj;
          
          //jsonを解析
          //retweetの場合,各情報を取得
          if(json_obj.has_member("retweeted_status")){
            retweet=true;
            json_main_obj=json_obj.get_object_member("retweeted_status");
            foreach(string member in json_obj.get_members()){
              switch(member){
                case "user":
                Json.Object rt_user_obj=json_obj.get_object_member("user");
                foreach(string user_member in rt_user_obj.get_members()){
                  switch(user_member){
                    case "id": rt_user_id=(int)rt_user_obj.get_int_member("id");
                    break;
                    case "name": rt_name=parse_name(rt_user_obj.get_string_member("name"));
                    break;
                    case "screen_name": rt_screen_name=rt_user_obj.get_string_member("screen_name");
                    break;
                    case "profile_image_url": rt_profile_image_url=rt_user_obj.get_string_member("profile_image_url");
                    break;
                  }
                }
                break;
              }
            }
          }else{
            //retweetedではなかった場合,json_objそのものがjson_main_objになる
            json_main_obj=json_obj;
          }
          if(json_main_obj.has_member("text")){
            //jsonの解析
            foreach(string member in json_main_obj.get_members()){
              switch(member){
                case "created_at": created_at=parse_created_at(json_main_obj.get_string_member("created_at"),time_deff);
                break;
                case "user":
                Json.Object user_obj=json_main_obj.get_object_member("user");
                foreach(string user_member in user_obj.get_members()){
                  switch(user_member){
                    case "id": user_id=(int)user_obj.get_int_member("id");
                    break;
                    case "name": name=parse_name(user_obj.get_string_member("name"));
                    break;
                    case "screen_name": screen_name=user_obj.get_string_member("screen_name");
                    break;
                    case "profile_image_url": profile_image_url=user_obj.get_string_member("profile_image_url");
                    break;
                  }
                }
                break;
                case "text":
                text=parse_text(json_main_obj.get_string_member("text"));
                reply=text.contains(my_screen_name);
                break;
                case "source": parse_source(json_main_obj.get_string_member("source"));
                break;
                case "id_str": tweet_id_str=json_main_obj.get_string_member("id_str");
                break;
                case "id": tweet_id=(int)json_main_obj.get_int_member("id");
                break;
              }
            }
            obj_not_null=true;
          }
        }
      }catch(Error e){
        //print("%s\n",e.message);
      }
    }
    
    //textのparse
    private string parse_text(string get_text){
      string parse_text=get_text;
      GLib.MatchInfo match_info;
      try{
        var text_regex=new Regex("https?://[-_.!~*\'a-zA-Z0-9;/?:@&=+$,%#]+");
        if(text_regex.match(get_text,0,out match_info)){
          do{
            //urlをハイパーリンクに置換
            var text_regex_replace=new Regex(match_info.fetch(0));
            GLib.StringBuilder url_sb=new GLib.StringBuilder("<u>");
            url_sb.append(match_info.fetch(0));
            url_sb.append("</u>");
            parse_text=text_regex_replace.replace(parse_text,-1,0,url_sb.str);
          }while(match_info.next());
        }
      }catch(Error e){
        print("%s\n",e.message);
      }
      return parse_text;
    }
    
    //created_atのparse
    private string parse_created_at(string get_created_at,int[] time_deff){
      GLib.StringBuilder created_at_sb=new GLib.StringBuilder();
      try{  //セイキヒョウゲンカッコバクショウで投稿日時を解析
        var created_at_regex_replace=new Regex("(:)");
        string created_at_regex=created_at_regex_replace.replace(get_created_at,-1,0," ");
        string[] created_at_split=created_at_regex.split(" ");
        int c_a_day=int.parse(created_at_split[2]);
        int c_a_hour=int.parse(created_at_split[3])+time_deff[0];
        int c_a_min=int.parse(created_at_split[4])+time_deff[1];
        if(c_a_min>=60){
          c_a_min-=60;
          c_a_hour+=1;
        }
        if(c_a_hour>=24){
          c_a_hour-=24;
          c_a_day+=1;
        }
        string c_a_hour_str=parse_time(c_a_hour);
        string c_a_min_str=parse_time(c_a_min);
        created_at_sb.append(created_at_split[0]);
        created_at_sb.append(" ");
        created_at_sb.append(created_at_split[1]);
        created_at_sb.append(" ");
        created_at_sb.append(c_a_day.to_string());
        created_at_sb.append(", ");
        created_at_sb.append(c_a_hour_str);
        created_at_sb.append(":");
        created_at_sb.append(c_a_min_str);
      }catch(Error e){
        print("%s\n",e.message);
      }
      return created_at_sb.str;
    }
    //nameの&の置換(やらないとmark upでコケる
    private string parse_name(string get_name){
      string name_regex=null;
      try{  //セイキヒョウゲンカッコバクショウでクライアント名とURLを解析
        var name_regex_replace=new Regex("(&)");
        name_regex=name_regex_replace.replace(get_name,-1,0,"&amp;");
      }catch(Error e){
        print("%s\n",e.message);
      }
      return name_regex;
    }
    private string parse_time(int time){
      string time_str=time.to_string();
      if(time_str.length<2){
        GLib.StringBuilder time_sb=new GLib.StringBuilder("0");
        time_sb.append(time_str);
        return time_sb.str;
      }else{
        return time_str;
      }
    }
    private void parse_source(string get_source){
      string[] source_split={"https://twitter.com/","web"};
      if(get_source!="web"){
        //セイキヒョウゲンカッコバクショウでクライアント名とURLを解析
        try{
          var source_regex_replace=new Regex("(<a href=|rel=\"nofollow\"|\"|</a>)");
          string source_regex=source_regex_replace.replace(get_source,-1,0,"");
          source_split=source_regex.split(">");
        }catch(Error e){
          print("%s\n",e.message);
        }
      }
      //配列からコンストラクタに格納
      source_label=source_split[1];
      source_url=source_split[0];
    }
  }  
}
