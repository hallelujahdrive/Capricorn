using UriUtils;

public class SignalPipe{
  //colorが変更された
  public signal void color_change_event();
  
  //timeline_nodesが変更された
  public signal void timeline_nodes_is_changed();
  
  //リプライの要求
  public signal void reply_request_event(TweetNode tweet_node);
  
  //post
  public signal void post_button_click_event();
  
  //url_shorting
  public signal void url_shorting_button_click_event();

  //media_url
  public signal void media_url_click_event(media[] media_array,TweetNode tweet_node);
}
