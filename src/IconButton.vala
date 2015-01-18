using Gdk;
using Gtk;

class IconButton:ImageButton{
  private Pixbuf default_pixbuf_;
  private Pixbuf hover_pixbuf_;
  private Pixbuf on_pixbuf_;
  
  private bool already_=false;

  //button_release_event_cbのCallack(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(clicked(already_)&&on_pixbuf_!=null){
      already_=!already_;
      if(already_){
        image.set_from_pixbuf(on_pixbuf_);
      }else{
        image.set_from_pixbuf(default_pixbuf_);
      }
    }
    
    return already_;
  }
  
  //enter_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(hover_pixbuf_!=null&&!already_){
      image.set_from_pixbuf(hover_pixbuf_);
    }
    
    return true;
  }
  
  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(hover_pixbuf_!=null&&!already_){
      image.set_from_pixbuf(default_pixbuf_);
    }
    
    return true;
  }
  
  public IconButton(Pixbuf default_pixbuf,Pixbuf? hover_pixbuf,Pixbuf? on_pixbuf){
    default_pixbuf_=default_pixbuf;
    hover_pixbuf_=hover_pixbuf;
    on_pixbuf_=on_pixbuf;
    
    image.set_from_pixbuf(default_pixbuf_);
  }
}
