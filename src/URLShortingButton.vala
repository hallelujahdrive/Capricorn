using Gdk;
using Gtk;

class URLShortoingButton:ImageButton{
  
  //button_release_eventのCallback
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    signal_pipe_.url_shorting_button_click_event();
    return true;
  }
  
  public URLShortoingButton(Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    image.set_from_pixbuf(config_.url_shorting_icon_pixbuf);
  }
}

