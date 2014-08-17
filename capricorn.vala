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
    private PostBox post_box;
    //fontの設定
    private int font_size=10;
    private string font_family="VLGothic";
    private Pango.FontDescription font_desk=new Pango.FontDescription();
    
    private GLib.Array<TLScrolled> tl_scrolled_array=new GLib.Array<TLScrolled>();
    //ツイートの取得数上限
    private static int get_tweet_max=15;
    //時差
    private static int[] time_deff={9,0};

    //アカウント操作がされたかどうか
    private bool account_add_or_remove;
    
    public CprWindow(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      //プロパティ
      font_desk.set_size((int)font_size*Pango.SCALE);
      font_desk.set_family(font_family);
      
      //post_box;
      post_box=new PostBox(account_array);
      app_grid.attach(post_box,0,0,3,1);
      
      //comboboxにアカウント入れて
      post_box.load_combobox(account_array,cache_dir,db);
      
      //TLを作ろう!
      for(int i=0;i<account_array.length;i++){
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),post_box,get_tweet_max,cache_dir,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,tl_scrolled_array.index(i).home_tag_image);
        this.mention_note.append_page(tl_scrolled_array.index(i).mention_scrolled,tl_scrolled_array.index(i).mention_tag_image);
      }
      
      //シグナルのコネクト      
      //settings_windowの起動
      this.settings_box.settings_button.clicked.connect(()=>{
        SettingsWindow settings_window=new SettingsWindow(account_array,cache_dir,&account_add_or_remove,db);
        settings_window.show_all();
        //もしアカウントが操作されていれば,削除,追加
        settings_window.destroy.connect(()=>{
          if(account_add_or_remove){
            post_box.load_combobox(account_array,cache_dir,db);
            add_or_remove_TLScrolled(account_array,cache_dir,db);
          }
        });
      });
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
        TLScrolled tl_scrolled=new TLScrolled(account_array.index(i),post_box,get_tweet_max,cache_dir,time_deff,font_desk,db);
        tl_scrolled_array.append_val(tl_scrolled);
        this.home_tl_note.append_page(tl_scrolled_array.index(i).home_tl_scrolled,tl_scrolled_array.index(i).home_tag_image);
        this.mention_note.append_page(tl_scrolled_array.index(i).mention_scrolled,tl_scrolled_array.index(i).mention_tag_image);
      }
    //表示
    this.home_tl_note.show_all();
    this.mention_note.show_all();
    }
  }
  
  class PostBox:PostBoxUI{
    //選択中のアカウント
    private int select_account_num;
    //replyするtweetのid
    private string? tweet_id;
    //アカウントリスト更新中のchangedシグナルの停止
    private bool list_not_reloading=true;
    
    public PostBox(GLib.Array<Account> account_array){
      //シグナルの処理
      post_button.clicked.connect(()=>{
        post_button_clicked(post_textview,account_array.index(select_account_num));
      });
      
      //文字数のカウントですよ
      post_textview.buffer.changed.connect(()=>{
        chars_count_label.set_text((140-post_textview.buffer.get_char_count()).to_string());
      });
      
      //combobox
      account_cbox.changed.connect(()=>{
        if(list_not_reloading){
          GLib.Value val;
          account_cbox.get_active_iter(out iter);
          account_list_store.get_value(iter,0, out val);
          select_account_num=(int)val;
        }
      });
    }
    //ポスト
    private void post_button_clicked(Gtk.TextView post_textview,Account account){
      string post=post_textview.buffer.text;
      if(post!=""){
        Twitter.post_tweet(post,tweet_id,account.api_proxy);
        post_textview.buffer.text="";
        tweet_id=null;
      }
    }
    
    //replyの設定
    public void reply_param(string screen_name_param,string tweet_id_param){
      post_textview.buffer.text="@"+screen_name_param+" ";
      tweet_id=tweet_id_param;
    }
    
    //comboboxのロード
    public void load_combobox(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
      list_not_reloading=false;
      account_list_store.clear();
      Gdk.Pixbuf pixbuf=get_pixbuf(LOADING_ICON_PATH,24);
      for(int i=0;i<account_array.length;i++){
        account_list_store.append(out iter);
        account_list_store.set(iter,0,account_array.index(i).my_list_id,1,pixbuf,2,account_array.index(i).my_screen_name);
        string icon_path=SqliteOpr.select_image_path(account_array.index(i).my_id,db);
        set_image_for_liststore(account_array.index(i).my_screen_name,
                    account_array.index(i).my_id,
                    account_array.index(i).my_profile_image_url,
                    icon_path,
                    true,
                    account_list_store,
                    iter,
                    cache_dir,
                    db);
      }
      list_not_reloading=true;
      account_cbox.active=0;
      select_account_num=0;
    
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
    private PostBox post_box;
    private Pango.FontDescription *font_desk;
    private Sqlite.Database *db;
    public TLScrolled(Account account_param,PostBox post_box_param,int get_tweet_max_param,string cache_dir_param,int[] time_deff_param,Pango.FontDescription font_desk_param,Sqlite.Database db_param){
      //もうポインタで呼べばいいんじゃねーの
      get_tweet_max=get_tweet_max_param;
      cache_dir=cache_dir_param;
      time_deff=time_deff_param;
      account=account_param;
      post_box=post_box_param;
      font_desk=font_desk_param;
      db=db_param;
      
      my_id=account.my_id;
      
        home_tl_scrolled=new TLScrolledObj(get_tweet_max);
      mention_scrolled=new TLScrolledObj(get_tweet_max);
      //tagのimage
      //もらってくる
      string icon_path=SqliteOpr.select_image_path(account.my_id,db);
      set_image_for_image(account.my_screen_name,
                 account.my_id,
                 account.my_profile_image_url,
                 icon_path,
                 24,
                 true,
                 true,
                 home_tag_image,
                 cache_dir,
                 db);
        set_image_for_image(account.my_screen_name,
                 account.my_id,
                 account.my_profile_image_url,
                 icon_path,
                 24,
                 true,
                 true,
                 mention_tag_image,
                 cache_dir,
                 db);
                 
      //TL初期化
      //通常apiによる取得
      //home
      get_timeline(false);
      //mention
      get_timeline(true);
      
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
    private void get_timeline(bool mention){
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
        //通常APIによる取得であれば
        if(!mention){
          TweetObj normal_tweet_obj=new TweetObj(post_box,account,parse_json,font_desk);
          set_image_for_image(parse_json.screen_name,
                     parse_json.user_id,
                     parse_json.profile_image_url,
                     image_path,
                     48,
                     always_get,
                     always_get,
                     normal_tweet_obj.profile_image,
                     cache_dir,
                     db);
            if(parse_json.retweet){
              set_image_for_image(parse_json.screen_name,
                      parse_json.rt_user_id,
                      parse_json.rt_profile_image_url,
                      null,
                      16,
                      always_get,
                      true,
                      normal_tweet_obj.rt_profile_image,
                      cache_dir,
                      db);
          }
          home_tl_scrolled.add_tweet_obj(normal_tweet_obj,get_tweet_max,always_get);
        }
        //リプライを作るかもしれない
        if(parse_json.reply){
          TweetObj reply_obj=new TweetObj(post_box,account,parse_json,font_desk);
          set_image_for_image(parse_json.screen_name,
                     parse_json.user_id,
                     parse_json.profile_image_url,
                     image_path,
                     48,
                     always_get, 
                     true,
                     reply_obj.profile_image,
                     cache_dir,
                     db);
            if(parse_json.retweet){
              set_image_for_image(parse_json.screen_name,
                      parse_json.rt_user_id,
                      parse_json.rt_profile_image_url,
                      null,
                      16,
                      always_get,
                      true,
                      reply_obj.rt_profile_image,
                      cache_dir,
                      db);
          }
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
