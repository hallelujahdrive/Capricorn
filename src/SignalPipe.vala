using Ruribitaki;

public class SignalPipe{
  //AccountComboBoxの再読み込み
  public signal void account_array_change_event();
  //colorが変更された
  public signal void color_change_event();
  
  public signal void show();
  
  //timeline_node_conutが変更された
  public signal void time_line_node_count_change_event();
  
  //event_node_node_conutが変更された
  public signal void event_notify_settings_change_event();
  
  //textviewに文字列を追加
  public signal void add_text_event(string text,Node? tweet_node,int list_id);
  
  //post
  public signal void post_button_click_event();
  
  //url_shorting
  public signal void url_shorting_button_click_event();

  //media_urlがクリックされた
  public signal void media_url_click_event(Node tweet_node,medium[] media,medium[] extended_media);
  
  //delete
  public signal void delete_tweet_node_event(string id_str);
  
  //event
  public signal bool event_update_event(Status status);
}
