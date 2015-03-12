using Gdk;
using Gtk;

class IconButton:ImageButton{
  private string _default_icon;
  private string _hover_icon;
  private string _on_icon;
  private IconSize _icon_size;
  
  private bool already=false;

  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(clicked(already)&&_on_icon!=null){
      already=!already;
      if(already){
        image.set_from_icon_name(_on_icon,_icon_size);
      }else{
        image.set_from_icon_name(_default_icon,_icon_size);
      }
    }
    
    return already;
  }
  
  //enter_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(_hover_icon!=null&&!already){
      image.set_from_icon_name(_hover_icon,_icon_size);
    }
    
    return true;
  }
  
  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(_hover_icon!=null&&!already){
      image.set_from_icon_name(_default_icon,_icon_size);
    }
    
    return true;
  }
  
  public IconButton(string default_icon,string? hover_icon,string? on_icon,IconSize icon_size){
    _default_icon=default_icon;
    _hover_icon=hover_icon;
    _on_icon=on_icon;
    _icon_size=icon_size;
    
    image.set_from_icon_name(_default_icon,_icon_size);
  }
}
