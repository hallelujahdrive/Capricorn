using Cairo;
using Gdk;
using Gtk;

using ImageUtil;
using URIUtil;

class PhotoBox:DrawingBox{
  private int num;
  private unowned Func<int> func;
    
  public Pixbuf pixbuf;
  private Pixbuf resized_pixbuf;
  private Surface image_surface;
  
  //button_release_eventのCallback
  [GtkCallback]
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    func(num);
    return true;
  }
  
  //drawのcallback
  [GtkCallback]
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    if(pixbuf!=null){
      width=this.get_allocated_width();
      resized_pixbuf=scale_pixbuf(width,height,pixbuf);
      height=resized_pixbuf.height;
      
      image_surface=cairo_surface_create_from_pixbuf(resized_pixbuf,1,null);
      context.set_source_surface(image_surface,0,0);
      context.paint();
      this.set_size_request(-1,height);
    }
    return true;
  }
  
  public PhotoBox(int num,string media_url,Func<int> func){
    base(null,null);
    this.num=num;
    this.func=func;
    
    this.hexpand=true;
    this.vexpand=true;
    
    get_media_pixbuf_async(media_url,(obj,res)=>{
      pixbuf=get_media_pixbuf_async.end(res);
      //再描画
      drawing_area.queue_draw();
    });
  }
  
  //縦サイズ変更
  public void change_allocated_height(int _height){
    height=_height;
    this.queue_draw();
  }
}
