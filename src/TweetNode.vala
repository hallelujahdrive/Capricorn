using Cairo;
using Gdk;
using Gtk;
using Rest;

using ImageUtils;
using JsonUtils;
using TwitterUtils;
using UriUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tweet_node.ui")]
class TweetNode:Grid{
  private ParsedJsonObj parsed_json_obj_;
  private OAuthProxy api_proxy_;
  private Config config_;
  private SignalPipe signal_pipe_;
    
  private HeaderDrawingBox header_d_box;
  private TextDrawingBox text_d_box;
  private FooterDrawingBox footer_d_box;
    
  private bool already_retweet=false;
  private bool already_favorite=false;
  
  [GtkChild]
  private EventBox profile_image_ebox;

  [GtkChild]
  private Image profile_image_image;

  [GtkChild]
  private EventBox reply_ebox;
  
  [GtkChild]
  private Image reply_icon;
  
  [GtkChild]
  private EventBox retweet_ebox;
  
  [GtkChild]
  private Image retweet_icon;
  
  [GtkChild]
  private EventBox favorite_ebox;
  
  [GtkChild]
  private Image favorite_icon;

  //リプライ
  [GtkCallback]
  private bool reply_ebox_button_press_event_cb(EventButton reply_ebutton){
    signal_pipe_.reply_request(parsed_json_obj_.tweet_id_str,parsed_json_obj_.screen_name);
    return true;
  }
  //hover
  [GtkCallback]
  private bool reply_ebox_enter_notify_event_cb(EventCrossing event){
    reply_icon.set_from_pixbuf(get_pixbuf_from_path(config_.reply_hover_icon_path,16));
    return true;
  }
  //leave
  [GtkCallback]
  private bool reply_ebox_leave_notify_event_cb(EventCrossing event){
    reply_icon.set_from_pixbuf(get_pixbuf_from_path(config_.reply_icon_path,16));
    return true;
  }
  
  //リツイート
  [GtkCallback]
  private bool retweet_ebox_button_press_event_cb(EventButton retweet_ebutton){
    if(!already_retweet){
      already_retweet=retweet(parsed_json_obj_.tweet_id_str,api_proxy_);
      retweet_icon.set_from_pixbuf(get_pixbuf_from_path(config_.retweet_on_icon_path,16));
    }
    return already_retweet;
  }
  //hover
  [GtkCallback]
  private bool retweet_ebox_enter_notify_event_cb(EventCrossing event){
    if(!already_retweet){
      retweet_icon.set_from_pixbuf(get_pixbuf_from_path(config_.retweet_hover_icon_path,16));
    }
    return true;
  }
  //leave
  [GtkCallback]
  private bool retweet_ebox_leave_notify_event_cb(EventCrossing event){
    if(!already_retweet){
      retweet_icon.set_from_pixbuf(get_pixbuf_from_path(config_.retweet_icon_path,16));
    }
    return true;
  }
  
  //☆
  [GtkCallback]
  private bool favorite_ebox_button_press_event_cb(EventButton favorite_ebutton){
    if(!already_favorite){
      already_favorite=favorite(parsed_json_obj_.tweet_id_str,api_proxy_);
      favorite_icon.set_from_pixbuf(get_pixbuf_from_path(config_.favorite_on_icon_path,16));
    }
    return already_favorite;
  }
  //hover
  [GtkCallback]
  private bool favorite_ebox_enter_notify_event_cb(EventCrossing event){
    if(!already_favorite){
      favorite_icon.set_from_pixbuf(get_pixbuf_from_path(config_.favorite_hover_icon_path,16));
    }
    return true;
  }
  //leave
  [GtkCallback]
  private bool favorite_ebox_leave_notify_event_cb(EventCrossing event){
    if(!already_favorite){
      favorite_icon.set_from_pixbuf(get_pixbuf_from_path(config_.favorite_icon_path,16));
    }
    return true;
  }
  
  public TweetNode(ParsedJsonObj parsed_json_obj,OAuthProxy api_proxy,Config config,SignalPipe signal_pipe){
    parsed_json_obj_=parsed_json_obj;
    api_proxy_=api_proxy;
    config_=config;
    signal_pipe_=signal_pipe;
    
    header_d_box=new HeaderDrawingBox(parsed_json_obj_.screen_name,parsed_json_obj_.name,parsed_json_obj_.account_is_protected,config_,signal_pipe_);
    text_d_box=new TextDrawingBox(parsed_json_obj_.text,parsed_json_obj_.media_array,parsed_json_obj_.urls_array,config_,signal_pipe_);
    footer_d_box=new FooterDrawingBox(parsed_json_obj_.created_at,parsed_json_obj_.source_label,parsed_json_obj_.source_url,config_,signal_pipe_);
    
    this.attach(header_d_box,1,0,1,1);
    this.attach(text_d_box,1,1,1,1);
    this.attach(footer_d_box,1,3,1,1);
        
    //背景色の設定
    profile_image_ebox.override_background_color(StateFlags.NORMAL,config_.clear);

    reply_ebox.override_background_color(StateFlags.NORMAL,config_.clear);
    retweet_ebox.override_background_color(StateFlags.NORMAL,config_.clear);
    favorite_ebox.override_background_color(StateFlags.NORMAL,config_.clear);
        
    set_bg_color();

    //iconのload
    reply_icon.set_from_pixbuf(get_pixbuf_from_path(config_.reply_icon_path,16));
    retweet_icon.set_from_pixbuf(get_pixbuf_from_path(config_.retweet_icon_path,16));
    favorite_icon.set_from_pixbuf(get_pixbuf_from_path(config_.favorite_icon_path,16));
    
    //profile_imageのset
    get_pixbuf_async.begin(config_.cache_dir_path,parsed_json_obj_.screen_name,parsed_json_obj_.profile_image_url,48,config.profile_image_hash_table,(obj,res)=>{
      set_profile_image(get_pixbuf_async.end(res));
    });
    
    //rt_d_boxの追加
    if(parsed_json_obj_.is_retweet){
      var rt_d_box=new RetweetDrawingBox(parsed_json_obj_.rt_screen_name,parsed_json_obj_.rt_profile_image_url,config_,signal_pipe_);
      this.attach(rt_d_box,1,4,1,1);
    }
    
    //in_reply_d_boxの追加
    if(parsed_json_obj_.in_reply_to_status_id!=null){
      var in_reply_d_box=new InReplyDrawingBox(api_proxy,parsed_json_obj_.in_reply_to_status_id,config_,signal_pipe_);
      this.attach(in_reply_d_box,1,5,1,1);
    }

    //背景色設定のシグナル
    signal_pipe.color_change.connect(()=>{
      set_bg_color();
      this.hide();
      this.show();
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
    }else{
      this.override_background_color(StateFlags.NORMAL,config_.default_bg_rgba);
    }
  }
  
  //pixbufのset
  public void set_profile_image(Pixbuf pixbuf){
    profile_image_image.set_from_pixbuf(pixbuf);
  }
}
