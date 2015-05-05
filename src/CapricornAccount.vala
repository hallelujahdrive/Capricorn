using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;

[Compact]
public class CapricornAccount:Account{
  private weak Config config;
  private weak SignalPipe signal_pipe;
  
  public int list_id;
  
  //TLScrolled
  public TimeLine home_time_line;
  public TimeLine mention_time_line;
  public EventNotifyListBox event_notify_list_box;
  
  private UserStream user_stream;
    
  //loading用
  private bool profile_image_loaded=false;
  
  public CapricornAccount(Config config,SignalPipe signal_pipe,Account ?account=null){
    base(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);
    
    if(account!=null){
      this.id=account.id;
      this.id_str=account.id_str;
      this.profile_image_url=account.profile_image_url;
      this.screen_name=account.screen_name;
      this.time_zone=account.time_zone;
      this.api_proxy.set_token(account.api_proxy.get_token());
      this.api_proxy.set_token_secret(account.api_proxy.get_token_secret());
      this.stream_proxy.set_token(account.stream_proxy.get_token());
      this.stream_proxy.set_token_secret(account.stream_proxy.get_token_secret());
    }
    
    this.config=config;
    this.signal_pipe=signal_pipe;
  }
  
  public void init(){
    //TimeLine
    home_time_line=new TimeLine.home(this,this.config,this.signal_pipe);
    mention_time_line=new TimeLine.mention(this,this.config,this.signal_pipe);
    event_notify_list_box=new EventNotifyListBox(this.config,this.signal_pipe);
    
    //UserStream
    user_stream=new UserStream(this);
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
    get_profile_image_async.begin(this.screen_name,this.profile_image_url,24,this.config,(obj,res)=>{
      Pixbuf pixbuf=get_profile_image_async.end(res);
      if(pixbuf!=null){
        home_time_line.tab.set_from_pixbuf(pixbuf);
        mention_time_line.tab.set_from_pixbuf(pixbuf);
        profile_image_loaded=true;
      }
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
          case Ruribitaki.EventType.FAVORITE:
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
    TweetNode tweet_node=new TweetNode(parsed_json_obj,this,this.config,this.signal_pipe);
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
        event_notify_list_box.prepend_node(new EventNode.with_update(parsed_json_obj,this,config,signal_pipe));
      }
      if(signal_pipe.event_update_event(parsed_json_obj)){
        home_time_line.prepend_node(new EventNode.no_update(parsed_json_obj,this,config,signal_pipe));
      }
    }
  }
  
  //オブジェクトの削除
  public void destroy(){
    home_time_line.destroy();
    mention_time_line.destroy();
    event_notify_list_box.destroy();
  }
}
