using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tl_page.ui")]
class TLPage:ScrolledWindow{
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private int node_count=0;
  
  //widget
  [GtkChild]
  private ListBox tl_list_box;
  
  //tab
  public Image tab=new Image();
      
  public TLPage(Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    tl_list_box.override_background_color(StateFlags.NORMAL,config.white);
    
    signal_pipe_.timeline_nodes_is_changed.connect(()=>{
      if(config_.tweet_node_max<node_count){
        delete_nodes();
      }
    });
  }
  
  //TweetNodeの追加(append)
  public void add_node(TweetNode tweet_node){
    tl_list_box.add(tweet_node);
    node_count++;
  }
  
  //TweetNodeの追加(prepend)
  public void prepend_node(TweetNode tweet_node){
    tl_list_box.prepend(tweet_node);
    //古いTweetNodeの削除
    if(node_count==config_.tweet_node_max){
      //ListBoxRowの取得
      tl_list_box.remove(tl_list_box.get_row_at_index(config_.tweet_node_max));
    }else{
      node_count++;
    }
  }
  
  //TweetNodeの削除
  private void delete_nodes(){
    while(node_count!=config_.tweet_node_max){
      //ListBoxRowの取得
      node_count--;
      tl_list_box.remove(tl_list_box.get_row_at_index(node_count));
    }
  }
}
