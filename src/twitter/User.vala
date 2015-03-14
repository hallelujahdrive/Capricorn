namespace TwitterUtil{
  [Compact]
  public class User{
    public string name;
    public string screen_name;
    public string profile_image_url;
    public bool account_is_protected;
    
    public User(string? name,string? screen_name,string? profile_image_url,bool account_is_protected){
      this.name=name;
      this.screen_name=screen_name;
      this.profile_image_url=profile_image_url;
      this.account_is_protected=account_is_protected;
    }
  }
}
