using Gtk;
using Sqlite;

using FileUtil;
using SqliteUtil;
using TwitterUtil;

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
      insert_font(0,config.font_profile,config.db);
      insert_timeline_node_count(config.init_node_count,config.tl_node_count,config.db);
      
      can_window_open=true;
    }else{
      //テーブルが存在したら
      //colorの読み出し
      select_color(0,config);
      //フォントの読み出し
      select_font(0,config.font_profile,config.db);
      //ツイート取得数の読み出し
      select_timeline_nodes(ref config.init_node_count,ref config.tl_node_count,config.db);
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
          insert_account(account_array.index(0),config.db);
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
