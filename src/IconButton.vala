using Gdk;
using Gtk;

class IconButton:ImageButton{
  private string default_icon;
  private string hover_icon;
  private string on_icon;
  private IconSize icon_size;
  
  private bool already=false;

  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(clicked(already)&&on_icon!=null){
      already=!already;
      if(already){
        image.set_from_icon_name(on_icon,icon_size);
      }else{
        image.set_from_icon_name(default_icon,icon_size);
      }
    }
    
    return already;
  }
  
  //enter_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(hover_icon!=null&&!already){
      image.set_from_icon_name(hover_icon,icon_size);
    }
    
    return true;
  }
  
  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(hover_icon!=null&&!already){
      image.set_from_icon_name(default_icon,icon_size);
    }
    
    return true;
  }
  
  public IconButton(string default_icon,string? hover_icon,string? on_icon,IconSize icon_size){
    this.default_icon=default_icon;
    this.hover_icon=hover_icon;
    this.on_icon=on_icon;
    this.icon_size=icon_size;
    
    image.set_from_icon_name(this.default_icon,icon_size);
  }
}
