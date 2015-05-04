using Gdk;
using Gtk;
using Ruribitaki;

public class TimeLine:ScrolledListBox{
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
  public TimeLine.home(CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    //シグナルハンドラ
    this.signal_pipe.show.connect(()=>{
      init(statuses_home_timeline(cpr_account,config.init_time_line_node_count),cpr_account);
    });
  }
  
  //mention
  public TimeLine.mention(CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    //シグナルハンドラ
    this.signal_pipe.show.connect(()=>{
      init(statuses_mention_timeline(cpr_account,config.init_time_line_node_count),cpr_account);
    });
  }
  
  //Nodeを配置
  private void init(Array<ParsedJsonObj> parsed_json_obj_array,CapricornAccount cpr_account){
    for(int i=0;i<parsed_json_obj_array.length;i++){
      TweetNode tweet_node=new TweetNode(parsed_json_obj_array.index(i),cpr_account,config,signal_pipe);
      this.add_node(tweet_node);
    }
  }
}
