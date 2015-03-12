using Gdk;
using Gtk;

using TwitterUtil;

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
  
  //home
  public TLPage.home(Account account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    init(statuses_home_timeline(account,config.init_node_count),account);
  }
  
  //mention
  public TLPage.mention(Account account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
   init(statuses_mention_timeline(account,config.init_node_count),account);
  }
  
  //event
  public TLPage.event(Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
  }
  
  //TLNodeを取得
  private void init(Array<ParsedJsonObj> parsed_json_obj_array,Account account){
    for(int i=0;i<parsed_json_obj_array.length;i++){
      Node tweet_node=new Node.tweet(parsed_json_obj_array.index(i),account,_config,_signal_pipe);
      this.add_node(tweet_node);
    }
  }
  
  //Nodeの追加(append)
  public void add_node(Node node){
    tl_list_box.add(node);
    node_count++;
  }
  
  //Nodeの追加(prepend)
  public void prepend_node(Node node){
    tl_list_box.prepend(node);
    //古いNodeの削除
    if(node_count==_config.tl_node_count){
      //ListBoxRowの取得
      tl_list_box.remove(tl_list_box.get_row_at_index(_config.tl_node_count));
    }else{
      node_count++;
    }
  }
  
  //Nodeの削除
  private void delete_nodes(){
    while(node_count!=_config.tl_node_count){
      //ListBoxRowの取得
      node_count--;
      tl_list_box.remove(tl_list_box.get_row_at_index(node_count));
    }
  }
}
