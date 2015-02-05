using Rest;

using JsonUtils;

namespace TwitterUtils{
  //ConsumerKey,URL,Function
  private static const string CONSUMER_KEY="RLPSuCTCq0xfXeSRF6KVu1c5v";
  private static const string CONSUMER_SECRET="iVnFROxYtG4prUS0tx6u7d348yANTfzhC3T5IghBVceSZPcZzm";
  private static const string API_URL="https://api.twitter.com";
  private static const string STREAM_URL="https://userstream.twitter.com";

  //Function
  private static const string FUNCTION_REQUEST_TOKEN="oauth/request_token";
  private static const string FUNCTION_ACCESS_TOKEN="oauth/access_token";
  private static const string FUNCTION_ACCOUNT_SETTINGS="1.1/account/settings.json";
  private static const string FUNCTION_ACCOUNT_VERIFY_CREDENTIALS="1.1/account/verify_credentials.json";
  private static const string FUNCTION_STATUSES_UPDATE="1.1/statuses/update.json";
  private static const string FUNCTION_STATUSES_HOME_TIMELINE="1.1/statuses/home_timeline.json";
  private static const string FUNCTION_STATUSES_MENTIONS_TIMELINE="1.1/statuses/mentions_timeline.json";
  private static const string FUNCTION_STATUSES_RETWEET="1.1/statuses/retweet/";
  private static const string FUNCTION_STATUSES_SHOW="1.1/statuses/show.json";
  private static const string FUNCTION_FAVORITES_CREATE="1.1/favorites/create.json";
  private static const string FUNCTION_USER="1.1/user.json";

  private static const string PARAM_STATUS="status";
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
  
  //user_stream
  class UserStream{
    private OAuthProxy stream_proxy_;
    
    private string json_frg;
    private StringBuilder json_sb=new StringBuilder();
    
    private ProxyCall stream_call;
    
    public UserStream(OAuthProxy stream_proxy){
      stream_proxy_=stream_proxy;
    }
  
    public void run(){
      //proxy_callの設定
      stream_call=stream_proxy_.new_call();
      stream_call.set_function(FUNCTION_USER);
      stream_call.set_method("GET");
      try{
        stream_call.continuous(user_stream_cb,stream_call);
      }catch(Error e){
        print("Error:%s\n",e.message);
      }
    }
  
    //user_streamのcallback
    private void user_stream_cb(ProxyCall call,string? buf,size_t len,Error? err){
      //エラー処理
      if(err!=null){
        callback_error(err.message);
      }
      if(buf!=null){
        json_frg=buf.substring(0,(int)len);  
        if(json_frg!="\n"){
          json_sb.append(json_frg);
          if(json_frg.has_suffix("\r\n")||json_frg.has_suffix("\r")){
            get_json_str(json_sb.str);
            json_sb.erase();
          }
          //json_sbの初期化
        }
      }
    }
    
    //シグナル
    public signal void get_json_str(string json_str);
    
    public signal void callback_error(string err);
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
      string profile_json=profile_call.get_payload();
      parse_profile_json(profile_json,account);
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
  
  //tweetのpost
  async bool post_tweet(string post,string? tweet_id,OAuthProxy api_proxy){
    bool result=false;
    ProxyCall post_call=api_proxy.new_call();
    post_call.set_function(FUNCTION_STATUSES_UPDATE);
    post_call.set_method("POST");
    post_call.add_param(PARAM_STATUS,post);
    //リプライならtweet_idのパラメータを設定
    if(tweet_id!=null){
      post_call.add_param(PARAM_IN_REPLY_TO_STATUS_ID,tweet_id);
    }
    try{
      if(post_call.sync()){
        result=true;
      }
    }catch(Error e){
      print("%s\n",e.message);
      result=false;
    }
    return result;
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
  
  //単一ツイートの取得
  public string? get_tweet_json(OAuthProxy api_proxy,string id_str){
    string json_str=null;
    ProxyCall get_call=api_proxy.new_call();
    get_call.set_function(FUNCTION_STATUSES_SHOW);
    get_call.set_method("GET");
    get_call.add_param(PARAM_ID,id_str);
    try{
      get_call.run();
      json_str=get_call.get_payload();
    }catch(Error e){
      print("Json Error:%s\n",e.message);
    }
    return json_str;
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
