using Rest;
using Pango;
using Sqlite;

using AccountInfo;
using JsonOpr;
using OAuth;
using SqliteOpr;
using TLObject;
using Twitter;
using UI;

namespace Capricorn{
  //本体
  class CprWindow:AppWindow{
    //コンストラクタ
    //fontの設定
    private int font_size=10;
    private string font_family="VLGothic";
    private Pango.FontDescription font_desk=new Pango.FontDescription();
    
    private GLib.Array<TLScrolled> tl_scrolled_array=new GLib.Array<TLScrolled>();
    //ツイートの取得数上限
    private static int get_tweet_max=10;
    //時差
    private static int[] time_deff={9,0};
    
    public CprWindow(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      //プロパティ
      font_desk.set_size((int)font_size*Pango.SCALE);
      font_desk.set_family(font_family);
      
      //これ暫定の何かだから気にしないで
      Gtk.Label home_label=new Gtk.Label("home");
      Gtk.Label mention_label=new Gtk.Label("mention");
      //TLを作ろう!
      for(int i=0;i<account_array.length;i++){
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),get_tweet_max,cache_dir,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,home_label);
        this.mention_note.append_page(tl_scrolled_array.index(i).mention_scrolled,mention_label);
      }
      
      //シグナルのコネクト
      this.post_box.post_button.clicked.connect(()=>{
        post_button_clicked(this.post_box.post_textview,account_array.index(0));
      });
      
    }
    
    private void post_button_clicked(Gtk.TextView post_textview,Account account){
      string post=post_textview.buffer.text;
      if(post!=""){
        Twitter.post_tweet(post,account.api_proxy);
        post_textview.buffer.text="";
      }
    }
  }
  
  //TLScrolled
  class TLScrolled:GLib.Object{
    //コンストラクタ
    public TLScrolledObj home_tl_scrolled=new TLScrolledObj();
    public TLScrolledObj mention_scrolled=new TLScrolledObj();
    
    private GLib.StringBuilder json_sb=new GLib.StringBuilder();
    
    private int get_tweet_max;
    private string *cache_dir;
    private int[] time_deff;
    private Account account;
    private Pango.FontDescription *font_desk;
    private Sqlite.Database *db;
    public TLScrolled(Account account_param,int get_tweet_max_param,string cache_dir_param,int[] time_deff_param,Pango.FontDescription font_desk_param,Sqlite.Database db_param){
      //もうポインタで呼べばいいんじゃねーの
      get_tweet_max=get_tweet_max_param;
      cache_dir=cache_dir_param;
      time_deff=time_deff_param;
      account=account_param;
      font_desk=font_desk_param;
      db=db_param;      
      //tl初期化
      //通常apiによる取得
      //home
      get_timeline(account,false,get_tweet_max,cache_dir,time_deff,font_desk,db);
      //mention
      get_timeline(account,true,get_tweet_max,cache_dir,time_deff,font_desk,db);
      
      //StreamingAPI
      ProxyCall stream_call=account.stream_proxy.new_call();
      stream_call.set_function(FUNCTION_USER);
      stream_call.set_method("GET");
      try{
        stream_call.continuous(user_stream_cb,stream_call);
      }catch(Error e){
        print("%s\n",e.message);
      }
    }
    
    //APIで取得
    private void get_timeline(Account account,bool mention,int get_tweet_max,string cache_dir,int[] time_deff,Pango.FontDescription font_desk,Sqlite.Database db){
      uint obj_count=0;
      //json用のstring[]
      string[] tl_json=Twitter.get_timeline_json(account.api_proxy,get_tweet_max,mention);
      if(mention){
        obj_count=mention_scrolled.tweet_obj_array.length;
      }
      for(int i=(int)obj_count;i<tl_json.length;i++){
        make_and_add_tweet(tl_json[i],mention,false);
      }
    }
    
    //objectを作る
    private void make_and_add_tweet(string json_str,bool mention,bool stream){
      ParseJson parse_json=new ParseJson(json_str,account.my_screen_name,time_deff,db);
      //tlに追加
      if(parse_json.created_at!=null){
        Tweet new_tweet=new Tweet(parse_json,cache_dir,stream,font_desk,db);
        if(!mention){
          home_tl_scrolled.add_tweet_obj(new_tweet.normal_tweet_obj,get_tweet_max,stream);
        }
        //replyはmentionに追加する
        if(parse_json.reply||mention){
            mention_scrolled.add_tweet_obj(new_tweet.reply_obj,get_tweet_max,stream);
        }
      }
    }
    
    //ユーザーストリームのcallback
    private void user_stream_cb(ProxyCall stream_call,string buf,size_t len,Error? error){
    string tweet_json=buf.substring(0,(int)len);
      if(tweet_json!="\n"){
        json_sb.append(tweet_json);
        if(tweet_json.has_suffix("\r\n")||tweet_json.has_suffix("\r")){
          //投げる
          make_and_add_tweet(json_sb.str,false,true);
          json_sb.erase();
        }
      }
    }
  }
}
