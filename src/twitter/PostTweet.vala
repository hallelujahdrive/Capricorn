using Rest;

namespace TwitterUtil{
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
}
