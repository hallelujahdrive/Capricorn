using Gdk;
using Gtk;

class IconButton:ImageButton{
  private string default_icon_;
  private string hover_icon_;
  private string on_icon_;
  private IconSize icon_size_;
  
  private bool already=false;

  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(clicked(already)&&on_icon_!=null){
      already=!already;
      if(already){
        image.set_from_icon_name(on_icon_,icon_size_);
      }else{
        image.set_from_icon_name(default_icon_,icon_size_);
      }
    }
    
    return already;
  }
  
  //enter_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(hover_icon_!=null&&!already){
      image.set_from_icon_name(hover_icon_,icon_size_);
    }
    
    return true;
  }
  
  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(hover_icon_!=null&&!already){
      image.set_from_icon_name(default_icon_,icon_size_);
    }
    
    return true;
  }
  
  public IconButton(string default_icon,string? hover_icon,string? on_icon,IconSize icon_size){
    default_icon_=default_icon;
    hover_icon_=hover_icon;
    on_icon_=on_icon;
    icon_size_=icon_size;
    
    
    image.set_from_icon_name(default_icon_,icon_size_);
  }
}
