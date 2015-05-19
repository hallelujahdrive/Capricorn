using Gtk;
using Ruribitaki;

class TweetNode:Node{
  //RTのstautsのid_str
  protected string? source_id_str;
  //RTしたuser
  protected User? user;
  
  //Widget
  private IconButton reply_button;
  private IconButton retweet_button;
  private IconButton favorite_button;
  
  public TweetNode(Status status,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    base(status,cpr_account,config,signal_pipe);
    
    //IconButtoの作成
    reply_button=new IconButton(REPLY_ICON,REPLY_HOVER_ICON,null,IconSize.BUTTON);
    retweet_button=new IconButton(RETWEET_ICON,RETWEET_HOVER_ICON,RETWEET_ON_ICON,IconSize.BUTTON,this.status.retweeted);
    favorite_button=new IconButton(FAVORITE_ICON,FAVORITE_HOVER_ICON,FAVORITE_ON_ICON,IconSize.BUTTON,this.status.favorited);
    
    
    action_box.pack_end(favorite_button,false,false,0);
    action_box.pack_end(retweet_button,false,false,0);
    action_box.pack_end(reply_button,false,false,0);
    
    //in_reply_drawing_boxの追加
    if(status.in_reply_to_status_id_str!=null){
      var in_reply_drawing_box=new InReplyDrawingBox(this.config,this.signal_pipe);
      
      in_reply_drawing_box.draw_tweet.begin(this.cpr_account,this.status.in_reply_to_status_id_str,(obj,res)=>{
        if(in_reply_drawing_box.draw_tweet.begin.end(res)){
          this.attach(in_reply_drawing_box,1,5,1,1);
        }
      });
    }
    
    //シグナルハンドラ
    //delete
    this.signal_pipe.delete_tweet_node_event.connect((id_str)=>{
      if(id_str==this.id_str){
        node_type=NodeType.DELETED;
        this.queue_draw();
      }
    });
    
    //reply
    reply_button.clicked.connect(()=>{
      this.signal_pipe.add_text_event(build_reply(this.status.user,this.status.entities_user_mentions),this.copy(),this.cpr_account.list_id);
    });
    
    //retweet
    retweet_button.clicked.connect((image_button)=>{
      weak IconButton icon_button=(IconButton)image_button;
      if(icon_button.already){
        statuses_destroy.begin(this.cpr_account,this.source_id_str,(obj,res)=>{
          try{
            if(statuses_destroy.end(res)){
              icon_button.already=!icon_button.already;
              icon_button.update();
            }
          }catch(Error e){
            print("Retweet destroy error : %s\n",e.message);
          }
        });
      }else{
        statuses_retweet.begin(this.cpr_account,this.status.id_str,(obj,res)=>{
          try{
            if(statuses_retweet.end(res)){
              icon_button.already=!icon_button.already;
              icon_button.update();
            }
          }catch(Error e){
            print("Retweet error : %s \n",e.message);
          }
        });
      }
    });
    
    //favorite
    favorite_button.clicked.connect((image_button)=>{
      weak IconButton icon_button=(IconButton)image_button;
      if(icon_button.already){
        favorites_destroy.begin(this.cpr_account,this.status.id_str,(obj,res)=>{
          try{
            if(favorites_destroy.end(res)){
              icon_button.already=!icon_button.already;
              icon_button.update();
            }
          }catch(Error e){
            print("Favorite destroy error : %s\n",e.message);
          }
        });
      }else{
        favorites_create.begin(this.cpr_account,this.status.id_str,(obj,res)=>{
          try{
            if(favorites_create.end(res)){
              icon_button.already=!icon_button.already;
              icon_button.update();
            }
          }catch(Error e){
            print("Favorite error : %s\n",e.message);
          }
        });
      }
    });
  }
  
  //Retweet
  public TweetNode.retweet(Status status,User user,CapricornAccount cpr_account,Config config,SignalPipe signal_pipe){
    this(status,cpr_account,config,signal_pipe);
    
    this.user=user;
    
    this.source_id_str=status.id_str;
    
    //NodeType
    this.node_type=NodeType.RETWEET;
    
    //rt_drawing_boxの追加
    var rt_drawing_box=new RetweetDrawingBox(this.user,this.status.retweet_count,this.config,this.signal_pipe);
    this.attach(rt_drawing_box,1,4,1,1);
    
    //背景色
    set_bg_color();
  }
  
  //replyのscreen_nameをぽこぽこ
  private string build_reply(User user,user_mention[] user_mentions){
    var sb=new StringBuilder("@%s ".printf(user.screen_name));
    var generic_set=new GenericSet<string>(str_hash,str_equal);
    for(int i=0;i<user_mentions.length;i++){
      if(user_mentions[i].screen_name!=this.cpr_account.screen_name){
        generic_set.add(user_mentions[i].screen_name);
      }
    }
    generic_set.foreach((val)=>{
      sb.append("@%s ".printf(val));
    });
    return sb.str;
  }
  
  //copy
  public TweetNode copy(){
    switch(node_type){
      case NodeType.RETWEET:
      return new TweetNode.retweet(status,user,cpr_account,config,signal_pipe);
      default:
      return new TweetNode(status,cpr_account,config,signal_pipe);
    }
  }
}
