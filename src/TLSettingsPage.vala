using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tl_settings_page.ui")]
class TLSettingsPage:Frame{
  private weak Config _config;
  
  public bool changed;
    
  //Widget
  [GtkChild]
  private SpinButton init_node_count_spin_button;
  
  [GtkChild]
  private SpinButton tl_node_count_spin_button;
  
  [GtkChild]
  public Image tab;
  
  //Callback
  [GtkCallback]
  private void value_changed_cb(){
    changed=true;
  }
  
  public TLSettingsPage(Config config){
    _config=config;
    
    //spinbuttonへの値の挿入
    init_node_count_spin_button.set_value(_config.init_node_count);
    tl_node_count_spin_button.set_value(_config.tl_node_count);
    
    //フラグの初期化(値の挿入前にやると挿入時のシグナルでtrueになる)
    changed=false;
  }
  
  public void set_timeline_nodes(){
    _config.init_node_count=init_node_count_spin_button.get_value_as_int();
    _config.tl_node_count=tl_node_count_spin_button.get_value_as_int();
  }
}
