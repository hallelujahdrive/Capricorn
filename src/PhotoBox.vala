using Cairo;
using Gdk;
using Gtk;

using ImageUtils;
using UriUtils;

class PhotoBox:DrawingBox{
  private media _media_;
  private Pixbuf pixbuf;
  private Pixbuf resized_pixbuf;
  private Surface image_surface;
  
  //button_release_eventのCallback
  [GtkCallback]
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    return true;
  }
  
  //drawのcallback
  [GtkCallback]
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    w=this.get_allocated_width();
    resized_pixbuf=resize_pixbuf(w,null,pixbuf);
    h=resized_pixbuf.height;
    
    image_surface=cairo_surface_create_from_pixbuf(resized_pixbuf,1,null);
    context.set_source_surface(image_surface,0,0);
    context.paint();
    this.set_size_request(-1,h);
    return true;
  }
  
  public PhotoBox(media _media){
    _media_=_media;
    
    this.hexpand=true;
    this.vexpand=true;
        
    get_media_pixbuf_async(_media_.media_url,(obj,res)=>{
      pixbuf=get_media_pixbuf_async.end(res);
      //再描画
      drawing_area.hide();
      drawing_area.show();
    });
  }
}
