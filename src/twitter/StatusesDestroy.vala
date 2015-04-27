using Rest;

namespace TwitterUtil{
  //ツイート削除
  async bool statuses_destroy(Account account,string id_str){
    bool res;
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_DESROY.printf(id_str));
    proxy_call.set_method("POST");
    
    Idle.add(statuses_destroy.callback);
    
    try{
      res=proxy_call.sync();
    }catch(Error e){
      print("%s\n",e.message);
      res=false;
    }
    
    yield;
    return res;
  }
}
