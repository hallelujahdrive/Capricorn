using Cairo;
using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/drawing_box.ui")]
class DrawingBox:EventBox{
  protected weak Config _config;
  protected weak SignalPipe _signal_pipe;
  protected Pango.Layout layout;
  
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
    _config=config;
    _signal_pipe=signal_pipe;
    
    clear.alpha=0;
    this.override_background_color(StateFlags.NORMAL,clear);
    drawing_area.override_background_color(StateFlags.NORMAL,clear);

  }
   
  protected void context_set_source_rgba(Context context,RGBA rgba){
   context.set_source_rgba(rgba.red,rgba.green,rgba.blue,rgba.alpha);
  }
}
