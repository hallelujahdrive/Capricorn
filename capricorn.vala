using Pango;
using Sqlite;

using AccountInfo;
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
    
    public CprWindow(GLib.Array<Account> account_array,Sqlite.Database db){
      //プロパティ
      font_desk.set_size((int)font_size*Pango.SCALE);
      font_desk.set_family(font_family);
      
      //これ暫定の何かだから気にしないで
      Gtk.Label debug_label=new Gtk.Label("debug");
      //TLを作ろう!
      for(int i=0;i<account_array.length;i++){
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),get_tweet_max,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,debug_label);
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
    public TLScrolled(Account account,int get_tweet_max,int[] time_deff,Pango.FontDescription font_desk,Sqlite.Database db){
      //tl初期化
      home_tl_scrolled.add_tweet_obj(get_timeline_json(account.api_proxy,get_tweet_max,false),account.my_screen_name,time_deff,font_desk,db);
    }
  }
}
