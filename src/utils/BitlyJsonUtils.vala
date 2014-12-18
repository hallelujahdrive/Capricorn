using Json;

namespace JsonUtils{
  //bit.lyのjsonの解析
  public string? get_shorten_url(string bitly_json){
    string url=null;
    try{
      Json.Parser bitly_parser=new Json.Parser();
      bitly_parser.load_from_data(bitly_json);
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
