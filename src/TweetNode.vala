using Cairo;
using Gdk;
using Gtk;
using Rest;

using TwitterUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tweet_node.ui")]
public class TweetNode:Grid{
  private ParsedJsonObj parsed_json_obj_;
  private OAuthProxy api_proxy_;
  private Config config_;
  private SignalPipe signal_pipe_;
    
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
    parsed_json_obj_=parsed_json_obj;
    api_proxy_=api_proxy;
    config_=config;
    signal_pipe_=signal_pipe;
    
    header_d_box=new HeaderDrawingBox(parsed_json_obj_.screen_name,parsed_json_obj_.name,parsed_json_obj_.account_is_protected,config_,signal_pipe_);
    text_d_box=new TextDrawingBox(parsed_json_obj_.text,parsed_json_obj_.media_array,parsed_json_obj_.urls_array,config_,signal_pipe_);
    footer_d_box=new FooterDrawingBox(parsed_json_obj_.created_at,parsed_json_obj_.source_label,parsed_json_obj_.source_url,config_,signal_pipe_);
    
    profile_image_button=new ProfileImageButton(parsed_json_obj_.screen_name,parsed_json_obj_.profile_image_url,config_,signal_pipe_);
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
    if(parsed_json_obj_.is_retweet){
      var rt_d_box=new RetweetDrawingBox(parsed_json_obj_.rt_screen_name,parsed_json_obj_.rt_profile_image_url,config_,signal_pipe_);
      this.attach(rt_d_box,1,4,1,1);
    }
    
    //in_reply_d_boxの追加
    if(parsed_json_obj_.in_reply_to_status_id!=null){
      var in_reply_d_box=new InReplyDrawingBox(config_,signal_pipe_);
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
      if(id_str==parsed_json_obj_.id_str){
        parsed_json_obj_.is_delete=true;
        this.override_background_color(StateFlags.NORMAL,config_.delete_bg_rgba);
      }
    });
    
    //reply
    reply_button.clicked.connect((already)=>{
      signal_pipe_.reply_request_event(this.copy(),parsed_json_obj.id_str,parsed_json_obj_.screen_name);
      return true;
    });
    
    //retweet
    retweet_button.clicked.connect((already)=>{
      return retweet(parsed_json_obj_.id_str,api_proxy_);
    });
    
    //favorite
    favorite_button.clicked.connect((already)=>{
      return favorite(parsed_json_obj_.id_str,api_proxy_);
    });
  }
  
  //色の設定
  private void set_bg_color(){
    if(parsed_json_obj_.is_mine){
      this.override_background_color(StateFlags.NORMAL,config_.mine_bg_rgba);
    }else if(parsed_json_obj_.is_retweet){
      this.override_background_color(StateFlags.NORMAL,config_.retweet_bg_rgba);
    }else if(parsed_json_obj_.is_reply){
      this.override_background_color(StateFlags.NORMAL,config_.reply_bg_rgba);
    }else if(!parsed_json_obj_.is_delete){
      this.override_background_color(StateFlags.NORMAL,config_.default_bg_rgba);
    }
  }
  
  //コピー
  public TweetNode copy(){
    return new TweetNode(parsed_json_obj_,api_proxy_,config_,signal_pipe_);
  }
}
