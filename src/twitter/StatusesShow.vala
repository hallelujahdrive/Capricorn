using Rest;

namespace TwitterUtil{
  //単一ツイートの取得
  public async ParsedJsonObj? statuses_show(Account account,string id_str){
    ParsedJsonObj parsed_json_obj=null;
    
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_SHOW);
    proxy_call.set_method("GET");
    proxy_call.add_param(PARAM_ID,id_str);
    
    proxy_call.invoke_async.begin(null,()=>{
      parsed_json_obj=new ParsedJsonObj.from_string(proxy_call.get_payload(),account.my_screen_name);
      statuses_show.callback();
    });
    
    yield;
    return parsed_json_obj;
  }
}
