using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/timeline_settings_page.ui")]
class TimelineSettingsPage:Frame{
  private weak Config config;
  
  public bool changed;
    
  //Widget
  [GtkChild]
  private SpinButton init_timeline_node_count_spin_button;
  
  [GtkChild]
  private SpinButton timeline_node_count_spin_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void value_changed_cb(){
    changed=true;
  }
  
  public TimelineSettingsPage(Config config){
    this.config=config;
    
    //spinbuttonへの値の挿入
    init_timeline_node_count_spin_button.set_value(this.config.init_timeline_node_count);
    timeline_node_count_spin_button.set_value(this.config.timeline_node_count);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    changed=false;
  }
  
  public void update_settings(){
    config.init_timeline_node_count=init_timeline_node_count_spin_button.get_value_as_int();
    config.timeline_node_count=timeline_node_count_spin_button.get_value_as_int();
  }
}
