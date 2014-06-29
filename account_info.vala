using Rest;

using Twitter;

namespace AccountInfo{
  public class Account:GLib.Object{
    //コンストラクタ
    public int my_list_id{get;set;}
    public int my_id{get;set;}
    public string my_screen_name{get;set;}
    public OAuthProxy api_proxy=new OAuthProxy(CONSUMER_KEY,CONSUMER_SECRET,API_URL,false);
    public OAuthProxy stream_proxy=new OAuthProxy(CONSUMER_KEY,CONSUMER_SECRET,STREAM_URL,false);
  }
}
