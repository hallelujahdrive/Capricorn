using Rest;

namespace TwitterUtil{
  //user_stream
  class UserStream{
    private OAuthProxy _stream_proxy;
    
    private string json_frg;
    private StringBuilder json_sb=new StringBuilder();
    
    private ProxyCall proxy_call;
    
    public UserStream(Account account){
      _stream_proxy=account.stream_proxy;
    }
  
    public void run(){
      //proxy_callの設定
      proxy_call=_stream_proxy.new_call();
      proxy_call.set_function(FUNCTION_USER);
      proxy_call.set_method("GET");
      try{
        proxy_call.continuous(user_stream_cb,proxy_call);
      }catch(Error e){
        print("Error:%s\n",e.message);
      }
    }
  
    //user_streamのcallback
    private void user_stream_cb(ProxyCall call,string? buf,size_t len,Error? err){
      //エラー処理
      if(err!=null){
        callback_error(err.message);
      }
      if(buf!=null){
        json_frg=buf.substring(0,(int)len);  
        if(json_frg!="\n"){
          json_sb.append(json_frg);
          if(json_frg.has_suffix("\r\n")||json_frg.has_suffix("\r")){
            //シグナル発行
            callback_json(json_sb.str);
            //json_sbの初期化
            json_sb.erase();
          }
        }
      }
    }
    
    //シグナル
    public signal void callback_json(string json_str);
    public signal void callback_error(string err);
  }
}
