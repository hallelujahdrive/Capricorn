using Rest;

namespace TwitterUtil{
  //アカウント情報の取得
  public bool get_account_info(Account account){
    //prox_call
    ProxyCall profile_call=account.api_proxy.new_call();
    profile_call.set_function(FUNCTION_ACCOUNT_VERIFY_CREDENTIALS);
    profile_call.set_method("GET");
    try{
      profile_call.run();
      string profile_json=profile_call.get_payload();
      parse_profile_json(profile_json,account);
      return true;
    }catch(Error e){
      print("%s\n",e.message);
      return false;
    }
  }
}
