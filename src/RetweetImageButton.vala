using Gtk;
using Gdk;
using Rest;

using ImageUtils;
using TwitterUtils;

class RetweetImageButton:ImageButton{
  private string tweet_id_str_;
  private OAuthProxy api_proxy_;
  private bool retweeted_;
    
  //button_release_eventのCallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(retweeted_){
    }else if(retweeted_=retweet(tweet_id_str_,api_proxy_)){
      image.set_from_pixbuf(config_.retweet_on_icon_pixbuf);
    }
    
    return retweeted_;
  }
  
  //enetr_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(!retweeted_){
      image.set_from_pixbuf(config_.retweet_hover_icon_pixbuf);
    }
    
    return true;
  }

  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(!retweeted_){
      image.set_from_pixbuf(config_.retweet_icon_pixbuf);
    }
        
    return true;
  }
  
  public RetweetImageButton(string tweet_id_str,OAuthProxy api_proxy,bool retweeted,Config config){
    tweet_id_str_=tweet_id_str;
    api_proxy_=api_proxy;
    retweeted_=retweeted;    
    config_=config;
    
    //defaultのiconのset
    if(retweeted_){
      image.set_from_pixbuf(config_.retweet_on_icon_pixbuf);
    }else{
      image.set_from_pixbuf(config_.retweet_icon_pixbuf);
    }
  }
}
