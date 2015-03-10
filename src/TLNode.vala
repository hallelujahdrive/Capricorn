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
    
  private unowned Account _account;
  private weak Config _config;
  private weak SignalPipe _signal_pipe;
  
  private UserStream user_stream;
  
  //json用
  private ParsedJsonObj parsed_json_obj;
    
  //loading用
  private bool profile_image_loaded=false;
  
  public TLNode(Account account,Config config,SignalPipe signal_pipe){
    _account=account;
    _config=config;
    _signal_pipe=signal_pipe;
    
    my_id=account.my_id;
        
    //TLPage
    home_tl_page=new TLPage(_config,_signal_pipe);
    mention_tl_page=new TLPage(_config,_signal_pipe);
    //UserStream
    user_stream=new UserStream(_account.stream_proxy);
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
    //home
    get_tweet_by_api(_config.init_node_count,false);
    //mention
    get_tweet_by_api(_config.init_node_count,true);
    //user_streamの開始
    user_stream.run();
    
    //シグナルハンドラ
    user_stream.callback_json.connect((json_str)=>{
      parsed_json_obj=new ParsedJsonObj(json_str,_account.my_screen_name);
      if(parsed_json_obj.is_delete){
        //ツイートの削除の処理
        signal_pipe.delete_tweet_node_event(parsed_json_obj.id_str);
      }else if(parsed_json_obj.is_tweet){
        //homeのTweetNode
        TweetNode tweet_node=new TweetNode(parsed_json_obj,_account,_config,signal_pipe);
        //replyの作成
        if(parsed_json_obj.is_reply){
          TweetNode reply_node=tweet_node.copy();
          mention_tl_page.prepend_node(reply_node);
        }
        home_tl_page.prepend_node(tweet_node);

      }
    });
    
    //エラー処理
    user_stream.callback_error.connect((err)=>{
      print("UserStream Error:%s\n",err);
      user_stream.run();
    });
  }
  
  //ツイートの取得
  private void get_tweet_by_api(int count,bool is_mention){
    string[] json_array;
    TLPage tl_page;
    if(is_mention){
      json_array=statuses_mention_timeline(_account.api_proxy,count);
      tl_page=mention_tl_page;
    }else{
      json_array=statuses_home_timeline(_account.api_proxy,count);
      tl_page=home_tl_page;
    }
    for(int i=0;i<json_array.length;i++){
      parsed_json_obj=new ParsedJsonObj((owned)json_array[i],_account.my_screen_name);
      TweetNode tweet_node=new TweetNode(parsed_json_obj,_account,_config,_signal_pipe);
      
      tl_page.add_node(tweet_node);
    }
  }
}
