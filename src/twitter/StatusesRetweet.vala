using Rest;

namespace TwitterUtil{
  //retweet
  async bool statuses_retweet(Account account,string id_str){
    bool res;
    ProxyCall post_call=account.api_proxy.new_call();
    post_call.set_function(FUNCTION_STATUSES_RETWEET.printf(id_str));
    post_call.set_method("POST");
    
    Idle.add(statuses_retweet.callback);
    
    try{
      res=post_call.sync();
    }catch(Error e){
      print("%s\n",e.message);
      res=false;
    }
    
    yield;
    return res;
  }
}
