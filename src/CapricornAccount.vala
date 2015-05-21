using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;

public class CapricornAccount:Account{
  private weak Config config;

  private weak MainWindow main_window;
  
  public int list_id;
  
  //TLScrolled
  public TimeLine home_time_line;
  public TimeLine mention_time_line;
  public EventNotifyListBox event_notify_list_box;
  
  private UserStream user_stream;
    
  //loading用
  private bool image_loaded=false;
  
  public CapricornAccount(Config config,Account ?account=null){
    base(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);

    //これくらいコピーすれば良い気がする
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
  }
  
  public void init(MainWindow main_window){
    this.main_window=main_window;
    //TimeLine
    home_time_line=new TimeLine.home(this,this.config,main_window);
    mention_time_line=new TimeLine.mention(this,this.config,main_window);
    event_notify_list_box=new EventNotifyListBox(this.config,main_window);
    
    //UserStream
    user_stream=new UserStream(this);
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(this.config.icon_theme.load_icon(LOADING_ICON,24,IconLookupFlags.NO_SVG));
      rotate_surface.run();
      rotate_surface.update.connect((surface)=>{
        if(!image_loaded){
          home_time_line.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
          mention_time_line.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
        }   
        return !image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_profile_image_async.begin(this.screen_name,this.profile_image_url,24,this.config,(obj,res)=>{
      Pixbuf pixbuf=get_profile_image_async.end(res);
      if(pixbuf!=null){
        home_time_line.tab.set_from_pixbuf(pixbuf);
        mention_time_line.tab.set_from_pixbuf(pixbuf);
        image_loaded=true;
      }
    });
    
    //user_streamの開始
    try{
      user_stream.run();
    }catch(Error e){
      print("User stream run error : %s\n",e.message);
    }
    
    //シグナルハンドラ
    user_stream.callback_json.connect((status)=>{
      switch(status.status_type){
        //tweetの削除の処理
        case StatusType.DELETE:
        delete_tweet_node_event(status.id_str);
        if(status.id_str!=null){
          event_update_event(status);
        }
        break;
        //eventの処理
        case StatusType.EVENT:
        switch(status.event){
          case Ruribitaki.EventType.FAVORITE:
          case Ruribitaki.EventType.UNFAVORITE:
          create_event(status);
          break;
        }
        break;
        //retweetの処理
        case StatusType.RETWEET:
        create_tweet(status);
        create_event(status);
        break;
        //tweetの処理
        case StatusType.TWEET:create_tweet(status);
        break;
      }
    });
    
    //エラー処理
    user_stream.callback_error.connect((err)=>{
      print("User stream error:%s\n",err.message);
      try{
        user_stream.run();
      }catch(Error e){
        print("User stream error : %s\n",e.message);
      }
    });
  }
  
  //tweetの作成
  private void create_tweet(Ruribitaki.Status status){
    TweetNode? tweet_node=null;
    switch(status.status_type){
      case StatusType.RETWEET:tweet_node=new TweetNode.retweet(status.target_status,status.user,this,this.config,this.main_window);
      break;
      case StatusType.TWEET:
      tweet_node=new TweetNode(status,this,this.config,this.main_window);
      if(status.is_reply){
        //replyの作成
        mention_time_line.prepend_node(tweet_node.copy());
      }
      break;
    }
    if(tweet_node!=null){
      home_time_line.prepend_node(tweet_node);
    }
  }
  
  //eventの作成
  private void create_event(Ruribitaki.Status status){
    if(status.target_status.is_mine){
      if(!event_notify_list_box.generic_set.contains(status.target_status.id_str)){
        event_notify_list_box.prepend_node(new EventNode.with_update(status,this,config,main_window));
      }
      if(event_update_event(status)){
        home_time_line.prepend_node(new EventNode.no_update(status,this,config,main_window));
      }
    }
  }
  
  //ScrolledWindowの削除
  public void destroy(){
    home_time_line.destroy();
    mention_time_line.destroy();
    event_notify_list_box.destroy();
  }

  //シグナル
  public signal void delete_tweet_node_event(string id_str);
  
  public signal bool event_update_event(Ruribitaki.Status status);
}
