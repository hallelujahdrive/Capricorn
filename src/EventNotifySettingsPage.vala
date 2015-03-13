using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/event_notify_settings_page.ui")]
class EventNotifySettingsPage:Frame{
  private weak Config _config;
  
  public bool changed;
  
  //widget
  [GtkChild]
  private SpinButton event_node_count_spin_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void value_changed_cb(){
    changed=true;
  }
  
  public EventNotifySettingsPage(Config config){
    _config=config;
    
    //spinbuttonへの値の挿入
    event_node_count_spin_button.set_value(_config.event_node_count);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    changed=false;
  }
  
  public void get_values(){
    _config.event_node_count=event_node_count_spin_button.get_value_as_int();
  }
}
