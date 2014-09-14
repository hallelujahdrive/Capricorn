using Rest;

using ContentsObj;

namespace Twitter{
  //ConsumerKey,URL,Function
  public static const string CONSUMER_KEY="RLPSuCTCq0xfXeSRF6KVu1c5v";
  public static const string CONSUMER_SECRET="iVnFROxYtG4prUS0tx6u7d348yANTfzhC3T5IghBVceSZPcZzm";
  public static const string API_URL="https://api.twitter.com";
  public static const string STREAM_URL="https://userstream.twitter.com";

  //Function
  private static const string FUNCTION_REQUEST_TOKEN="oauth/request_token";
  private static const string FUNCTION_ACCESS_TOKEN="oauth/access_token";
  private static const string FUNCTION_ACCOUNT_SETTINGS="1.1/account/settings.json";
  private static const string FUNCTION_ACCOUNT_VERIFY_CREDENTIALS="1.1/account/verify_credentials.json";
  private static const string FUNCTION_STATUSES_UPDATE="1.1/statuses/update.json";
  private static const string FUNCTION_STATUSES_HOME_TIMELINE="1.1/statuses/home_timeline.json";
  private static const string FUNCTION_STATUSES_MENTIONS_TIMELINE="1.1/statuses/mentions_timeline.json";
  private static const string FUNCTION_STATUSES_RETWEET="1.1/statuses/retweet/";
  private static const string FUNCTION_FAVORITES_CREATE="1.1/favorites/create.json";
  private static const string FUNCTION_USER="1.1/user.json";

  public static const string PARAM_STATUS="status";
  private static const string PARAM_IN_REPLY_TO_STATUS_ID="in_reply_to_status_id";
  private static const string PARAM_DELIMITED="delimited";
  private static const string PARAM_COUNT="count";
  private static const string PARAM_ID="id";
  
  //URL
  private static const string URL_HEAD="https://twitter.com/oauth/authorize?oauth_token=";
  
  //token_urlの取得
  public string? get_token_url(OAuthProxy api_proxy){
    try{
      api_proxy.request_token(FUNCTION_REQUEST_TOKEN,"oob");
      //OAuth認証用URL
      GLib.StringBuilder oauth_url_sb=new GLib.StringBuilder(URL_HEAD);
      oauth_url_sb.append(api_proxy.get_token());
      return oauth_url_sb.str;
    }catch(Error e){
      print("Could not get token_url:%s\n",e.message);
      return null;
    }
  }
  
  //PINコードの送信
  public bool get_token_and_token_secret(Account account,string pin_code){
    try{
      //token,token_secretの取得
      account.api_proxy.access_token(FUNCTION_ACCESS_TOKEN,pin_code);
      //stream_apiにtokenの設定;
      account.stream_proxy.set_token(account.api_proxy.get_token());
      account.stream_proxy.set_token_secret(account.api_proxy.get_token_secret());
      
      return true;
    }catch(Error e){
      print("Could not get token and token_secret:%s\n",e.message);
      
      return false;
    }
  }
  
  //アカウント情報の取得
  public bool get_account_info(Account account){
    //prox_call
    ProxyCall profile_call=account.api_proxy.new_call();
    profile_call.set_function(FUNCTION_ACCOUNT_VERIFY_CREDENTIALS);
    profile_call.set_method("GET");
    try{
      profile_call.run();
      
      //jsonの取得
      string profile_json=profile_call.get_payload();
      Json.Parser profile_parser=new Json.Parser();
      profile_parser.load_from_data(profile_json);
      Json.Node profile_node=profile_parser.get_root();
      Json.Object profile_object=profile_node.get_object();
      
      //jsonの解析
      foreach(string member in profile_object.get_members()){
        switch(member){
          case "screen_name": account.my_screen_name=profile_object.get_string_member("screen_name");
          break;
          case "id": account.my_id=(int)profile_object.get_int_member("id");
          break;
          case "profile_image_url": account.my_profile_image_url=profile_object.get_string_member("profile_image_url");
          break;
        }
      }
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
    
  //tweetのpost
  public bool post_tweet(string post,string? tweet_id,OAuthProxy api_proxy){
    ProxyCall post_call=api_proxy.new_call();
    post_call.set_function(FUNCTION_STATUSES_UPDATE);
    post_call.set_method("POST");
    post_call.add_param(PARAM_STATUS,post);
    if(tweet_id!=null){
      post_call.add_param(PARAM_IN_REPLY_TO_STATUS_ID,tweet_id);
    }
    try{
      post_call.sync();
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
  
  //retweet
  public bool retweet(string tweet_id,OAuthProxy api_proxy){
    ProxyCall post_call=api_proxy.new_call();
    var function_statuses_retweet_sb=new GLib.StringBuilder(FUNCTION_STATUSES_RETWEET);
    function_statuses_retweet_sb.append(tweet_id);
    function_statuses_retweet_sb.append(".json");
    post_call.set_function(function_statuses_retweet_sb.str);
    post_call.set_method("POST");
    try{
      post_call.sync();
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
  
  //☆
  public bool favorite(string tweet_id,OAuthProxy api_proxy){
    ProxyCall post_call=api_proxy.new_call();
    post_call.set_function(FUNCTION_FAVORITES_CREATE);
    post_call.set_method("POST");
    post_call.add_param(PARAM_ID,tweet_id);
    try{
      post_call.sync();
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
  
  //通常apiによるjsonの取得
  public string[] get_timeline_json(OAuthProxy api_proxy,int get_tweet_max,bool status_is_mention){
    //文字列,戻り値の配列
    string tl_json;
    string[] tl_json_split=new string[get_tweet_max];
    ProxyCall tl_call=api_proxy.new_call();
    //mentionかどうか
    if(status_is_mention){
      tl_call.set_function(FUNCTION_STATUSES_MENTIONS_TIMELINE);
    }else{
      tl_call.set_function(FUNCTION_STATUSES_HOME_TIMELINE);
    }
    //proxy_callのパラメータ
    tl_call.set_method("GET");
    tl_call.add_param(PARAM_COUNT,get_tweet_max.to_string());
    //取得とセイキヒョウゲンカッコバクショウ
    try{
      tl_call.run();
      tl_json=tl_call.get_payload();
      string tl_json_slice=tl_json.slice(1,tl_json.length-1);
      var tl_regex_replace=new Regex("(},{\"created_at\")");
      string tl_regex=tl_regex_replace.replace(tl_json_slice,-1,0,"}\n{\"created_at\"");
      tl_json_split=tl_regex.split("\n");
    }catch(Error e){
      print("%s\n",e.message);
    }
    return tl_json_split;
  }
}
