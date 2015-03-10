using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tl_page.ui")]
class TLPage:ScrolledWindow{
  private weak Config _config;
  private weak SignalPipe _signal_pipe;
  
  private int node_count=0;
  
  //widget
  [GtkChild]
  private ListBox tl_list_box;
  
  //tab
  public Image tab=new Image();
      
  public TLPage(Config config,SignalPipe signal_pipe){
    _config=config;
    _signal_pipe=signal_pipe;
    
    tl_list_box.override_background_color(StateFlags.NORMAL,config.white);
    
    _signal_pipe.timeline_nodes_is_changed.connect(()=>{
      if(_config.tl_node_count<node_count){
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
    if(node_count==_config.tl_node_count){
      //ListBoxRowの取得
      tl_list_box.remove(tl_list_box.get_row_at_index(_config.tl_node_count));
    }else{
      node_count++;
    }
  }
  
  //TweetNodeの削除
  private void delete_nodes(){
    while(node_count!=_config.tl_node_count){
      //ListBoxRowの取得
      node_count--;
      tl_list_box.remove(tl_list_box.get_row_at_index(node_count));
    }
  }
}
