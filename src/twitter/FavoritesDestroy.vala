using Rest;

namespace TwitterUtil{
  //☆ヲ殺ス
  public bool favorites_destroy(Account account,string id_str){
    ProxyCall post_call=account.api_proxy.new_call();
    post_call.set_function(FUNCTION_FAVORITES_DESTROY);
    post_call.set_method("POST");
    post_call.add_param(PARAM_ID,id_str);
    try{
      post_call.sync();
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }    
  }
}
