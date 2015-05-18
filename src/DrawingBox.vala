using Cairo;
using Gdk;
using Gtk;

using ImageUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/drawing_box.ui")]
class DrawingBox:EventBox{
  protected weak Config config;
  protected weak SignalPipe signal_pipe;
 
  protected Pango.Layout layout;
  protected RotateSurface rotate_surface;
  
  //rotate_surfaceの戻り値
  protected bool image_loaded=false;
  
  private RGBA clear=RGBA();
  
  protected int width;
  protected int height;
  
  [GtkChild]
  protected DrawingArea drawing_area;
  
  //button_release_eventのCallback(子クラスでoverrideする)
  [GtkCallback]
  protected virtual bool button_release_event_cb(EventButton event_button){
    return true;
  }
  
  //drawのcallback(子クラスでoverrideする)
  [GtkCallback]
  protected virtual bool drawing_area_draw_cb(Context context){
    return true;
  }
   
  public DrawingBox(Config? config,SignalPipe? signal_pipe){
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    clear.alpha=0;
    override_background_color(StateFlags.NORMAL,clear);
    drawing_area.override_background_color(StateFlags.NORMAL,clear);

  }
  
  protected void rotate_surface_run(int size){
    try{
      rotate_surface=new RotateSurface(config.icon_theme.load_icon(LOADING_ICON,size,IconLookupFlags.NO_SVG));
      rotate_surface.run();
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
  }
   
  protected void context_set_source_rgba(Context context,RGBA rgba){
   context.set_source_rgba(rgba.red,rgba.green,rgba.blue,rgba.alpha);
  }
}
