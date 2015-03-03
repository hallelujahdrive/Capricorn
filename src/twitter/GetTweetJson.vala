using Rest;

namespace TwitterUtil{
  //単一ツイートの取得
  public string? get_tweet_json(OAuthProxy api_proxy,string id_str){
    string json_str=null;
    ProxyCall get_call=api_proxy.new_call();
    get_call.set_function(FUNCTION_STATUSES_SHOW);
    get_call.set_method("GET");
    get_call.add_param(PARAM_ID,id_str);
    try{
      get_call.run();
      json_str=get_call.get_payload();
    }catch(Error e){
      print("Json Error:%s\n",e.message);
    }
    return json_str;
  }
}
