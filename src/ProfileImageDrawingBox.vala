using Cairo;
using Gdk;
using Gtk;

using ImageUtils;

class ProfileImageDrawingBox:DrawingBox{
  private bool account_is_protected_;
  
  private Pixbuf profile_image_pixbuf;  
  private Pixbuf protected_icon_pixbuf;
  private Surface image_surface;
  
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    image_surface=cairo_surface_create_from_pixbuf(profile_image_pixbuf,1,null);
    context.set_source_surface(image_surface,0,0);
    context.paint();
    if(account_is_protected_){
      image_surface=cairo_surface_create_from_pixbuf(protected_icon_pixbuf,1,null);
      context.set_source_surface(image_surface,28,28);
      context.paint();
    }
    return true;
  }
  
  public ProfileImageDrawingBox(string screen_name,string profile_image_url,bool account_is_protected,Config config,SignalPipe signal_pipe_){
    account_is_protected_=account_is_protected;
    
    this.hexpand=false;
    this.set_size_request(48,48);
    
    //profile_image_pixbufの取得
    profile_image_pixbuf=get_pixbuf_from_path(config.loading_icon_path,48);
    if(account_is_protected_){
      protected_icon_pixbuf=get_pixbuf_from_path(config.protected_icon_path,20);
    }
    get_pixbuf_async.begin(config.cache_dir_path,screen_name,profile_image_url,48,config.profile_image_hash_table,(obj,res)=>{
      profile_image_pixbuf=get_pixbuf_async.end(res);
      //再描画
      drawing_area.hide();
      drawing_area.show();
    });
  }
}
