using Rest;

namespace TwitterUtil{
  public class Account{
    //メンバ
    public int my_list_id;
    public int my_id;
    public string my_screen_name;
    public string my_profile_image_url;
    public string my_time_zone;
    public OAuthProxy api_proxy=new OAuthProxy(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET,API_URL,false);
    public OAuthProxy stream_proxy=new OAuthProxy(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET,STREAM_URL,false);
  }
}
