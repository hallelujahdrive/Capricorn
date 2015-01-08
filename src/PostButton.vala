using Gdk;
using Gtk;

class PostButton:ImageButton{
  
  //button_release_eventのCallback
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    signal_pipe_.post_button_click_event();
    return true;
  }
  
  public PostButton(Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    image.set_from_pixbuf(config_.post_icon_pixbuf);
  }
}
