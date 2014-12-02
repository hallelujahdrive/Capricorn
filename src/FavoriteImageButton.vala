using Gtk;
using Gdk;
using Rest;

using ImageUtils;
using TwitterUtils;

class FavoriteImageButton:ImageButton{
  private bool favorited_;
  
  private string tweet_id_str_;
  private OAuthProxy api_proxy_;
  
  //button_release_eventのCallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    if(favorited_){
    }else if(favorited_=favorite(tweet_id_str_,api_proxy_)){
      image.set_from_pixbuf(config_.favorite_on_icon_pixbuf);
    }
    
    return favorited_;
  }
  
  //enetr_notify_eventのCallback(override)
  protected override bool enter_notify_event_cb(EventCrossing event){
    base.enter_notify_event_cb(event);
    
    if(!favorited_){
      image.set_from_pixbuf(config_.favorite_hover_icon_pixbuf);
    }
    
    return true;
  }

  //leave_notify_eventのCallback(override)
  protected override bool leave_notify_event_cb(EventCrossing event){
    base.leave_notify_event_cb(event);
    
    if(!favorited_){
      image.set_from_pixbuf(config_.favorite_icon_pixbuf);
    }
        
    return true;
  }
  
  public FavoriteImageButton(string tweet_id_str,OAuthProxy api_proxy,bool favorited,Config config){
    favorited_=favorited;
    
    tweet_id_str_=tweet_id_str;
    api_proxy_=api_proxy;
    
    config_=config;
    
    //defaultのiconのset
    if(favorited_){
      image.set_from_pixbuf(config_.favorite_on_icon_pixbuf);
    }else{
      image.set_from_pixbuf(config_.favorite_icon_pixbuf);
    }
  }
}
