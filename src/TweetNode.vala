using Gtk;

using TwitterUtil;

class TweetNode:Node{
  
  private IconButton reply_button;
  private IconButton retweet_button;
  private IconButton favorite_button;
  
  public TweetNode(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    base(parsed_json_obj,account,config,signal_pipe);
    
    //IconButtoの作成
    reply_button=new IconButton(REPLY_ICON,REPLY_HOVER_ICON,null,IconSize.BUTTON);
    retweet_button=new IconButton(RETWEET_ICON,RETWEET_HOVER_ICON,RETWEET_ON_ICON,IconSize.BUTTON,this.parsed_json_obj.retweeted);
    favorite_button=new IconButton(FAVORITE_ICON,FAVORITE_HOVER_ICON,FAVORITE_ON_ICON,IconSize.BUTTON,this.parsed_json_obj.favorited);
    
    
    action_box.pack_end(favorite_button,false,false,0);
    action_box.pack_end(retweet_button,false,false,0);
    action_box.pack_end(reply_button,false,false,0);
    
    //rt_drawing_boxの追加
    if(this.parsed_json_obj.type==ParsedJsonObjType.RETWEET){
      var rt_drawing_box=new RetweetDrawingBox(this.parsed_json_obj.sub_user,this.parsed_json_obj.retweet_count,this.config,signal_pipe);
      this.attach(rt_drawing_box,1,4,1,1);
    }
    
    //in_reply_drawing_boxの追加
    if(parsed_json_obj.in_reply_to_status_id_str!=null){
      var in_reply_drawing_box=new InReplyDrawingBox(this.config,this.signal_pipe);
      if(in_reply_drawing_box.draw_tweet(this.account,this.parsed_json_obj.in_reply_to_status_id_str)){
        this.attach(in_reply_drawing_box,1,5,1,1);
      }
    }
    
    //シグナルハンドラ
    //delete
    this.signal_pipe.delete_tweet_node_event.connect((id_str)=>{
      if(id_str==this.id_str){
        this.parsed_json_obj.type=ParsedJsonObjType.DELETE;
        set_bg_color();
        this.queue_draw();
      }
    });
    
    //reply
    reply_button.clicked.connect((already)=>{
      this.signal_pipe.reply_request_event(this.copy(),this.account.my_list_id);
      return true;
    });
    
    //retweet
    retweet_button.clicked.connect((already)=>{
      if(already){
        return statuses_destroy(this.account,this.parsed_json_obj.retweeted_status_id_str);
      }else{
        return statuses_retweet(this.account,this.parsed_json_obj.id_str);
      }
    });
    
    //favorite
    favorite_button.clicked.connect((already)=>{
      if(already){
        return favorites_destroy(this.account,this.parsed_json_obj.id_str);
      }else{
        return favorites_create(this.account,this.parsed_json_obj.id_str);
      }
    });
  }
  
  //copy
  public TweetNode copy(){
    return new TweetNode(parsed_json_obj,account,config,signal_pipe);
  }
}
