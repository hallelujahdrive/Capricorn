public class SignalPipe{
  //colorが変更された
  public signal void color_change();
  
  //リプライの要求
  public signal void reply_request(string tweet_id_str,string screen_name);
}
