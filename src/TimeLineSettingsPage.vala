using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/time_line_settings_page.ui")]
class TimeLineSettingsPage:Frame{
  private weak Config _config;
  
  public bool changed;
    
  //Widget
  [GtkChild]
  private SpinButton init_time_line_node_count_spin_button;
  
  [GtkChild]
  private SpinButton time_line_node_count_spin_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void value_changed_cb(){
    changed=true;
  }
  
  public TimeLineSettingsPage(Config config){
    _config=config;
    
    //spinbuttonへの値の挿入
    init_time_line_node_count_spin_button.set_value(_config.init_time_line_node_count);
    time_line_node_count_spin_button.set_value(_config.time_line_node_count);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    changed=false;
  }
  
  public void get_values(){
    _config.init_time_line_node_count=init_time_line_node_count_spin_button.get_value_as_int();
    _config.time_line_node_count=time_line_node_count_spin_button.get_value_as_int();
  }
}
