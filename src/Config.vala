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
  
  //font  
  public FontProfile font_profile=new FontProfile();
  //color
  public ColorProfile color_profile=new ColorProfile();
  
  //Nodeの取得数
  public int init_timeline_node_count;
  public int timeline_node_count;
  
  public int event_node_count;
  public bool event_show_on_timeline;
  
  //時差
  public string datetime_format="%I:%M%P - %e %b %g";
  public int time_deff_hour=9;
  public int time_deff_min=0;
  
  //Proxy
  public int use_proxy;
  public URI proxy_uri;

  //notebookの設定
  //notebookのarrayの長さ(暫定3)
  public int column_length;
  //pageの位置
  public position[] positions=new position[5];
  
  public Config(string cpr_dir_path){
    cache_dir_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cpr_dir_path,"cache");
        
    //IconThemeの読み込み
    icon_theme.set_custom_theme("hicolor");
  }
  
  //初期化
  public void init(){
    init_timeline_node_count=10;
    timeline_node_count=50;
    event_node_count=20;
    event_show_on_timeline=false;
    use_proxy=0;
    proxy_uri=new URI(null);
    
    positions[PageType.DEFAULT_HOME].column=0;
    positions[PageType.DEFAULT_HOME].tab=-1;
    positions[PageType.DEFAULT_MENTION].column=1;
    positions[PageType.DEFAULT_MENTION].tab=-1;
    positions[PageType.POST].column=2;
    positions[PageType.POST].tab=0;
    positions[PageType.EVENT_NOTIFY].column=2;
    positions[PageType.EVENT_NOTIFY].tab=1;
    positions[PageType.MEDIA].column=2;
    positions[PageType.MEDIA].tab=-1;

    column_length=3;
    
    font_profile.init();
    color_profile.init();
  }
}
