using TwitterUtil;

public class SignalPipe{
  //AccountComboBoxの再読み込み
  public signal void account_array_change_event();
  //colorが変更された
  public signal void color_change_event();
  
  //timeline_node_conutが変更された
  public signal void timeline_nodes_is_changed();
  
  //リプライの要求
  public signal void reply_request_event(TweetNode tweet_node,int my_list_id);
  
  //post
  public signal void post_button_click_event();
  
  //url_shorting
  public signal void url_shorting_button_click_event();

  //media_urlがクリックされた
  public signal void media_url_click_event(TweetNode tweet_node,media[] media_array);
  
  //delete
  public signal void delete_tweet_node_event(string id_str);
}
