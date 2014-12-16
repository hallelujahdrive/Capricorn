using Gtk;
using Sqlite;

using FileUtils;
using SqliteUtils;
using TwitterUtils;

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

  private bool mk_dirs=false;
  
  public Capricorn(){
    application_id="org.gtk.capricorn";
    flags=GLib.ApplicationFlags.FLAGS_NONE;
    
    signal_pipe=new SignalPipe();
    config=new Config(CPR_DIR_PATH,signal_pipe);
    
    //ディレクトリの作成
    if(mk_cpr_dir(CPR_DIR_PATH,config.cache_dir_path)){
      mk_dirs=true;
    }
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
      insert_timeline_nodes(config.get_tweet_nodes,config.tweet_node_max,config.db);
    }else{
      //テーブルが存在したら
      //colorの読み出し
      select_color(0,config);
      //フォントの読み出し
      select_font(0,config.font_profile,config.db);
      //ツイート取得数の読み出し
      select_timeline_nodes(ref config.get_tweet_nodes,ref config.tweet_node_max,config.db);
      //Account情報の読み出し
      account_count=record_count(config.db,"ACCOUNT");
      for(int i=0;i<account_count;i++){
        var account=new Account();
        select_account(i,account,config.db);
        //配列に追加
        account_array.append_val(account);
        //Account情報の取得
        get_account_info(account_array.index(i));
      }
    }
  }

  public override void startup(){
    base.startup();
    
    //Accountが0なら,認証windowを開く
    if(account_count==0){
      Account account=new Account();
      OAuthDialog oauth_dialog=new OAuthDialog(account_count,account);
      oauth_dialog.show_all();
      
      //シグナルハンドラ
      oauth_dialog.destroy.connect(()=>{
        if(oauth_dialog.success){
          account_array.append_val(account);
          insert_account(account_array.index(0),config.db);
        }
        if(account_count==record_count(config.db,"ACCOUNT")){
          window.destroy();
        }else{
          window.load_all();
        }
      });
    }
    
    //時刻表示のロケールを設定
    Intl.setlocale(LocaleCategory.TIME,"en_US.UTF-8");
    
    //終了処理
    this.shutdown.connect(()=>{
      clear_cache(config.cache_dir_path);
    });
    
    window=new MainWindow(this);
  }
  public override void activate(){
    window.present();
  }
}
