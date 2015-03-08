using Rest;

namespace TwitterUtil{
  //☆
  public bool favorites_create(string tweet_id,OAuthProxy api_proxy){
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
}
