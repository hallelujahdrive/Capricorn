using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/display_settings_page.ui")]
class DisplaySettingsPage:Frame{
  private Config config_;

  public bool color_is_changed=false;
  public bool font_is_changed=false;
  
  public bool use_default_font;
  
  //widget
  [GtkChild]
  private ColorButton default_bg_color_button;
  
  [GtkChild]
  private ColorButton reply_bg_color_button;
  
  [GtkChild]
  private ColorButton retweet_bg_color_button;
  
  [GtkChild]
  private ColorButton mine_bg_color_button;
  
  [GtkChild]
  private ColorButton default_font_color_button;
  
  [GtkChild]
  private ColorButton name_font_color_button;
  
  [GtkChild]
  private ColorButton text_font_color_button;
  
  [GtkChild]
  private ColorButton footer_font_color_button;
  
  [GtkChild]
  private ColorButton in_reply_font_color_button;
   
  [GtkChild]
  private Box default_font_box;
  
  [GtkChild]
  private FontButton default_font_button;
  
  [GtkChild]
  private CheckButton enable_font_detail_cbutton;
  
  [GtkChild]
  private Grid font_detail_grid;
  
  [GtkChild]
  private FontButton name_font_button;
  
  [GtkChild]
  private FontButton text_font_button;
  
  [GtkChild]
  private FontButton footer_font_button;
  
  [GtkChild]
  private FontButton in_reply_font_button;
  
  [GtkChild]
  public Image tab;
  
  //callback
  [GtkCallback]
  private void color_button_color_set_cb(ColorButton color_button){
    color_is_changed=true;
  }
  
  [GtkCallback]
  private void default_font_button_font_set_cb(FontButton font_button){
    text_font_button.set_font_desc(default_font_button.get_font_desc());
  }
  
  [GtkCallback]
  private void font_set_cb(FontButton font_button){
    font_is_changed=true;
  }
  
  //フォントの詳細設定の有効・無効
  [GtkCallback]
  private void enable_font_detail_cbutton_toggled_cb(){
    font_is_changed=true;
    if(enable_font_detail_cbutton.active){
      default_font_box.set_sensitive(false);
      font_detail_grid.show();
      use_default_font=false;
    }else{
      default_font_box.set_sensitive(true);
      font_detail_grid.hide();
      use_default_font=true;
    }
  }
  
  public DisplaySettingsPage(Config config){
    config_=config;
    use_default_font=config_.font_profile.use_default;
    
    //tabのアイコンの設定
    tab.set_from_pixbuf(config_.display_icon_pixbuf);
    
    //fontbuttonの設定
    enable_font_detail_cbutton.set_active(!config.font_profile.use_default);
    if(use_default_font){
      font_detail_grid.hide();
    }
    
    //ColorButtonの設定
    default_bg_color_button.set_rgba(config_.default_bg_rgba);
    reply_bg_color_button.set_rgba(config_.reply_bg_rgba);
    retweet_bg_color_button.set_rgba(config_.retweet_bg_rgba);
    mine_bg_color_button.set_rgba(config_.mine_bg_rgba);
    
    default_font_color_button.set_rgba(config_.font_profile.text_font_rgba);
    name_font_color_button.set_rgba(config_.font_profile.name_font_rgba);
    text_font_color_button.set_rgba(config_.font_profile.text_font_rgba);
    footer_font_color_button.set_rgba(config_.font_profile.footer_font_rgba);
    in_reply_font_color_button.set_rgba(config_.font_profile.in_reply_font_rgba);
    
    //FontButtonの設定
    default_font_button.set_font_desc(config_.font_profile.text_font_desc);
    
    name_font_button.set_font_desc(config_.font_profile.name_font_desc);
    text_font_button.set_font_desc(config_.font_profile.text_font_desc);
    footer_font_button.set_font_desc(config_.font_profile.footer_font_desc);
    in_reply_font_button.set_font_desc(config_.font_profile.in_reply_font_desc);
  }
  
  public void set_color(){
    config_.default_bg_rgba=default_bg_color_button.get_rgba();
    config_.reply_bg_rgba=reply_bg_color_button.get_rgba();
    config_.retweet_bg_rgba=retweet_bg_color_button.get_rgba();
    config_.mine_bg_rgba=mine_bg_color_button.get_rgba();
    
    if(config_.font_profile.use_default){
      config_.font_profile.text_font_rgba=default_font_color_button.get_rgba();
    }else{
      config_.font_profile.name_font_rgba=name_font_color_button.get_rgba();
      config_.font_profile.text_font_rgba=text_font_color_button.get_rgba();
      config_.font_profile.footer_font_rgba=footer_font_color_button.get_rgba();
      config_.font_profile.in_reply_font_rgba=in_reply_font_color_button.get_rgba();
    }
  }
  
  public void set_font_desc(){
    config_.font_profile.name_font_desc=name_font_button.get_font_desc();
    config_.font_profile.text_font_desc=text_font_button.get_font_desc();
    config_.font_profile.footer_font_desc=footer_font_button.get_font_desc();
    config_.font_profile.in_reply_font_desc=in_reply_font_button.get_font_desc();
    
    config_.font_profile.use_default=use_default_font;
  }
}
