using Rest;

namespace TwitterUtil{
  //アカウント情報の取得
  public bool account_verify_credential(Account account){
    //prox_call
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_ACCOUNT_VERIFY_CREDENTIALS);
    proxy_call.set_method("GET");
    try{
      proxy_call.run();
      return parse_profile_json(account,proxy_call.get_payload());
    }catch(Error e){
      print("Account Verify Error:%s\n",e.message);
      return false;
    }
  }
}
