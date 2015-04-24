using Json;
using Rest;

namespace TwitterUtil{
  private GLib.Array<ParsedJsonObj> statuses_timeline(ProxyCall proxy_call,string screen_name){
    //取得
    GLib.Array<ParsedJsonObj> parsed_json_obj_array=new GLib.Array<ParsedJsonObj>();
    try{
      proxy_call.run();
      string jsons_str=proxy_call.get_payload();
      //debug
      //print("%s\n",jsons_str);
      //json_obj
      Json.Parser json_parser=new Json.Parser();
      json_parser.load_from_data(jsons_str);
      Json.Node json_node=json_parser.get_root();
      if(json_node!=null){
         Json.Array json_array=json_node.get_array();
         for(uint i=0;i<json_array.get_length();i++){
           parsed_json_obj_array.append_val(new ParsedJsonObj(json_array.get_element(i),screen_name));
         }
       }
    }catch(Error e){
      print("%s\n",e.message);
    }
    return parsed_json_obj_array;
  }
}
