using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/event_image.ui")]
class EventImage:EventBox{
  
  private RGBA clear=RGBA();
  
  [GtkChild]
  protected Image image;
  
  //Callback
  [GtkCallback]
  protected virtual bool button_release_event_cb(EventButton event_button){
    return true;
  }

  [GtkCallback]
  protected virtual bool enter_notify_event_cb(EventCrossing event){
    return true;
  }

  [GtkCallback]
  protected virtual bool leave_notify_event_cb(EventCrossing event){
    return true;
  }
  
  public EventImage(){
    clear.alpha=0;
    this.override_background_color(StateFlags.NORMAL,clear);
    image.override_background_color(StateFlags.NORMAL,clear);
  }
  
  //clickのシグナル
  public signal void clicked(EventImage event_image);
}
