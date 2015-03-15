using Rest;

namespace TwitterUtil{
  //retweet
  public bool statuses_retweet(Account account,string id_str){
    ProxyCall post_call=account.api_proxy.new_call();
    post_call.set_function(FUNCTION_STATUSES_RETWEET.printf(id_str));
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
