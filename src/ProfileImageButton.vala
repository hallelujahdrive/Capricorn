using Gdk;
using Gtk;

using ImageUtils;

class ProfileImageButton:ImageButton{
  private Config config_;
  private SignalPipe signal_pipe_;
  
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
    
    //loadingiconのset
    image.set_from_animation(config.loading_animation_pixbuf);
    
    //profile_imageのset
    get_pixbuf_async.begin(config_.cache_dir_path,screen_name,profile_image_url,48,config.profile_image_hash_table,(obj,res)=>{
      image.set_from_pixbuf(get_pixbuf_async.end(res));
    });
  }
}
