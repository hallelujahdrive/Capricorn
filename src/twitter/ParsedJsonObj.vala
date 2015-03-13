using Json;

namespace TwitterUtil{
  public class ParsedJsonObj{
    //メンバ
    public User user;
    public User sub_user;
    
    public string text;
    public string source_label;
    public string source_url;
    public string id_str;
    
    public media[] media_array;
    public urls[] urls_array;
        
    public string? in_reply_to_status_id;
    
    public bool retweeted;
    public bool favorited;
    
    public bool is_mine=false;
        
    public ParsedJsonObjType type=ParsedJsonObjType.NULL;
    public EventType? event_type;
    public TweetType tweet_type=TweetType.NORMAL;
    
    public DateTime event_created_at;
    public DateTime created_at;
    
    public ParsedJsonObj(Json.Node? json_node,string? my_screen_name){
      if(json_node!=null){
        Json.Object json_obj=json_node.get_object();
        //type変更
        type=ParsedJsonObjType.TWEET;
        
        //jsonを解析
        if(json_obj.has_member("delete")){
          //deleteの解析.json_objはdelete.statusから取得
          type=ParsedJsonObjType.DELETE;
          json_obj=(json_obj.get_object_member("delete")).get_object_member("status");
        }else if(json_obj.has_member("event")){
          //eventの解析.json_objはtargetから取得
          type=ParsedJsonObjType.EVENT;
          foreach(string event_member in json_obj.get_members()){
            switch(event_member){
              case "created_at":event_created_at=parse_created_at(json_obj.get_string_member(event_member));
              break;
              case "event":
              switch(json_obj.get_string_member(event_member)){
                case "access_revoked":event_type=EventType.ACCESS_REVOKED;
                break;
                case "block":event_type=EventType.BLOCK;
                break;
                case "unblock":event_type=EventType.UNBLOCK;
                break;
                case "favorite":event_type=EventType.FAVORITE;
                break;
                case "unfavorite":event_type=EventType.UNFAVORITE;
                break;
                case "follow":event_type=EventType.FOLLOW;
                break;
                case "unfollow":event_type=EventType.UNFOLLOW;
                break;
                case "list_created":event_type=EventType.LIST_CREATED;
                break;
                case "list_destroyed":event_type=EventType.LIST_DESTROYED;
                break;
                case "list_updated":event_type=EventType.LIST_UPDATED;
                break;
                case "list_member_added":event_type=EventType.LIST_MEMBER_ADDED;
                break;
                case "list_member_removed":event_type=EventType.LIST_MEMBER_REMOVED;
                break;
                case "list_user_subscribed":event_type=EventType.LIST_USER_SUBSCRIBED;
                break;
                case "list_user_unsubscribed":event_type=EventType.LIST_USER_UNSUBSCRIBED;
                break;
                case "user_update":event_type=EventType.USER_UPDATE;
                break;
                default:event_type=EventType.UNKNOWN;
                break;
              }
              break;
              case "source":
              //sub_userの取得
              sub_user=new User();
              parse_user(json_obj.get_object_member(event_member),sub_user,null); 
              break;
            }
          }
          json_obj=json_obj.get_object_member("target_object");
        }else if(json_obj.has_member("friends")){
          //friendsの解析(現状無視.そのうち書くかも)
          type=ParsedJsonObjType.FRIENDS;
          return;
        }else if(json_obj.has_member("retweeted_status")){
          //retweetの解析.json_objはretweet_statusから取得
          foreach(string retweet_member in json_obj.get_members()){
            switch(retweet_member){
              case "created_at":event_created_at=parse_created_at(json_obj.get_string_member(retweet_member));
              break;
              case "retweeted_status":json_obj=json_obj.get_object_member(retweet_member);
              break;
              case "user":
              //userの解析
              tweet_type=TweetType.RETWEET;
              sub_user=new User();
              parse_user(json_obj.get_object_member(retweet_member),sub_user,null);
              break;
            }
          }
        }
        
        foreach(string member in json_obj.get_members()){
          switch(member){
            case "created_at":created_at=parse_created_at(json_obj.get_string_member(member));
            break;
            case "favorited":favorited=json_obj.get_boolean_member(member);
            break;
            case "id_str":id_str=json_obj.get_string_member(member);
            break;
            case "in_reply_to_status_id_str":in_reply_to_status_id=json_obj.get_string_member(member);
            break;
            case "retweeted":retweeted=json_obj.get_boolean_member(member);
            break;
            case "source":parse_source(json_obj.get_string_member(member));
            break;
            case "entities":
            case "extended_entities":
            //entitiesの解析
            Json.Object entities_obj=json_obj.get_object_member(member);
            foreach(string entities_member in entities_obj.get_members()){
              switch(entities_member){
                case "media":parse_media(entities_obj.get_array_member(entities_member));
                break;
                case "urls":parse_urls(entities_obj.get_array_member(entities_member));
                break;
              }
            }
            break;
            case "text":
            text=json_obj.get_string_member(member);
            if(my_screen_name!=null&&text.contains(my_screen_name)&&tweet_type!=TweetType.RETWEET){
              tweet_type=TweetType.REPLY;
            }
            break;
            //userの解析
            case "user":
            user=new User();
            parse_user(json_obj.get_object_member(member),user,my_screen_name);
            break;
          }
        }
      }
    }
    
