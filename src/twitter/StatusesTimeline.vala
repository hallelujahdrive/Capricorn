using Rest;

namespace TwitterUtil{
  private string[]? statuses_timeline(ProxyCall proxy_call){
    //取得とセイキヒョウゲンカッコバクショウ
    try{
      proxy_call.run();
      string jsons=proxy_call.get_payload();
      var regex_replace=new Regex("(},{\"created_at\")");
      string regex=regex_replace.replace(jsons.slice(1,jsons.length-1),-1,0,"}\n{\"created_at\"");
      
      return regex.split("\n");
    }catch(Error e){
      print("%s\n",e.message);
      return null;
    }
  }
}
