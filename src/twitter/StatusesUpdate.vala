using Rest;

namespace TwitterUtil{
  //tweetのpost
  public bool statuses_update(Account account,string status,string? in_reply_to_status_id_str){
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_UPDATE);
    proxy_call.set_method("POST");
    proxy_call.add_param(PARAM_STATUS,status);
    //リプライならtweet_idのパラメータを設定
    if(in_reply_to_status_id_str!=null){
      proxy_call.add_param(PARAM_IN_REPLY_TO_STATUS_ID,in_reply_to_status_id_str);
    }
    try{
      return proxy_call.sync();
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
}
