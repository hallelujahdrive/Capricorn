using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/event_notify_settings_page.ui")]
class EventNotifySettingsPage:Frame{
  private weak Config config;
  
  public bool changed;
  
  //widget
  [GtkChild]
  private SpinButton event_node_count_spin_button;
  
  [GtkChild]
  private CheckButton event_show_on_timeline_check_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void changed_cb(){
    changed=true;
  }
  
  public EventNotifySettingsPage(Config config){
    this.config=config;
    
    //spinbuttonへの値の挿入
    event_node_count_spin_button.set_value(this.config.event_node_count);
    event_show_on_timeline_check_button.set_active(this.config.event_show_on_timeline);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    changed=false;
  }
  
  public void update_settings(){
    config.event_node_count=event_node_count_spin_button.get_value_as_int();
    config.event_show_on_timeline=event_show_on_timeline_check_button.get_active();
  }
}
