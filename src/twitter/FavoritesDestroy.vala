using Rest;

namespace TwitterUtil{
  //☆ヲ殺ス
  async bool favorites_destroy(Account account,string id_str){
    bool result=false;
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_FAVORITES_DESTROY);
    proxy_call.set_method("POST");
    proxy_call.add_param(PARAM_ID,id_str);
    
    //run
    //なんか気持ち悪い構文になっているが、こうしないとwarnningが出るのでRestのバグかも知れない
    proxy_call.invoke_async.begin(null,(obj,res)=>{
      try{
        result=proxy_call.invoke_async.end(res);
      }catch(Error e){
        print("Error : %s\n",e.message);
      }
      favorites_destroy.callback();
    });
    
    yield;
    return result;
  }
}
