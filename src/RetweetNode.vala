using Gtk;
using Ruribitaki;

//retweetのnode
class RetweetNode:TweetNode{
  
  //private weak Status source_status;
  
  //Widget
  private RetweetDrawingBox rt_drawing_box;
  
  public RetweetNode(Status status,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    //this.source_status=source_status;
    //status_typeを書き換える
    //this.source_status.target_status.status_type=this.status.status_type;
    status.target_status.status_type=status.status_type;
    //描画用に渡すのはstatus.target_status;
    base(status.target_status,cpr_account,config,signal_pipe);
    //this.source_status=source_status;
    source_id_str=status.id_str;
    
    //rt_drawing_boxの追加
    rt_drawing_box=new RetweetDrawingBox(status.user,status.target_status.retweet_count,this.config,this.signal_pipe);
    this.attach(rt_drawing_box,1,4,1,1);
  }
  
  //copy
  /*public override TweetNode copy(){
    new RetweetNode(,cpr_account,config,signal_pipe);
  }*/
}