    public ParsedJsonObj.from_string(string json_str,string? screen_name){
      //json_obj
      Json.Parser json_parser=new Json.Parser();
      try{
        json_parser.load_from_data(json_str);
        this(json_parser.get_root(),screen_name);
      }catch(Error e){
        print("Error %s\n",e.message);
      }
    }
    //created_atのparse
    private DateTime? parse_created_at(string created_at_str){
      DateTime created_at=null;
      try{  //セイキヒョウゲンカッコバクショウで投稿日時を解析
        var created_at_regex_replace=new Regex("(:)");
        string created_at_regex=created_at_regex_replace.replace(created_at_str,-1,0," ");
        string[] created_at_split=created_at_regex.split(" ");
        int month=month_str_to_num(created_at_split[1]);
        int day=int.parse(created_at_split[2]);
        int hour=int.parse(created_at_split[3]);
        int minute=int.parse(created_at_split[4]);
        int second=int.parse(created_at_split[5]);
        int year=int.parse(created_at_split[7]);
        created_at=new DateTime.utc(year,month,day,hour,minute,second);
      }catch(Error e){
        print("%s\n",e.message);
      }
      return created_at;
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
    private void parse_source(string get_source){
      string[] source_split={"",""};
      //セイキヒョウゲンカッコバクショウでクライアント名とURLを解析
      try{
        var source_regex_replace=new Regex("(<a href=|rel=\"nofollow\"|\"|</a>)");
        string source_regex=source_regex_replace.replace(get_source,-1,0,"");
        source_split=source_regex.split(">");
      }catch(Error e){
        print("%s\n",e.message);
      }
      //配列からコンストラクタに格納
      source_label=source_split[1];
      source_url=source_split[0];
    }
  
    //urlの解析
    private void parse_urls(Json.Array urls_json_array){
      urls_array=new urls[urls_json_array.get_length()];
      for(int i=0;i<urls_json_array.get_length();i++){
        Json.Object urls_json_obj=urls_json_array.get_object_element(i);
        foreach(string member in urls_json_obj.get_members()){
          switch(member){
            case "display_url":urls_array[i].display_url=urls_json_obj.get_string_member(member);
            break;
            case "expanded_url":urls_array[i].expanded_url=urls_json_obj.get_string_member(member);
            break;
            case "url":urls_array[i].url=urls_json_obj.get_string_member(member);
            break;
            case "indices":
            Json.Array indices_json_array=urls_json_obj.get_array_member(member);
            for(int j=0;j<2;j++){
              switch(j){
                case 0:urls_array[i].start_indices=(int)indices_json_array.get_int_element(j);
                break;
                case 1:urls_array[i].end_indices=(int)indices_json_array.get_int_element(j);
                break;
              }
            }
            break;
          }
        }
      }
    }
    
    //userの解析
    private void parse_user(Json.Object user_obj,User user,string? my_screen_name){
      foreach(string user_member in user_obj.get_members()){
        switch(user_member){
          case "name":user.name=parse_name(user_obj.get_string_member(user_member));
          break;
          case "screen_name":
          user.screen_name=user_obj.get_string_member(user_member);
          //自分のtweetかどうか
          is_mine=my_screen_name==user.screen_name;
          break;
          case "profile_image_url":user.profile_image_url=user_obj.get_string_member(user_member);
          break;
          case "protected":user.account_is_protected=user_obj.get_boolean_member(user_member);
          break;
        }
      }
    }
    
    //mediaの解析
    private void parse_media(Json.Array media_json_array){
      media_array=new media[media_json_array.get_length()];
      for(int i=0;i<media_json_array.get_length();i++){
        Json.Object media_json_obj=media_json_array.get_object_element(i);
        foreach(string member in media_json_obj.get_members()){
          switch(member){
            case "display_url":media_array[i].display_url=media_json_obj.get_string_member(member);
            break;
            case "expanded_url":media_array[i].expanded_url=media_json_obj.get_string_member(member);
            break;
            case "media_url":media_array[i].media_url=media_json_obj.get_string_member(member);
            break;
            case "media_url_https":media_array[i].media_url_https=media_json_obj.get_string_member(member);
            break;
            case "url":media_array[i].url=media_json_obj.get_string_member(member);
            break;
            case "indices":
            Json.Array indices_json_array=media_json_obj.get_array_member(member);
            for(int j=0;j<2;j++){
              switch(j){
                case 0:media_array[i].start_indices=(int)indices_json_array.get_int_element(j);
                break;
                case 1:media_array[i].end_indices=(int)indices_json_array.get_int_element(j);
                break;
              }
            }
            break;
          }
        }
      }
    }
  }
}
