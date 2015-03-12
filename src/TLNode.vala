using Gdk;
using Gtk;
using Rest;

using ImageUtil;
using TwitterUtil;

class TLNode{
  public int my_id;
  //TLScrolled
  public TLPage home_tl_page;
  public TLPage mention_tl_page;
  public TLPage event_page;
    
  private unowned Account _account;
  private weak Config _config;
  private weak SignalPipe _signal_pipe;
  
  private UserStream user_stream;
    
  //loading用
  private bool profile_image_loaded=false;
  
  public TLNode(Account account,Config config,SignalPipe signal_pipe){
    _account=account;
    _config=config;
    _signal_pipe=signal_pipe;
    
    my_id=account.my_id;
        
    //TLPage
    home_tl_page=new TLPage.home(_account,_config,_signal_pipe);
    mention_tl_page=new TLPage.mention(_account,_config,_signal_pipe);
    event_page=new TLPage.event(_config,_signal_pipe);
    
    //UserStream
    user_stream=new UserStream(_account);
    //tab 
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(_config.icon_theme.load_icon(LOADING_ICON,24,IconLookupFlags.NO_SVG));
      rotate_surface.run();
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          home_tl_page.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
          mention_tl_page.tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
        }   
        return !profile_image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_pixbuf_async.begin(_config.cache_dir_path,_account.my_screen_name,_account.my_profile_image_url,24,config.profile_image_hash_table,(obj,res)=>{
      Pixbuf pixbuf=get_pixbuf_async.end(res);
      home_tl_page.tab.set_from_pixbuf(pixbuf);
      mention_tl_page.tab.set_from_pixbuf(pixbuf);
      profile_image_loaded=true;
    });
    
    //user_streamの開始
    user_stream.run();
    
    //シグナルハンドラ
    user_stream.callback_json.connect((parsed_json_obj)=>{
      switch(parsed_json_obj.type){
        //tweetの削除の処理
        case ParsedJsonObjType.DELETE:signal_pipe.delete_tweet_node_event(parsed_json_obj.id_str);
        break;
        //eventの処理
        case ParsedJsonObjType.EVENT:
        switch(parsed_json_obj.event_type){
          case TwitterUtil.EventType.FAVORITE:event_update(parsed_json_obj);
          break;
        }
        break;
        //tweetの処理
        case ParsedJsonObjType.TWEET:
        //homeのNode
        Node tweet_node=new Node.tweet(parsed_json_obj,_account,_config,signal_pipe);
        home_tl_page.prepend_node(tweet_node);
        switch(parsed_json_obj.tweet_type){
          //replyの作成
          case TweetType.REPLY:mention_tl_page.prepend_node(tweet_node.copy());
          break;
          //rtのNode.eventの作成
          case TweetType.RETWEET:
          event_update(parsed_json_obj);
          break;
        }
        break;
      }
    });
    
    //エラー処理
    user_stream.callback_error.connect((err)=>{
      print("UserStream Error:%s\n",err.message);
      user_stream.run();
    });
  }
  
  //eventの処理
  private void event_update(ParsedJsonObj parsed_json_obj){
    if(parsed_json_obj.is_mine){
      if(!_signal_pipe.event_update_event(parsed_json_obj)){
        event_page.prepend_node(new Node.event(parsed_json_obj,_account,_config,_signal_pipe));
        //シグナルハンドラだけでどうにかしようと言う魂胆
        _signal_pipe.event_update_event(parsed_json_obj);
      }
    }
  }
}
