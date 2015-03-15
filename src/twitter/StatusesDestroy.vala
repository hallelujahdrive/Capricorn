using Rest;

namespace TwitterUtil{
  //ツイート削除
  public bool statuses_destroy(Account account,string id_str){
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_DESROY.printf(id_str));
    proxy_call.set_method("POST");
    //リプライならtweet_idのパラメータを設定
    try{
      return proxy_call.sync();
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
}
