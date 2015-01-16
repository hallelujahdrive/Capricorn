using UriUtils;

public class SignalPipe{
  //colorが変更された
  public signal void color_change_event();
  
  //timeline_nodesが変更された
  public signal void timeline_nodes_is_changed();
  
  //リプライの要求
  public signal void reply_request_event(string tweet_id_str,string screen_name);
  
  //post
  public signal void post_button_click_event();
  
  //url_shorting
  public signal void url_shorting_button_click_event();
  
  //SettingsWindowを開く
  public signal void settings_button_click_event();
  
  //SettingsWindowを閉じる
  public signal void settings_window_destroy_event();
  
  //media_url
  public signal void media_url_click_event(media[] media_array,TweetNode tweet_node);
}
