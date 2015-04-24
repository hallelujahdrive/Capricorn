using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/network_settings_page.ui")]
class NetworkSettingsPage:Frame{
  private weak Config config;

  [GtkChild]
  public Image tab;
  public NetworkSettingsPage(Config config){
    this.config=config;
  }
}
