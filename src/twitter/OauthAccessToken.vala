using Rest;

namespace TwitterUtil{
  public bool oauth_access_token(Account account,string pin_code){
    try{
      //token,token_secretの取得
      account.api_proxy.access_token(FUNCTION_ACCESS_TOKEN,pin_code);
      //stream_apiにtokenの設定;
      account.stream_proxy.set_token(account.api_proxy.get_token());
      account.stream_proxy.set_token_secret(account.api_proxy.get_token_secret());
      
      return true;
    }catch(Error e){
      print("Could not get token and token_secret:%s\n",e.message);
      
      return false;
    }
  }
}
