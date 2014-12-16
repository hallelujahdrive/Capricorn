using Gdk;
using Pango;
using Sqlite;

using ImageUtils;

public class Config{
  //キャッシュのパス
  public string cache_dir_path;
  //アイコンのパス
  private string reply_icon_path=ICON_DIR_PATH+"reply_icon.png";
  private string reply_hover_icon_path=ICON_DIR_PATH+"reply_hover_icon.png";
  private string retweet_icon_path=ICON_DIR_PATH+"rt_icon.png";
  private string retweet_hover_icon_path=ICON_DIR_PATH+"rt_hover_icon.png";
  private string retweet_on_icon_path=ICON_DIR_PATH+"rt_on_icon.png";
  private string favorite_icon_path=ICON_DIR_PATH+"fav_icon.png";
  private string favorite_hover_icon_path=ICON_DIR_PATH+"fav_hover_icon.png";
  private string favorite_on_icon_path=ICON_DIR_PATH+"fav_on_icon.png";
  
  public string protected_icon_path=ICON_DIR_PATH+"protected_icon.png";
  
  public string loading_icon_path=ICON_DIR_PATH+"loading_icon.png";
  public string post_icon_path=ICON_DIR_PATH+"post_icon.png";
  private string settings_icon_path=ICON_DIR_PATH+"settings_icon.png";
  
  private string loading_animation_icon_path=ICON_DIR_PATH+"loading_icon.gif";
  
  //Pixbuf
  public Pixbuf reply_icon_pixbuf;
  public Pixbuf reply_hover_icon_pixbuf;
  public Pixbuf retweet_icon_pixbuf;
  public Pixbuf retweet_hover_icon_pixbuf;
  public Pixbuf retweet_on_icon_pixbuf;
  public Pixbuf favorite_icon_pixbuf;
  public Pixbuf favorite_hover_icon_pixbuf;
  public Pixbuf favorite_on_icon_pixbuf;
  
  public Pixbuf settings_icon_pixbuf;
  
  public PixbufAnimation loading_animation_icon_pixbuf;
  
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
    white.parse("rgba(255,255,255,255)");
    
    default_bg_rgba.alpha=1;
    reply_bg_rgba.alpha=1;
    retweet_bg_rgba.alpha=1;
    mine_bg_rgba.alpha=1;
    
    reply_icon_pixbuf=get_pixbuf_from_path(reply_icon_path,16);
    reply_hover_icon_pixbuf=get_pixbuf_from_path(reply_hover_icon_path,16);
    retweet_icon_pixbuf=get_pixbuf_from_path(retweet_icon_path,16);
    retweet_hover_icon_pixbuf=get_pixbuf_from_path(retweet_hover_icon_path,16);
    retweet_on_icon_pixbuf=get_pixbuf_from_path(retweet_on_icon_path,16);
    favorite_icon_pixbuf=get_pixbuf_from_path(favorite_icon_path,16);
    favorite_hover_icon_pixbuf=get_pixbuf_from_path(favorite_hover_icon_path,16);
    favorite_on_icon_pixbuf=get_pixbuf_from_path(favorite_on_icon_path,16);
    
    settings_icon_pixbuf=get_pixbuf_from_path(settings_icon_path,24);
    
    loading_animation_icon_pixbuf=get_pixbuf_animation_from_path(loading_animation_icon_path);
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
