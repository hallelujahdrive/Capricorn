namespace TwitterUtil{
  [Compact]
  [Immutable]
  [CCode(copy_function="twitter_util_user_copy")]
  public class User{
    public string name;
    public string screen_name;
    public string id_str;
    public string profile_image_url;
    public bool is_protected;
    
    public User(string? name,string? screen_name,string? id_str,string? profile_image_url,bool is_protected){
      this.name=name;
      this.screen_name=screen_name;
      this.id_str=id_str;
      this.profile_image_url=profile_image_url;
      this.is_protected=is_protected;
    }
    
    //なんとなくcopy実装してあるけど使い道ないしあんま意味ない
    public User copy(){
      return new User(this.name,this.screen_name,this.id_str,this.profile_image_url,this.is_protected);
    }
  }
}
