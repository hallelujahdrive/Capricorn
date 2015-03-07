using Gdk;
using Gtk;
using Pango;
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
  private SignalPipe signal_pipe_;
  //font  
  public FontProfile font_profile=new FontProfile();
  
  //Gdk.RGBA
  public RGBA default_bg_rgba=RGBA();
  public RGBA reply_bg_rgba=RGBA();
  public RGBA retweet_bg_rgba=RGBA();
  public RGBA mine_bg_rgba=RGBA();
    
  public RGBA clear=RGBA();
  public RGBA white=RGBA();
  
  public RGBA delete_bg_rgba=RGBA();
  
  //ツイートの取得数
  public int get_tweet_nodes;
  public int tweet_node_max;
  
  //時差
  public string datetime_format="%I:%M%P - %e %b %g";
  public int time_deff_hour=9;
  public int time_deff_min=0;
  
  public Config(string cpr_dir_path,SignalPipe signal_pipe){
    cache_dir_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cpr_dir_path,"cache");
    
    signal_pipe_=signal_pipe;
    
    //Gdk.RGBAの設定
    clear.alpha=0;
    white.parse("rgb(255,255,255)");
    delete_bg_rgba.parse("rgb(255,0,0)");
    
    default_bg_rgba.alpha=1;
    reply_bg_rgba.alpha=1;
    retweet_bg_rgba.alpha=1;
    mine_bg_rgba.alpha=1;
    
    //IconThemeの読み込み
    icon_theme.set_custom_theme("hicolor");
  }
  
  //defaultのcolor
  public void init(){
    default_bg_rgba.parse("rgb(255,255,255)");
    reply_bg_rgba.parse("rgb(204,255,128)");
    retweet_bg_rgba.parse("rgb(255,217,82)");
    mine_bg_rgba.parse("rgb(193,209,255)");
    
    get_tweet_nodes=10;
    tweet_node_max=50;
  }
}
