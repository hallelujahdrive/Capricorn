using Cairo;
using Gdk;
using Gtk;

using ImageUtils;
using UriUtils;

class PhotoBox:DrawingBox{
  private int num_;
  private Func<int> func_;
  private media _media_;
    
  private Pixbuf pixbuf_;
  private Pixbuf resized_pixbuf;
  private Surface image_surface;
  
  //button_release_eventのCallback
  [GtkCallback]
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    func_(num_);
    return true;
  }
  
  //drawのcallback
  [GtkCallback]
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    if(pixbuf_!=null){
      w=this.get_allocated_width();
      resized_pixbuf=resize_pixbuf(w,null,pixbuf_);
      h=resized_pixbuf.height;
    
      image_surface=cairo_surface_create_from_pixbuf(resized_pixbuf,1,null);
      context.set_source_surface(image_surface,0,0);
      context.paint();
      this.set_size_request(-1,h);
    }
    return true;
  }
  
  public PhotoBox(int num,media _media,Func<int> func){
    num_=num;
    _media_=_media;
    func_=func;
    
    this.hexpand=true;
    this.vexpand=true;
  }
  
  public async Pixbuf load_photo_async(){
    get_media_pixbuf_async(_media_.media_url,(obj,res)=>{
      pixbuf_=get_media_pixbuf_async.end(res);
      //再描画
      drawing_area.queue_draw();
      load_photo_async.callback();
    });
    yield;
    return pixbuf_;
  }
}
