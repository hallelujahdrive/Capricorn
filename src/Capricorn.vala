using Gtk;
using Soup;
using Sqlite;
using Ruribitaki;

using FileUtil;
using SqliteUtil;

public class Capricorn:Gtk.Application{
  //ApplicationWindow
  private MainWindow window;
  
  //Account数
  private static int account_count=0;
  
  //Accountの配列
  public GLib.Array<Account> account_array=new GLib.Array<Account>();
  
  //Path
  private static string CPR_DIR_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,GLib.Environment.get_home_dir(),".capricorn");
  private static string DB_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,CPR_DIR_PATH,"capricorn.db");
  
  //signal_pipe
  public SignalPipe signal_pipe;
  
  //config
  public Config config;
  
  //windowを開けるか否か
  private bool can_window_open;
  
  public Capricorn(){
    application_id="org.gtk.capricorn";
    flags=GLib.ApplicationFlags.FLAGS_NONE;
    
    signal_pipe=new SignalPipe();
    config=new Config(CPR_DIR_PATH,signal_pipe);
    
    //ディレクトリの作成
    mk_cpr_dir(CPR_DIR_PATH,config.cache_dir_path);
    //データベースのオープン
    int ec=Database.open_v2(DB_PATH,out config.db,OPEN_READWRITE|OPEN_CREATE);
    if(ec!=Sqlite.OK){
      print("Can't open database:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    //テーブルの作成
    if(create_tables(config.db)){
      //テーブルが新規に作成されたら
      //configの初期化
      config.init();
      config.font_profile.init();
      //insert
      insert_color(0,config);
      insert_event_notify_settings(config);
      insert_font(0,config.font_profile,config.db);
      insert_network_settings(config);
      insert_time_line_settings(config);

      can_window_open=true;
    }else{
      //テーブルが存在したら
      //select
      select_color(0,config);
      select_event_notify_settings(config);
      select_font(0,config.font_profile,config.db);
      select_network_settings(config);
      select_time_line_settings(config);
      //Account情報の読み出し
      account_count=count_records(config.db,"ACCOUNT");
      for(int i=0;i<account_count;i++){
        var account=new Account(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);
        select_account(i,account,config.db);
        //配列に追加
        account_array.append_val((owned)account);
        //Account情報の取得
        can_window_open=account_verify_credential(account_array.index(i));
      }
    }
  }

  public override void startup(){
    base.startup();
    
    //Accountが0なら,認証windowを開く
    if(account_count==0){
      Account account=new Account(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);
      OAuthDialog oauth_dialog=new OAuthDialog(account_count,account);
      oauth_dialog.show_all();
      
      //シグナルハンドラ
      oauth_dialog.destroy.connect(()=>{
        if(oauth_dialog.success){
          account_array.append_val((owned)account);
          insertaccount(account_array.index(0),config.db);
        }
        if(account_count==count_records(config.db,"ACCOUNT")){
          window.destroy();
        }else{
          window.load_all();
        }
      });
    }
    
    //時刻表示のロケールを設定
    Intl.setlocale(LocaleCategory.TIME,"en_US.UTF-8");
    //Windowを開く
    if(can_window_open){
      window=new MainWindow(this);
    }
    
    //終了処理
    this.shutdown.connect(()=>{
      clear_cache(config.cache_dir_path);
    });
    

  }
  public override void activate(){
    window.present();
  }
}
