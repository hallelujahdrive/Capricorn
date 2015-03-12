using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

class ProfileImageButton:ImageButton{
  private weak Config _config;
  private weak SignalPipe _signal_pipe;
  
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
  
  public ProfileImageButton(User user,Config config,SignalPipe signal_pipe){
    _config=config;
    _signal_pipe=signal_pipe;
    
    //profile_image_pixbufの取得
    try{
      Pixbuf pixbuf=_config.icon_theme.load_icon(LOADING_ICON,48,IconLookupFlags.NO_SVG);
      //load中の画像のRotateSurface
      image.set_from_pixbuf(pixbuf);
      RotateSurface rotate_surface=new RotateSurface(pixbuf);
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
    get_pixbuf_async.begin(_config.cache_dir_path,user.screen_name,user.profile_image_url,48,_config.profile_image_hash_table,(obj,res)=>{
      image.set_from_pixbuf(get_pixbuf_async.end(res));
      profile_image_loaded=true;
    });
  }
}
