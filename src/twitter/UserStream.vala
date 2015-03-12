using Rest;

namespace TwitterUtil{
  //user_stream
  class UserStream{
    private unowned Account _account;
    
    private string json_frg;
    private StringBuilder json_sb=new StringBuilder();
    
    private ProxyCall proxy_call;
    
    public UserStream(Account account){
      _account=account;
    }
  
    public void run(){
      //proxy_callの設定
      proxy_call=_account.stream_proxy.new_call();
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
        callback_error(err);
      }
      if(buf!=null){
        json_frg=buf.substring(0,(int)len);  
        if(json_frg!="\n"){
          json_sb.append(json_frg);
          if(json_frg.has_suffix("\r\n")||json_frg.has_suffix("\r")){
            //シグナル発行
            //debug
            //print("%s\n",json_sb.str);
            callback_json(new ParsedJsonObj.from_string(json_sb.str,_account.my_screen_name));
            //json_sbの初期化
            json_sb.erase();
          }
        }
      }
    }
    
    //シグナル
    public signal void callback_json(ParsedJsonObj parsed_json_obj);
    public signal void callback_error(Error e);
  }
}
