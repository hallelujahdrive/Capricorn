using Cairo;
using Gdk;
using Gtk;
using Rest;

using TwitterUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tweet_node.ui")]
public class TweetNode:Grid{
  private ParsedJsonObj _parsed_json_obj;
  private OAuthProxy _api_proxy;
  private Config _config;
  private SignalPipe _signal_pipe;
    
  private HeaderDrawingBox header_d_box;
  private TextDrawingBox text_d_box;
  private FooterDrawingBox footer_d_box;
  
  private ProfileImageButton profile_image_button;
  private IconButton reply_button;
  private IconButton retweet_button;
  private IconButton favorite_button;
    
  [GtkChild]
  private Box profile_image_box;
  
  [GtkChild]
  private Box action_box;
  
  public TweetNode(ParsedJsonObj parsed_json_obj,OAuthProxy api_proxy,Config config,SignalPipe signal_pipe){
    _parsed_json_obj=parsed_json_obj;
    _api_proxy=api_proxy;
    _config=config;
    _signal_pipe=signal_pipe;
    
    header_d_box=new HeaderDrawingBox(_parsed_json_obj.screen_name,_parsed_json_obj.name,_parsed_json_obj.account_is_protected,_config,_signal_pipe);
    text_d_box=new TextDrawingBox(_parsed_json_obj.text,_parsed_json_obj.media_array,_parsed_json_obj.urls_array,_config,_signal_pipe);
    footer_d_box=new FooterDrawingBox(_parsed_json_obj.created_at,_parsed_json_obj.source_label,_parsed_json_obj.source_url,_config,_signal_pipe);
    
    profile_image_button=new ProfileImageButton(_parsed_json_obj.screen_name,_parsed_json_obj.profile_image_url,_config,_signal_pipe);
    reply_button=new IconButton(REPLY_ICON,REPLY_HOVER_ICON,null,IconSize.BUTTON);
    retweet_button=new IconButton(RETWEET_ICON,RETWEET_HOVER_ICON,RETWEET_ON_ICON,IconSize.BUTTON);
    favorite_button=new IconButton(FAVORITE_ICON,FAVORITE_HOVER_ICON,FAVORITE_ON_ICON,IconSize.BUTTON);
    
    this.attach(header_d_box,1,0,1,1);
    this.attach(text_d_box,1,1,1,1);
    this.attach(footer_d_box,1,3,1,1);
    
    profile_image_box.pack_start(profile_image_button,false,false,0);
    
    action_box.pack_end(favorite_button,false,false,0);
    action_box.pack_end(retweet_button,false,false,0);
    action_box.pack_end(reply_button,false,false,0);
        
    //背景色の設定
    set_bg_color();
    
    //rt_d_boxの追加
    if(_parsed_json_obj.is_retweet){
      var rt_d_box=new RetweetDrawingBox(_parsed_json_obj.rt_screen_name,_parsed_json_obj.rt_profile_image_url,_config,_signal_pipe);
      this.attach(rt_d_box,1,4,1,1);
    }
    
    //in_reply_d_boxの追加
    if(_parsed_json_obj.in_reply_to_status_id!=null){
      var in_reply_d_box=new InReplyDrawingBox(_config,_signal_pipe);
      if(in_reply_d_box.draw_tweet(api_proxy,parsed_json_obj.in_reply_to_status_id)){
        this.attach(in_reply_d_box,1,5,1,1);
      }
    }
    
    //シグナルハンドラ
    //背景色設定のシグナル
    signal_pipe.color_change_event.connect(()=>{
      set_bg_color();
      this.queue_draw();
    });
    
    //delete
    signal_pipe.delete_tweet_node_event.connect((id_str)=>{
      if(id_str==_parsed_json_obj.id_str){
        _parsed_json_obj.is_delete=true;
        this.override_background_color(StateFlags.NORMAL,_config.delete_bg_rgba);
      }
    });
    
    //reply
    reply_button.clicked.connect((already)=>{
      _signal_pipe.reply_request_event(this.copy(),parsed_json_obj.id_str,_parsed_json_obj.screen_name);
      return true;
    });
    
    //retweet
    retweet_button.clicked.connect((already)=>{
      return retweet(_parsed_json_obj.id_str,_api_proxy);
    });
    
    //favorite
    favorite_button.clicked.connect((already)=>{
      return favorites_create(_parsed_json_obj.id_str,_api_proxy);
    });
  }
  
  //色の設定
  private void set_bg_color(){
    if(_parsed_json_obj.is_mine){
      this.override_background_color(StateFlags.NORMAL,_config.mine_bg_rgba);
    }else if(_parsed_json_obj.is_retweet){
      this.override_background_color(StateFlags.NORMAL,_config.retweet_bg_rgba);
    }else if(_parsed_json_obj.is_reply){
      this.override_background_color(StateFlags.NORMAL,_config.reply_bg_rgba);
    }else if(!_parsed_json_obj.is_delete){
      this.override_background_color(StateFlags.NORMAL,_config.default_bg_rgba);
    }
  }
  
  //コピー
  public TweetNode copy(){
    return new TweetNode(_parsed_json_obj,_api_proxy,_config,_signal_pipe);
  }
}
