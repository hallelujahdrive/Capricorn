using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/image_button.ui")]
public class ImageButton:EventBox{
  
  private RGBA clear=RGBA();
  
  [GtkChild]
  protected unowned Image image;
  
  //button_release_event_cbのCallack
  [GtkCallback]
  protected virtual bool button_release_event_cb(EventButton event_button){
    return true;
  }
  
  //enter_notify_eventのCallback
  [GtkCallback]
  protected virtual bool enter_notify_event_cb(EventCrossing event){
    return true;
  }
  
  //leave_notify_eventのCallback
  [GtkCallback]
  protected virtual bool leave_notify_event_cb(EventCrossing event){
    return true;
  }
  
  public ImageButton(){
    clear.alpha=0;
    this.override_background_color(StateFlags.NORMAL,clear);
    image.override_background_color(StateFlags.NORMAL,clear);
  }
  
  //clickのシグナル
  public signal bool clicked(bool already);
}
