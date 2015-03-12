using Rest;

namespace TwitterUtil{
  //token_urlの取得
  public string? request_token(Account account){
    try{
      account.api_proxy.request_token(FUNCTION_REQUEST_TOKEN,"oob");
      //OAuth認証用URL
      GLib.StringBuilder oauth_url_sb=new GLib.StringBuilder(URL_HEAD);
      oauth_url_sb.append(account.api_proxy.get_token());
      return oauth_url_sb.str;
    }catch(Error e){
      print("Could not get token_url:%s\n",e.message);
      return null;
    }
  }
}
