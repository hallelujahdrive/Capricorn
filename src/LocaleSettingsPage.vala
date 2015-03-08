using Gtk;

using DateTimeUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/locale_settings_page.ui")]
class LocaleSettingsPage:Frame{
  private Config _config;
  
  public Label tab=new Label("Locale");
  
  //CellRenderer
  private CellRendererText location_cell_text=new CellRendererText();
  private CellRendererText timedeff_cell_text=new CellRendererText();
  
  [GtkChild]
  private CheckButton timezone_cbutton;
  
  [GtkChild]
  private ComboBox timezone_cbox;
  
  [GtkChild]
  private ListStore timezone_list_store;
  private TreeIter iter;
  
  [GtkCallback]
  private void timezone_cbutton_toggled_cb(){
    if(timezone_cbutton.active){
      timezone_cbox.sensitive=false;
    }else{
      timezone_cbox.sensitive=true;
    }
  }
  public LocaleSettingsPage(Config config){
        
    //ComboBoxの設定
    timezone_cbox.pack_start(location_cell_text,false);
    timezone_cbox.add_attribute(location_cell_text,"text",1);
    timezone_cbox.pack_start(timedeff_cell_text,false);
    timezone_cbox.add_attribute(timedeff_cell_text,"text",2);
    
  }
}
