using Gdk;
using Gtk;

class IconButton:ImageButton{
  private string default_icon;
  private string hover_icon;
  private string on_icon;
  private IconSize icon_size;
  
  public bool already;

  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    (clicked(this));
    return true;
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
  
  public IconButton(string default_icon,string? hover_icon,string? on_icon,IconSize icon_size,bool already=false){
    this.default_icon=default_icon;
    this.hover_icon=hover_icon;
    this.on_icon=on_icon;
    this.icon_size=icon_size;
    this.already=already;
    
    update();
  }
  
  public void update(){
    if(already&&on_icon!=null) {
      image.set_from_icon_name(on_icon,icon_size);
    }else{
      image.set_from_icon_name(default_icon,icon_size);
    }
  }
}
