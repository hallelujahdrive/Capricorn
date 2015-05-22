using Gtk;
using Soup;

using StringUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/network_settings_page.ui")]
class NetworkSettingsPage:Frame{
  private weak Config config;
  
  private unowned SList<RadioButton> proxy_radio_button_slist;
  
  public bool changed;
  
  //Widget
  [GtkChild]
  private Grid proxy_setting_grid;
  
  [GtkChild]
  private RadioButton proxy_radio_button_0;
  
  [GtkChild]
  private EntryBuffer http_proxy_entry_buffer;
  
  [GtkChild]
  private EntryBuffer http_proxy_port_entry_buffer;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void proxy_manual_setting_radio_button_toggled_cb(ToggleButton button){
    proxy_setting_grid.set_sensitive(button.get_active());
  }
  
  [GtkCallback]
  private void changed_cb(){
    changed=true;
  }
  
  public NetworkSettingsPage(Config config){
    this.config=config;
    
    proxy_radio_button_slist=proxy_radio_button_0.get_group();
    proxy_radio_button_slist.nth_data(config.use_proxy).set_active(true);
    
    //proxyの設定の挿入
    if(this.config.proxy_uri!=null){
      http_proxy_entry_buffer.set_text((uint8[])parse_uri(this.config.proxy_uri));
      http_proxy_port_entry_buffer.set_text((uint8[])this.config.proxy_uri.get_port().to_string());
    }
    
    //sensitive
    proxy_setting_grid.set_sensitive(config.use_proxy==1);
    
    //changedの初期化
    changed=false;
  }
  
  //設定の更新
  public void update_settings(){
    //proxyの使用の可否
    for(int i=0;i<proxy_radio_button_slist.length();i++){
      if(proxy_radio_button_slist.nth_data(i).get_active()){
        config.use_proxy=i;
        //proxy_uriの設定
        config.proxy_uri=new URI(http_proxy_entry_buffer.get_text());
        config.proxy_uri.set_port(int.parse(http_proxy_port_entry_buffer.get_text()));
        break;
      }
    }
  }
}
