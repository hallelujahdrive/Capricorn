using Rest;

using JsonUtils;

namespace BitlyUtils{
  private static const string ACCESS_TOKEN="3fd832b3648dbe526b11b54f7ca6098330bef53f";
  private static const string API_URL="https://api-ssl.bitly.com";
  
  private static const string FUNCTION_SHOTEN="/v3/shorten?";
  
  private static const string PARAM_LONG_URL="longUrl";
  private static const string PARAM_FORMAT="format";
  
  public string shorting_url(string long_url){
    string url=null;
    OAuth2Proxy proxy=new OAuth2Proxy.with_token("",ACCESS_TOKEN,"",API_URL,false);
      ProxyCall call=proxy.new_call();
      call.set_function(FUNCTION_SHOTEN);
      call.set_method("GET");
      call.add_params(
        PARAM_LONG_URL,long_url,
        PARAM_FORMAT,"json"
      );

      try{
        call.run();
        string payload=call.get_payload();
        url=get_shorten_url(payload);
      }catch(Error e){
      print("%s\n",e.message);
    }
    return url;
  }
}
