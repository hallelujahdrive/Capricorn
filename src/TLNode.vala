using Gdk;
using Gtk;
using Rest;

using ImageUtil;
using TwitterUtil;

class TLNode{
  public int my_id;
  //TLScrolled
  public TimeLine home_time_line;
  public TimeLine mention_time_line;
  public EventNotifyListBox event_notify_list_box;
    
  private unowned Account account;
  private weak Config config;
  private weak SignalPipe signal_pipe;
  
  private UserStream user_stream;
    
  //loading用
  private bool profile_image_loaded=false;
  
  public TLNode(Account account,Config config,SignalPipe signal_pipe){
    this.account=account;
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    my_id=this.account.my_id;
        
    //TimeLine
    home_time_line=new TimeLine.home(this.account,this.config,this.signal_pipe);
    mention_time_line=new TimeLine.mention(this.account,this.config,this.signal_pipe);
    event_notify_list_box=new EventNotifyListBox(this.config,this.signal_pipe);
    
    //UserStream
    user_stream=new UserStream(this.account);
    //tab 
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(this.config.icon_theme.load_icon(LOADING_ICON,24,IconLookupFlags.NO_SVG));
      rotate_surface.run();
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          home_time_line.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
          mention_time_line.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
        }   
        return !profile_image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_profile_image_async.begin(this.account.my_screen_name,this.account.my_profile_image_url,24,this.config,(obj,res)=>{
      Pixbuf pixbuf=get_profile_image_async.end(res);
      home_time_line.tab.set_from_pixbuf(pixbuf);
      mention_time_line.tab.set_from_pixbuf(pixbuf);
      profile_image_loaded=true;
    });
    
    //user_streamの開始
    user_stream.run();
    
    //シグナルハンドラ
    user_stream.callback_json.connect((parsed_json_obj)=>{
      switch(parsed_json_obj.type){
        //tweetの削除の処理
        case ParsedJsonObjType.DELETE:
        this.signal_pipe.delete_tweet_node_event(parsed_json_obj.id_str);
        if(parsed_json_obj.id_str!=null){
          this.signal_pipe.event_update_event(parsed_json_obj);
        }
        break;
        //eventの処理
        case ParsedJsonObjType.EVENT:
        create_event(parsed_json_obj);
        /*switch(parsed_json_obj.event_type){
          case TwitterUtil.EventType.FAVORITE:
          break;
        }*/
        break;
        //retweetの処理
        case ParsedJsonObjType.RETWEET:
        create_tweet(parsed_json_obj);
        create_event(parsed_json_obj);
        break;
        //tweetの処理
        case ParsedJsonObjType.TWEET:create_tweet(parsed_json_obj);
        break;
      }
    });
    
    //エラー処理
    user_stream.callback_error.connect((err)=>{
      print("UserStream Error:%s\n",err.message);
      user_stream.run();
    });
  }
  
  //tweetの作成
  private void create_tweet(ParsedJsonObj parsed_json_obj){
    TweetNode tweet_node=new TweetNode(parsed_json_obj,this.account,this.config,this.signal_pipe);
    home_time_line.prepend_node(tweet_node);
    switch(parsed_json_obj.tweet_type){
      //replyの作成
      case TweetType.REPLY:mention_time_line.prepend_node(tweet_node.copy());
      break;
    }
  }
  
  //eventの作成
  private void create_event(ParsedJsonObj parsed_json_obj){
    if(parsed_json_obj.is_mine){
      if(!event_notify_list_box.generic_set.contains(parsed_json_obj.id_str)){
        event_notify_list_box.prepend_node(new EventNode.with_update(parsed_json_obj,account,config,signal_pipe));
      }
      if(signal_pipe.event_update_event(parsed_json_obj)){
        home_time_line.prepend_node(new EventNode.no_update(parsed_json_obj,account,config,signal_pipe));
      }
    }
  }
}
