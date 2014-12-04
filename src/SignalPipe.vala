public class SignalPipe{
  //colorが変更された
  public signal void color_change_event();
  
  //リプライの要求
  public signal void reply_request_event(string tweet_id_str,string screen_name);
  
  //SettingsWindowのOpen
  public signal void settings_button_click_event(SettingsImageButton settings_image_button);
}
