using Cairo;
using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/drawing_box.ui")]
class DrawingBox:EventBox{
  protected unowned Config config_;
  protected unowned SignalPipe signal_pipe_;
  protected Pango.Layout layout;
  
  private RGBA clear=RGBA();
  
  protected int w;
  protected int h;
  
  [GtkChild]
  protected unowned DrawingArea drawing_area;
  
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
   
  public DrawingBox(){
   clear.alpha=0;
   this.override_background_color(StateFlags.NORMAL,clear);
   drawing_area.override_background_color(StateFlags.NORMAL,clear);

  }
   
  protected void context_set_source_rgba(Context context,RGBA rgba){
   context.set_source_rgba(rgba.red,rgba.green,rgba.blue,rgba.alpha);
  }
}
