using Json;

namespace TwitterUtil{
  //プロファイルの解析
  public bool parse_profile_json(string profile_json,Account account){
    bool success=true;
    try{
      Json.Parser profile_parser=new Json.Parser();
      profile_parser.load_from_data(profile_json);
      Json.Node profile_node=profile_parser.get_root();
      Json.Object profile_object=profile_node.get_object();
    
      //jsonの解析
      foreach(string member in profile_object.get_members()){
        switch(member){
          case "screen_name": account.my_screen_name=profile_object.get_string_member(member);
          break;
          case "id": account.my_id=(int)profile_object.get_int_member(member);
          break;
          case "profile_image_url": account.my_profile_image_url=profile_object.get_string_member(member);
          break;
          case "time_zone":account.my_time_zone=profile_object.get_string_member(member);
          break;
        }
      }
    }catch(Error e){
      print("ParseJson Error:%s\n",e.message);
      success=false;
    }
    return success;
  }
}
