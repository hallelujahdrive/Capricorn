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
    
  private Account account_;
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private UserStream user_stream;
  
  //json用
  private ParsedJsonObj parsed_json_obj;
  
  //tab
  public Image home_tab=new Image();
  public Image mention_tab=new Image();
  
  //loading用
  private bool profile_image_loaded=false;
  
  public TLNode(Account account,Config config,SignalPipe signal_pipe){
    account_=account;
    config_=config;
    signal_pipe_=signal_pipe;
    
    my_id=account.my_id;
        
    //TLPage
    home_tl_page=new TLPage(config_,signal_pipe_);
    mention_tl_page=new TLPage(config_,signal_pipe_);
    //UserStream
    user_stream=new UserStream(account_.stream_proxy);
    //tab 
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(config_.icon_theme.load_icon(LOADING_ICON,24,IconLookupFlags.NO_SVG),24,24);
      rotate_surface.run();
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          home_tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
          mention_tab.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,24,24));
        }   
        return !profile_image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_pixbuf_async.begin(config_.cache_dir_path,account_.my_screen_name,account_.my_profile_image_url,24,config.profile_image_hash_table,(obj,res)=>{
      Pixbuf pixbuf=get_pixbuf_async.end(res);
      home_tab.set_from_pixbuf(pixbuf);
      mention_tab.set_from_pixbuf(pixbuf);
      profile_image_loaded=true;
    });
    //home
    get_tweet_by_api(config_.get_tweet_nodes,false);
    //mention
    get_tweet_by_api(config_.get_tweet_nodes,true);
    //user_streamの開始
    user_stream.run();
    
    //シグナルハンドラ
    user_stream.get_json_str.connect((json_str)=>{
      parsed_json_obj=new ParsedJsonObj(json_str,account_.my_screen_name);
      if(parsed_json_obj.is_tweet){
        //homeのTweetNode
        TweetNode tweet_node=new TweetNode(parsed_json_obj,account.api_proxy,config_,signal_pipe);
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
  private void get_tweet_by_api(int get_tweet_max,bool is_mention){
    string[] json_array=get_timeline_json(account_.api_proxy,get_tweet_max,is_mention);
    for(int i=0;i<json_array.length;i++){
      parsed_json_obj=new ParsedJsonObj((owned)json_array[i],account_.my_screen_name);
      TweetNode tweet_node=new TweetNode(parsed_json_obj,account_.api_proxy,config_,signal_pipe_);
      if(is_mention){
        mention_tl_page.add_node((owned)tweet_node);
      }else{
        home_tl_page.add_node((owned)tweet_node);
      }
    }
  }
}
