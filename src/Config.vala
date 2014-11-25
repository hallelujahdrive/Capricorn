using Gdk;
using Pango;
using Sqlite;

public class Config{
  //キャッシュのパス
  public string cache_dir_path;
  //アイコンのパス
  public string reply_icon_path="icon/reply_icon.png";
  public string reply_hover_icon_path="icon/reply_hover_icon.png";
  public string retweet_icon_path="icon/rt_icon.png";
  public string retweet_hover_icon_path="icon/rt_hover_icon.png";
  public string retweet_on_icon_path="icon/rt_on_icon.png";
  public string favorite_icon_path="icon/fav_icon.png";
  public string favorite_hover_icon_path="icon/fav_hover_icon.png";
  public string favorite_on_icon_path="icon/fav_on_icon.png";
  
  public string protected_icon_path="icon/protected_icon.png";
  
  public string loading_icon_path="icon/loading_icon.png";
  public string post_icon_path="icon/post_icon.png";
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
  
  //時差
  public string datetime_format="%I:%M%P - %e %b %g";
  public int time_deff_hour=9;
  public int time_deff_min=0;
  
  public Config(string cpr_dir_path,SignalPipe signal_pipe){
    cache_dir_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cpr_dir_path,"cache");
    
    signal_pipe_=signal_pipe;
    
    //Gdk.RGBAの設定
    clear.alpha=0;
    white.parse("rgba(255,255,255,255)");
    
    default_bg_rgba.alpha=1;
    reply_bg_rgba.alpha=1;
    retweet_bg_rgba.alpha=1;
    mine_bg_rgba.alpha=1;
    
  }
  
  //defaultのcolor
  public void init(){
    default_bg_rgba.parse("rgb(255,255,255)");
    reply_bg_rgba.parse("rgb(204,255,128)");
    retweet_bg_rgba.parse("rgb(255,217,82)");
    mine_bg_rgba.parse("rgb(193,209,255)");
  }
}
