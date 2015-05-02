using Gtk;
using Ruribitaki;

class EventNode:Node{
  
  public int64 event_created_at;
  
  //Widget
  private EventDrawingBox favorite_event_drawing_box;
  private EventDrawingBox retweet_event_drawing_box;
  
  public EventNode(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    base(parsed_json_obj,account,config,signal_pipe);
    
    //EventDrawingBoxの作成
    retweet_event_drawing_box=new EventDrawingBox.retweet(this.config,this.signal_pipe);
    favorite_event_drawing_box=new EventDrawingBox.favorite(this.config,this.signal_pipe);
    
    this.attach(retweet_event_drawing_box,1,4,1,1);
    this.attach(favorite_event_drawing_box,1,5,1,1);    
  }
  
  public EventNode.with_update(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,account,config,signal_pipe);
    
    //シグナルハンドラ
    this.signal_pipe.event_update_event.connect((parsed_json_obj)=>{
      bool res=false;
      if(parsed_json_obj.id_str==id_str){
        res=event_node_update(parsed_json_obj)&&this.config.event_show_on_time_line;
      }else if(parsed_json_obj.type==ParsedJsonObjType.DELETE){
        retweet_event_drawing_box.remove_user(parsed_json_obj.user);
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
  
  public EventNode.no_update(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,account,config,signal_pipe);
    
    event_node_update(this.parsed_json_obj);
    
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
  private bool event_node_update(ParsedJsonObj parsed_json_obj){
    bool add=false;
    event_created_at=parsed_json_obj.event_created_at.to_unix();
    switch(parsed_json_obj.type){
      case ParsedJsonObjType.EVENT:
      switch(parsed_json_obj.event_type){
        case Ruribitaki.EventType.FAVORITE:
        favorite_event_drawing_box.add_user(parsed_json_obj.sub_user,parsed_json_obj.favorite_count);
        add=true;
        break;
        case Ruribitaki.EventType.UNFAVORITE:favorite_event_drawing_box.remove_user(parsed_json_obj.sub_user);
        break;
      }
      break;
      case ParsedJsonObjType.RETWEET:
      retweet_event_drawing_box.add_user(parsed_json_obj.sub_user,parsed_json_obj.retweet_count);
      add=true;
      break;
    }
    return add;
  }
}
