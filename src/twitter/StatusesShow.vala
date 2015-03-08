using Rest;

namespace TwitterUtil{
  //単一ツイートの取得
  public string? statuses_show(OAuthProxy api_proxy,string id_str){
    ProxyCall proxy_call=api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_SHOW);
    proxy_call.set_method("GET");
    proxy_call.add_param(PARAM_ID,id_str);
    try{
      proxy_call.run();
      return proxy_call.get_payload();
    }catch(Error e){
      print("Json Error:%s\n",e.message);
      return null;
    }
  }
}
