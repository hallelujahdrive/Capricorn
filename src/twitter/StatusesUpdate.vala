using Rest;

namespace TwitterUtil{
  //tweetのpost
  public bool statuses_update(OAuthProxy api_proxy,string status,string? in_reply_to_status_id){
    bool result=false;
    ProxyCall proxy_call=api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_UPDATE);
    proxy_call.set_method("POST");
    proxy_call.add_param(PARAM_STATUS,status);
    //リプライならtweet_idのパラメータを設定
    if(in_reply_to_status_id!=null){
      proxy_call.add_param(PARAM_IN_REPLY_TO_STATUS_ID,in_reply_to_status_id);
    }
    try{
      if(proxy_call.sync()){
        result=true;
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return result;
  }
}
