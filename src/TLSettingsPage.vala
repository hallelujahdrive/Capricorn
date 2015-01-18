using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tl_settings_page.ui")]
class TLSettingsPage:Frame{
  private Config config_;
  
  public bool node_max_is_changed;
    
  //Widget
  [GtkChild]
  private SpinButton get_tweet_nodes_s_button;
  
  [GtkChild]
  private SpinButton tweet_node_max_s_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void value_changed_cb(){
    node_max_is_changed=true;
  }
  
  public TLSettingsPage(Config config){
    config_=config;
    
    //tabのiconの設定
    tab.set_from_pixbuf(config_.timeline_pixbuf);
    
    //spinbuttonへの値の挿入
    get_tweet_nodes_s_button.set_value(config_.get_tweet_nodes);
    tweet_node_max_s_button.set_value(config_.tweet_node_max);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    node_max_is_changed=false;
  }
  
  public void set_timeline_nodes(){
    config_.get_tweet_nodes=get_tweet_nodes_s_button.get_value_as_int();
    config_.tweet_node_max=tweet_node_max_s_button.get_value_as_int();
  }
}
