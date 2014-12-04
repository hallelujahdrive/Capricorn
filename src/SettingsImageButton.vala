using Gdk;
using Gtk;

public class SettingsImageButton:ImageButton{
    
  //button_release_eventのCallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    signal_pipe_.settings_button_click_event(this);
    return true;
  }
  
  //enetr_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);

    return true;
  }

  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
        
    return true;
  }
  
  public SettingsImageButton(Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    image.set_from_pixbuf(config_.settings_icon_pixbuf);
  }
}
