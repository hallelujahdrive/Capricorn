using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tl_page.ui")]
class TLPage:ScrolledWindow{
  
  private TweetNode[] tweet_node_array;
  //TweetNodeの最大取得数(暫定でここで宣言)
  private int tweet_node_max=10;
  
  private int node_count=0;
  
  [GtkChild]
  private ListBox tl_list_box;
      
  public TLPage(Config config){
    tweet_node_array=new TweetNode[tweet_node_max];
    
    tl_list_box.override_background_color(StateFlags.NORMAL,config.white);
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
    if(node_count==tweet_node_max){
      //ListBoxRowの取得
      var del_node=tl_list_box.get_row_at_index(tweet_node_max);
      tl_list_box.remove(del_node);
      del_node.destroy();
    }else{
      node_count++;
    }
  }
}
