using Gdk;
using Gtk;

using ImageUtil;

class ProfileImageButton:ImageButton{
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private bool profile_image_loaded=false;
  
  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    return true;
  }
  
  //enter_notify_eventのCallback(override)
  [GtkCallback]
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    return true;
  }
  
  //leave_notify_eventのCallback(override)
  [GtkCallback]
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    return true;
  }
  
  public ProfileImageButton(string screen_name,string profile_image_url,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(config_.icon_theme.load_icon(LOADING_ICON,48,IconLookupFlags.NO_SVG));
      rotate_surface.run();
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          image.set_from_pixbuf(pixbuf_get_from_surface(surface,0,0,48,48));
        }   
        return !profile_image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_pixbuf_async.begin(config_.cache_dir_path,screen_name,profile_image_url,48,config_.profile_image_hash_table,(obj,res)=>{
      image.set_from_pixbuf(get_pixbuf_async.end(res));
      profile_image_loaded=true;
    });
  }
}
