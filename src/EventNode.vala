using Gtk;
using Ruribitaki;

class EventNode:Node{
  
  public int64 event_created_at;
  
  //Widget
  private EventDrawingBox favorite_event_drawing_box;
  private EventDrawingBox retweet_event_drawing_box;
  
  public EventNode(Status status,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    base(status.target_status,cpr_account,config,signal_pipe);
    
    //EventDrawingBoxの作成
    retweet_event_drawing_box=new EventDrawingBox.retweet(this.config,this.signal_pipe);
    favorite_event_drawing_box=new EventDrawingBox.favorite(this.config,this.signal_pipe);
    
    this.attach(retweet_event_drawing_box,1,4,1,1);
    this.attach(favorite_event_drawing_box,1,5,1,1);
  }
  
  public EventNode.with_update(Ruribitaki.Status status,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(status,cpr_account,config,signal_pipe);
    
    //シグナルハンドラ
    this.signal_pipe.event_update_event.connect((status)=>{
      bool res=false;
      if(status.status_type==StatusType.DELETE){
        retweet_event_drawing_box.remove_user(status.user);
      }else if(status.target_status.id_str==id_str){
        res=event_node_update(status)&&this.config.event_show_on_time_line;
      }
      if(!favorite_event_drawing_box.active&&!retweet_event_drawing_box.active){
        //userが0の時、Nodeを削除(親遠すぎわろたでち)
        weak EventNotifyListBox parent=(EventNotifyListBox)this.get_parent().get_parent().get_parent().get_parent();
        weak ListBoxRow child=(ListBoxRow)this.get_parent();
        parent.remove_list_box_row(child);
      }
      return res;
    });
  }
  
  public EventNode.no_update(Status status,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(status,cpr_account,config,signal_pipe);
    
    event_node_update(status);
    
    //シグナルハンドラ
    this.signal_pipe.event_notify_settings_change_event.connect(()=>{
      if(!this.config.event_show_on_time_line){
        //userが0の時、Nodeを削除(親遠すぎわろたでち)
        weak ScrolledListBox parent=(ScrolledListBox)this.get_parent().get_parent().get_parent().get_parent();
        weak ListBoxRow child=(ListBoxRow)this.get_parent();
        parent.remove_list_box_row(child);
      }
    });
  }
  
  //EventDrawongBoxのアップデート
  private bool event_node_update(Status status){
    bool add=false;
    event_created_at=status.created_at.to_unix();
    switch(status.status_type){
      case Ruribitaki.StatusType.EVENT:
      switch(status.event){
        case Ruribitaki.EventType.FAVORITE:
        favorite_event_drawing_box.add_user(status.user,status.target_status.favorite_count);
        add=true;
        break;
        case Ruribitaki.EventType.UNFAVORITE:favorite_event_drawing_box.remove_user(status.user);
        break;
      }
      break;
      case Ruribitaki.StatusType.RETWEET:
      retweet_event_drawing_box.add_user(status.user,status.target_status.retweet_count);
      add=true;
      break;
    }
    return add;
  }
}
