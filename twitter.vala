using Rest;

using AccountInfo;

namespace Twitter{
  //ConsumerKey,URL,Function
  public static const string CONSUMER_KEY="RLPSuCTCq0xfXeSRF6KVu1c5v";
  public static const string CONSUMER_SECRET="iVnFROxYtG4prUS0tx6u7d348yANTfzhC3T5IghBVceSZPcZzm";
  public static const string API_URL="https://api.twitter.com";
  public static const string STREAM_URL="https://userstream.twitter.com";

  //Function
  private static const string FUNCTION_REQUEST_TOKEN="oauth/request_token";
  private static const string FUNCTION_ACCESS_TOKEN="oauth/access_token";
  public static const string FUNCTION_ACCOUNT_SETTINGS="1.1/account/settings.json";
  public static const string FUNCTION_ACCOUNT_VERIFY_CREDENTIALS="1.1/account/verify_credentials.json";
  public static const string FUNCTION_STATUSES_UPDATE="1.1/statuses/update.json";
  public static const string FUNCTION_STATUSES_HOME_TIMELINE="1.1/statuses/home_timeline.json";
  public static const string FUNCTION_STATUSES_MENTIONS_TIMELINE="1.1/statuses/mentions_timeline.json";
  public static const string FUNCTION_USER="1.1/user.json";

  public static const string PARAM_STATUS="status";
  public static const string PARAM_DELIMITED="delimited";
  public static const string PARAM_COUNT="count";
  
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
  public void get_account_info(Account account){
    //prox_call
    ProxyCall profile_call=account.api_proxy.new_call();
    profile_call.set_function(FUNCTION_ACCOUNT_SETTINGS);
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
        }
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
  }
    
  //tweetのpost
  public bool post_tweet(string post,OAuthProxy api_proxy){
    ProxyCall post_call=api_proxy.new_call();
    post_call.set_function(FUNCTION_STATUSES_UPDATE);
    post_call.set_method("POST");
    post_call.add_param(PARAM_STATUS,post);
    try{
      post_call.sync();
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
}
