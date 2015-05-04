using Gdk;
using Gtk;
using Pango;
using Soup;
using Sqlite;

using ImageUtil;

public class Config{
  //キャッシュのパス
  public string cache_dir_path;

  //IconTheme
  public IconTheme icon_theme=new IconTheme();
  
  //データベース
  public Database db;
  //アイコンのHashTable
  public HashTable<string,string?> profile_image_hash_table=new HashTable<string,string?>(str_hash,str_equal);
  //signal_pipe
  private weak SignalPipe signal_pipe;
  //font  
  public FontProfile font_profile=new FontProfile();
  //color
  public ColorProfile color_profile=new ColorProfile();
  
  //Nodeの取得数
  public int init_time_line_node_count;
  public int time_line_node_count;
  
  public int event_node_count;
  public bool event_show_on_time_line;
  
  //時差
  public string datetime_format="%I:%M%P - %e %b %g";
  public int time_deff_hour=9;
  public int time_deff_min=0;
  
  //Proxy
  public int use_proxy;
  public URI proxy_uri;
  
  public Config(string cpr_dir_path,SignalPipe signal_pipe){
    cache_dir_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cpr_dir_path,"cache");
    
    this.signal_pipe=signal_pipe;
    
    //IconThemeの読み込み
    icon_theme.set_custom_theme("hicolor");
  }
  
  //初期化
  public void init(){
    init_time_line_node_count=10;
    time_line_node_count=50;
    event_node_count=20;
    event_show_on_time_line=false;
    use_proxy=0;
    proxy_uri=new URI(null);
    
    font_profile.init();
    color_profile.init();
  }
}
