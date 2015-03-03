using Rest;

namespace TwitterUtil{
  //user_stream
  class UserStream{
    private OAuthProxy stream_proxy_;
    
    private string json_frg;
    private StringBuilder json_sb=new StringBuilder();
    
    private ProxyCall stream_call;
    
    public UserStream(OAuthProxy stream_proxy){
      stream_proxy_=stream_proxy;
    }
  
    public void run(){
      //proxy_callの設定
      stream_call=stream_proxy_.new_call();
      stream_call.set_function(FUNCTION_USER);
      stream_call.set_method("GET");
      try{
        stream_call.continuous(user_stream_cb,stream_call);
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
            get_json_str(json_sb.str);
            //json_sbの初期化
            json_sb.erase();
          }
        }
      }
    }
    
    //シグナル
    public signal void get_json_str(string json_str);
    public signal void callback_error(string err);
  }
}
