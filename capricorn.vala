using Rest;
using Pango;
using Sqlite;

using ContentsObj;
using FileOpr;
using JsonOpr;
using OAuth;
using Settings;
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
    private static int get_tweet_max=15;
    //時差
    private static int[] time_deff={9,0};
    
    //選択中のアカウント
    private int select_account_num;
    //アカウントリスト更新中のchangedシグナルの停止
    private bool list_not_reloading=true;
    
    //アカウント操作がされたかどうか
    private bool account_add_or_remove;
    
    public CprWindow(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      //プロパティ
      font_desk.set_size((int)font_size*Pango.SCALE);
      font_desk.set_family(font_family);
      
      //comboboxにアカウント入れて
      load_combobox(account_array,cache_dir,db);
      
      //TLを作ろう!
      for(int i=0;i<account_array.length;i++){
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),get_tweet_max,cache_dir,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,tl_scrolled_array.index(i).home_tag_image);
        this.mention_note.append_page(tl_scrolled_array.index(i).mention_scrolled,tl_scrolled_array.index(i).mention_tag_image);
      }
      
      //シグナルのコネクト
      this.post_box.post_button.clicked.connect(()=>{
        post_button_clicked(this.post_box.post_textview,account_array.index(select_account_num));
      });
      
      //文字数のカウントですよ
      this.post_box.post_textview.buffer.changed.connect(()=>{
        this.post_box.chars_count_label.set_text((140-this.post_box.post_textview.buffer.get_char_count()).to_string());
      });
      
      //combobox
      this.post_box.account_cbox.changed.connect(()=>{
        if(list_not_reloading){
          GLib.Value val;
          this.post_box.account_cbox.get_active_iter(out this.post_box.iter);
          this.post_box.account_list_store.get_value(this.post_box.iter,0, out val);
          select_account_num=(int)val;
        }
      });
      
      //settings_windowの起動
      this.settings_box.settings_button.clicked.connect(()=>{
        SettingsWindow settings_window=new SettingsWindow(account_array,cache_dir,&account_add_or_remove,db);
        settings_window.show_all();
        //もしアカウントが操作されていれば,削除,追加
        settings_window.destroy.connect(()=>{
          if(account_add_or_remove){
            add_or_remove_TLScrolled(account_array,cache_dir,db);
          }else{
          }
        });
      });
    }
    
    //ポスト
    private void post_button_clicked(Gtk.TextView post_textview,Account account){
      string post=post_textview.buffer.text;
      if(post!=""){
        Twitter.post_tweet(post,account.api_proxy);
        post_textview.buffer.text="";
      }
    }
    
    //comboboxのロード
    public void load_combobox(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      list_not_reloading=false;
      try{
        Gdk.Pixbuf pixbuf=new Gdk.Pixbuf.from_file("icon/loading_icon.png");
        for(int i=0;i<account_array.length;i++){
          this.post_box.account_list_store.append(out this.post_box.iter);
          this.post_box.account_list_store.set(this.post_box.iter,0,account_array.index(i).my_list_id,1,pixbuf,2,account_array.index(i).my_screen_name);
          string icon_path=SqliteOpr.select_icon_path(account_array.index(i).my_id,db);
          get_image(account_array.index(i).my_screen_name+"_icon",
                     account_array.index(i).my_id,
                     account_array.index(i).my_profile_image_url,
                     icon_path,
                     true,
                     false,
                     false,
                     null,
                     this.post_box.account_list_store,
                     this.post_box.iter,
                     cache_dir,
                     db);
        }
      }catch(Error e){
        print("%s\n",e.message);
      }
      list_not_reloading=true;
      this.post_box.account_cbox.active=0;
      select_account_num=0;
    }
    
    //tl_scrolled_arrayの追加と削除
    private void add_or_remove_TLScrolled(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      //削除
      for(int i=0;i<tl_scrolled_array.length;){
        if(account_array.index(i)==null||tl_scrolled_array.index(i).my_id!=account_array.index(i).my_id){
          home_tl_note.remove(tl_scrolled_array.index(i).home_tl_scrolled);
          mention_note.remove(tl_scrolled_array.index(i).mention_scrolled);
          tl_scrolled_array.remove_index(i);
        }else{
          i++;
        }
      }
      //追加
      for(int i=(int)tl_scrolled_array.length;i<account_array.length;i++){
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),get_tweet_max,cache_dir,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,tl_scrolled_array.index(i).home_tag_image);
        this.mention_note.append_page(tl_scrolled_array.index(i).mention_scrolled,tl_scrolled_array.index(i).mention_tag_image);
      }
    //表示
    this.home_tl_note.show_all();
    this.mention_note.show_all();
    }
  }
  
  //TLScrolled
  class TLScrolled:GLib.Object{
    //コンストラクタ
    public TLScrolledObj home_tl_scrolled;
    public TLScrolledObj mention_scrolled;
    
    public Gtk.Image home_tag_image=new Gtk.Image();
    public Gtk.Image mention_tag_image=new Gtk.Image();
    
    //持っとくと便利かな
    public int my_id;
    
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
      
      my_id=account.my_id;
      
        home_tl_scrolled=new TLScrolledObj(get_tweet_max);
      mention_scrolled=new TLScrolledObj(get_tweet_max);
      //tagのimage
      //もらってくる(冗長に見えるがどのみちGtk.main();までpngは書き出されない)
      string icon_path=SqliteOpr.select_icon_path(account.my_id,db);
      get_image(account.my_screen_name+"_icon",
                 account.my_id,
                 account.my_profile_image_url,
                 icon_path,
                 true,
                 true,
                 false,
                 home_tag_image,
                 null,
                 null,
                 cache_dir,
                 db);
        get_image(account.my_screen_name+"_icon",
                 account.my_id,
                 account.my_profile_image_url,
                 icon_path,
                 true,
                 true,
                 false,
                 mention_tag_image,
                 null,
                 null,
                 cache_dir,
                 db);
                 
      //TL初期化
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
      //json用のstring[]
      string[] tl_json=Twitter.get_timeline_json(account.api_proxy,get_tweet_max,mention);
      for(int i=0;i<tl_json.length;i++){
        make_and_add_tweet(tl_json[i],mention,true);
      }
    }
    
    //objectを作る
    private void make_and_add_tweet(string json_str,bool mention,bool always_get){
      ParseJson parse_json=new ParseJson(json_str,account.my_screen_name,time_deff,db);
      //tlに追加
      if(parse_json.created_at!=null){
        string image_path=SqliteOpr.select_image_path(parse_json.user_id,db);
        //string image_path="/home/chiharu/Documents/vala/cpr.png";
        //通常APIによる取得であれば
        if(!mention){
          TweetObj normal_tweet_obj=new TweetObj(parse_json,font_desk);
          get_image(parse_json.screen_name,
                     parse_json.user_id,
                     parse_json.profile_image_url,
                     image_path,
                     always_get,
                     false,
                     true,
                     normal_tweet_obj.profile_image,
                     null,
                     null,
                     cache_dir,
                     db);
          home_tl_scrolled.add_tweet_obj(normal_tweet_obj,get_tweet_max,always_get);
        }
        //リプライを作るかもしれない
        if(parse_json.reply){
          TweetObj reply_obj=new TweetObj(parse_json,font_desk);
          get_image(parse_json.screen_name,
                     parse_json.user_id,
                     parse_json.profile_image_url,
                     image_path,
                     always_get,
                     !mention,
                     true,
                     reply_obj.profile_image,
                     null,
                     null,
                     cache_dir,
                     db);
          //replyはmentionに追加する
          mention_scrolled.add_tweet_obj(reply_obj,get_tweet_max,always_get);
        }
      }
    }
    
    //ユーザーストリームのcallback
    private void user_stream_cb(ProxyCall stream_call,string? buf,size_t len,Error? error){
      if(buf!=null){
        string tweet_json=buf.substring(0,(int)len);
        if(tweet_json!="\n"){
          json_sb.append(tweet_json);
          if(tweet_json.has_suffix("\r\n")||tweet_json.has_suffix("\r")){
            //投げる
            make_and_add_tweet(json_sb.str,false,false);
            json_sb.erase();
          }
        }
      }
    }
  }
}
