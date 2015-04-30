using Rest;

namespace TwitterUtil{
  //ツイート削除
  public async bool statuses_destroy(Account account,string id_str){
    bool result=false;
    ProxyCall proxy_call=account.api_proxy.new_call();
    proxy_call.set_function(FUNCTION_STATUSES_DESROY.printf(id_str));
    proxy_call.set_method("POST");
    
    //run
    //なんか気持ち悪い構文になっているが、こうしないとwarnningが出るのでRestのバグかも知れない
    proxy_call.invoke_async.begin(null,(obj,res)=>{
      try{
        result=proxy_call.invoke_async.end(res);
      }catch(Error e){
        print("Error : %s\n",e.message);
      }
      statuses_destroy.callback();
    });
    
    yield;
    return result;
  }
}
