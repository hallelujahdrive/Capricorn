using Gdk;
using Gtk;

using ImageUtils;

class ProfileImageButton:ImageButton{
  public ProfileImageButton(string screen_name,string profile_image_url,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    //loadingiconのset
    image.set_from_animation(config.loading_animation_icon_pixbuf);
    
    //profile_imageのset
    get_pixbuf_async.begin(config_.cache_dir_path,screen_name,profile_image_url,48,config.profile_image_hash_table,(obj,res)=>{
      image.set_from_pixbuf(get_pixbuf_async.end(res));
    });
  }
}
