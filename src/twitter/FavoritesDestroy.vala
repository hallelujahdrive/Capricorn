using Rest;

namespace TwitterUtil{
  //☆ヲ殺ス
  async bool favorites_destroy(Account account,string id_str){
    bool res;
    ProxyCall post_call=account.api_proxy.new_call();
    post_call.set_function(FUNCTION_FAVORITES_DESTROY);
    post_call.set_method("POST");
    post_call.add_param(PARAM_ID,id_str);
    
    Idle.add(favorites_destroy.callback);
    
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
