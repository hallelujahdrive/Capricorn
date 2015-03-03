using Rest;

namespace BitlyUtil{
  public string shorting_url(string long_url){
    string url=null;
    OAuth2Proxy proxy=new OAuth2Proxy.with_token("",BITLY_ACCESS_TOKEN,"",API_URL,false);
    ProxyCall call=proxy.new_call();
    call.set_function(FUNCTION_SHOTEN);
    call.set_method("GET");
    call.add_params(PARAM_LONG_URL,long_url,PARAM_FORMAT,"json");

    try{
      call.run();
      string payload=call.get_payload();
      //bit.lyのjsonの解析
      Json.Parser bitly_parser=new Json.Parser();
      bitly_parser.load_from_data(payload);
      Json.Node bitly_node=bitly_parser.get_root();
      Json.Object bitly_object=bitly_node.get_object();
      //jsonの解析
      foreach(string member in bitly_object.get_members()){
        switch(member){
          case "data":
          Json.Object data_object=bitly_object.get_object_member(member);
          foreach(string data_member in data_object.get_members()){
            switch(data_member){
              case "url":url=data_object.get_string_member(data_member);
              break;
            }
          }
          break;
        }
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return url;
  }
}
