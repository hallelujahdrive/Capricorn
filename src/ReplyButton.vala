using Gtk;
using Gdk;

using ImageUtils;

class ReplyButton:ImageButton{
  private string tweet_id_str_;
  private string screen_name_;
  
  //button_release_eventのCallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    signal_pipe_.reply_request_event(tweet_id_str_,screen_name_);
    
    return true;
  }
  
  //enetr_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    image.set_from_pixbuf(config_.reply_hover_icon_pixbuf);
    
    return true;
  }

  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    image.set_from_pixbuf(config_.reply_icon_pixbuf);
        
    return true;
  }
  
  public ReplyButton(string tweet_id_str,string screen_name,Config config,SignalPipe signal_pipe){
    tweet_id_str_=tweet_id_str;
    screen_name_=screen_name;
    
    config_=config;
    signal_pipe_=signal_pipe;
    
    image.set_from_pixbuf(config_.reply_icon_pixbuf);
  }
}
