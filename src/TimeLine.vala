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
      try{
        init(statuses_home_timeline(cpr_account,config.init_time_line_node_count),cpr_account);
      }catch(Error e){
        print("Home timeline error : %s\n",e.message);
      }
    });
  }
  
  //mention
  public TimeLine.mention(CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    //シグナルハンドラ
    this.signal_pipe.show.connect(()=>{
      try{
        init(statuses_mention_timeline(cpr_account,config.init_time_line_node_count),cpr_account);
      }catch(Error e){
        print("Mention timeline error : %s\n",e.message);
      }
    });
  }
  
  //Nodeを配置
  private void init(Array<Ruribitaki.Status> status_array,CapricornAccount cpr_account){
    for(int i=0;i<status_array.length;i++){
      TweetNode? tweet_node=null;
      switch(status_array.index(i).status_type){
        case StatusType.RETWEET:tweet_node=new TweetNode.retweet(status_array.index(i).target_status,status_array.index(i).user,cpr_account,config,signal_pipe);
        break;
        case StatusType.TWEET:tweet_node=new TweetNode(status_array.index(i),cpr_account,config,signal_pipe);
        break;
      }
      if(tweet_node!=null){
        this.add_node(tweet_node);
      }
    }
  }
}
