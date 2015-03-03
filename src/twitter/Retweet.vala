using Rest;

namespace TwitterUtil{
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
}
