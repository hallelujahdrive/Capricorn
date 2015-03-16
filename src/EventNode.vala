using Gtk;

using TwitterUtil;

class EventNode:Node{
  
  public int64 event_created_at;
  
  //Widget
  private EventDrawingBox favorite_event_drawing_box;
  private EventDrawingBox retweet_event_drawing_box;
  
  public EventNode(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    base(parsed_json_obj,account,config,signal_pipe);
    
    //EventDrawingBoxの作成
    retweet_event_drawing_box=new EventDrawingBox.retweet(this.parsed_json_obj,this.config,this.signal_pipe);
    favorite_event_drawing_box=new EventDrawingBox.favorite(this.parsed_json_obj,this.config,this.signal_pipe);
    
    this.attach(retweet_event_drawing_box,1,4,1,1);
    this.attach(favorite_event_drawing_box,1,5,1,1);
  }
  
  public EventNode.with_update(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,account,config,signal_pipe);
    
    //シグナルハンドラ
    this.signal_pipe.event_update_event.connect((parsed_json_obj)=>{
      if(parsed_json_obj.id_str==id_str){
        EventNode copy_node=null;
        if(config.event_show_on_time_line){
          copy_node=this.copy();
          copy_node.event_node_update(parsed_json_obj);
        }
        event_node_update(parsed_json_obj);
        return copy_node;
      }else if(parsed_json_obj.type==ParsedJsonObjType.DELETE){
        retweet_event_drawing_box.remove_user(parsed_json_obj.user);
      }
      return null;
    });
  }
  
  public EventNode.no_update(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,account,config,signal_pipe);
    
    event_node_update(this.parsed_json_obj);
  }
  
  //EventDrawongBoxのアップデート
  private void event_node_update(ParsedJsonObj parsed_json_obj){
    event_created_at=parsed_json_obj.event_created_at.to_unix();
    switch(parsed_json_obj.type){
      case ParsedJsonObjType.EVENT:
      switch(parsed_json_obj.event_type){
        case TwitterUtil.EventType.FAVORITE:favorite_event_drawing_box.add_user(parsed_json_obj.sub_user);
        break;
        case TwitterUtil.EventType.UNFAVORITE:favorite_event_drawing_box.remove_user(parsed_json_obj.sub_user);
        break;
      }
      break;
      case ParsedJsonObjType.RETWEET:retweet_event_drawing_box.add_user(parsed_json_obj.sub_user);
      break;
    }
  }
  
  //copy
  public EventNode copy(){
    EventNode copy_node=new EventNode.no_update(parsed_json_obj,account,config,signal_pipe);
    copy_node.favorite_event_drawing_box.update_hash_table(this.favorite_event_drawing_box.user_hash_table);
    copy_node.retweet_event_drawing_box.update_hash_table(this.retweet_event_drawing_box.user_hash_table);
    return copy_node;
  }
}
