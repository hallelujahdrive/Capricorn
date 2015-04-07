using Gdk;
using Gtk;

using TwitterUtil;

class TimeLine:ScrolledListBox{
  //tab
  public Image tab=new Image();
      
  public TimeLine(Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    node_count_limit=config.time_line_node_count;
    
    //シグナルハンドラ
    signal_pipe.time_line_node_count_change_event.connect(()=>{
      node_count_limit=config.time_line_node_count;
      delete_nodes();
    });
  }
  
  //home
  public TimeLine.home(Account account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    //シグナルハンドラ
    this.signal_pipe.show.connect(()=>{
      init(statuses_home_timeline(account,config.init_time_line_node_count),account);
    });
  }
  
  //mention
  public TimeLine.mention(Account account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    //シグナルハンドラ
    this.signal_pipe.show.connect(()=>{
      init(statuses_mention_timeline(account,config.init_time_line_node_count),account);
    });
  }
  
  //Nodeを配置
  private void init(Array<ParsedJsonObj> parsed_json_obj_array,Account account){
    for(int i=0;i<parsed_json_obj_array.length;i++){
      TweetNode tweet_node=new TweetNode(parsed_json_obj_array.index(i),account,config,signal_pipe);
      this.add_node(tweet_node);
    }
  }
}
