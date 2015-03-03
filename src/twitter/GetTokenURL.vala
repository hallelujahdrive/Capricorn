using Rest;

namespace TwitterUtil{
  //token_urlの取得
  public string? get_token_url(OAuthProxy api_proxy){
    try{
      api_proxy.request_token(FUNCTION_REQUEST_TOKEN,"oob");
      //OAuth認証用URL
      GLib.StringBuilder oauth_url_sb=new GLib.StringBuilder(URL_HEAD);
      oauth_url_sb.append(api_proxy.get_token());
      return oauth_url_sb.str;
    }catch(Error e){
      print("Could not get token_url:%s\n",e.message);
      return null;
    }
  }
}
